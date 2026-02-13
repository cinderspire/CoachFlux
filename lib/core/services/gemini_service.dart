import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'remote_config_service.dart';
import '../models/coach.dart';
import '../models/message.dart';
import 'goal_service.dart';
import 'mood_service.dart';
import 'problem_engine.dart';
import 'recommendation_service.dart';

class _CacheEntry {
  final String response;
  final DateTime timestamp;
  _CacheEntry(this.response) : timestamp = DateTime.now();
  bool get isValid => DateTime.now().difference(timestamp).inMinutes < 5;
}

class GeminiService {
  static final GeminiService _instance = GeminiService._();
  factory GeminiService() => _instance;
  GeminiService._();

  final String _baseUrl = AppConstants.geminiBaseUrl;
  late final List<String> _apiKeys = List.from(RemoteConfigService().geminiApiKeys);
  int _currentKeyIndex = 0;

  String get _apiKey => _apiKeys[_currentKeyIndex];

  final Map<String, _CacheEntry> _cache = {};

  void setApiKey(String key) {
    _apiKeys[0] = key;
    _currentKeyIndex = 0;
  }

  void _rotateKey() {
    _currentKeyIndex = (_currentKeyIndex + 1) % _apiKeys.length;
    debugPrint('Gemini: rotated to key index $_currentKeyIndex');
  }

  String _cacheKey(String coachId, String message) {
    final normalized = message.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
    return '$coachId:$normalized';
  }

  void _cleanCache() {
    _cache.removeWhere((_, entry) => !entry.isValid);
  }

  /// Load conversation memory for a coach (last 5 key points)
  Future<List<String>> _getConversationMemory(String coachId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('coach_memory_$coachId') ?? [];
  }

  /// Save key points from conversation
  Future<void> saveConversationMemory(String coachId, String keyPoint) async {
    final prefs = await SharedPreferences.getInstance();
    final memory = prefs.getStringList('coach_memory_$coachId') ?? [];
    memory.add(keyPoint);
    // Keep only last 5
    while (memory.length > 5) {
      memory.removeAt(0);
    }
    await prefs.setStringList('coach_memory_$coachId', memory);
  }

  /// Extract key point from AI response for memory
  String? _extractKeyPoint(String response) {
    // Simple heuristic: if response contains actionable advice, homework, or specific technique
    if (response.length > 100) {
      // Take the first sentence that contains action words
      final sentences = response.split(RegExp(r'[.!?]\s'));
      for (final s in sentences) {
        if (s.contains(RegExp(r'try|practice|start|focus|remember|homework|challenge|goal|technique', caseSensitive: false))) {
          return s.trim();
        }
      }
      // Fallback: first meaningful sentence
      if (sentences.isNotEmpty && sentences.first.length > 20) {
        return sentences.first.trim();
      }
    }
    return null;
  }

  Future<String> chat({
    required Coach coach,
    required List<ChatMessage> history,
    required String userMessage,
    UserProfile? userProfile,
  }) async {
    // Check cache first
    _cleanCache();
    final cKey = _cacheKey(coach.id, userMessage);
    final cached = _cache[cKey];
    if (cached != null && cached.isValid) {
      debugPrint('[GeminiService] Cache hit — saving API call');
      return cached.response;
    }

    try {
      // Build rich context
      final goalService = GoalService();
      final activitySummary = await goalService.getActivitySummary();
      final selectedGoals = await goalService.getSelectedGoals();
      final conversationMemory = await _getConversationMemory(coach.id);

      // Get mood context
      String moodContext = '';
      try {
        final scores = await MoodService().last7DaysScores();
        final valid = scores.where((s) => s >= 0).toList();
        if (valid.isNotEmpty) {
          final avg = valid.reduce((a, b) => a + b) / valid.length;
          if (avg >= 0.7) {
            moodContext = 'User has been feeling mostly positive lately.';
          } else if (avg >= 0.5) {
            moodContext = 'User mood has been moderate/mixed lately.';
          } else {
            moodContext = 'User has been struggling emotionally recently. Be extra supportive.';
          }
        }
      } catch (_) {}

      // Build system instruction with RICH context
      final systemParts = <String>[
        coach.systemPrompt,
        'Your name is ${coach.name}. You are a ${coach.title}.',
        'Your personality is ${coach.personality}.',
        'Your expertise: ${coach.expertise.join(", ")}.',
        '',
        '=== CRITICAL INSTRUCTIONS ===',
        'Never give generic advice. Always reference the user\'s SPECIFIC goals and recent activities.',
        'Suggest specific techniques from the library when relevant:',
        '- Focus: Pomodoro Technique, Time Blocking, 2-Minute Rule, Deep Work Protocol',
        '- Mindfulness: Box Breathing (4-4-4-4), Body Scan, 5-4-3-2-1 Grounding, Progressive Muscle Relaxation',
        '- Fitness: 7-Minute Workout, Walking Meditation, Desk Stretches, Energy Audit',
        '- Career: SMART Goal Framework, Weekly Review, Skill Gap Analysis, Networking Challenge',
        '- Financial: 50/30/20 Budget, No-Spend Challenge, Savings Goal Visualizer',
        '',
        'Ask follow-up questions about their progress. Give actionable homework.',
        'Track progress across sessions. Reference what you discussed before.',
        'Keep responses concise (2-4 paragraphs max). Be actionable, not vague.',
        'Never say you are an AI. You are a coach.',
        '',
        '=== USER CONTEXT ===',
      ];

      if (selectedGoals.isNotEmpty) {
        systemParts.add('User\'s goals: ${selectedGoals.join(", ")}');
      }
      if (activitySummary.isNotEmpty) {
        systemParts.add('Goal progress: $activitySummary');
      }
      if (moodContext.isNotEmpty) {
        systemParts.add('Mood: $moodContext');
      }
      if (conversationMemory.isNotEmpty) {
        systemParts.add('Previous conversation key points with this user:');
        for (final m in conversationMemory) {
          systemParts.add('- $m');
        }
      }

      if (userProfile != null && userProfile.toContextString().isNotEmpty) {
        systemParts.add('Additional profile: ${userProfile.toContextString()}');
      }

      // Problem assessment context
      try {
        final assessmentResults = await RecommendationService.loadAssessment();
        if (assessmentResults != null && assessmentResults.isNotEmpty) {
          systemParts.add('');
          systemParts.add(ProblemEngine.buildCoachContext(assessmentResults));
        }
      } catch (_) {}

      // Build conversation history
      final contents = <Map<String, dynamic>>[];

      for (final msg in history.take(20)) {
        contents.add({
          'role': msg.isUser ? 'user' : 'model',
          'parts': [{'text': msg.content}],
        });
      }

      contents.add({
        'role': 'user',
        'parts': [{'text': userMessage}],
      });

      final body = {
        'system_instruction': {
          'parts': [{'text': systemParts.join('\n')}],
        },
        'contents': contents,
        'generationConfig': {
          'temperature': 0.85,
          'topP': 0.95,
          'maxOutputTokens': 1024,
        },
      };

      final url = '$_baseUrl/models/${RemoteConfigService().geminiModel}:generateContent?key=$_apiKey';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        final result = text ?? 'I\'m having trouble responding right now. Let\'s try again.';
        _cache[cKey] = _CacheEntry(result);

        // Save conversation memory
        final keyPoint = _extractKeyPoint(result);
        if (keyPoint != null) {
          await saveConversationMemory(coach.id, keyPoint);
        }

        return result;
      } else if (response.statusCode == 429 && _apiKeys.length > 1) {
        // Rate limited — try next key
        final oldIndex = _currentKeyIndex;
        _rotateKey();
        if (_currentKeyIndex != oldIndex) {
          debugPrint('Gemini: rate limited, retrying with key $_currentKeyIndex');
          final retryUrl = '$_baseUrl/models/${RemoteConfigService().geminiModel}:generateContent?key=$_apiKey';
          final retryResponse = await http.post(
            Uri.parse(retryUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          );
          if (retryResponse.statusCode == 200) {
            final data = jsonDecode(retryResponse.body);
            final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
            final result = text ?? 'I\'m having trouble responding right now. Let\'s try again.';
            _cache[cKey] = _CacheEntry(result);
            return result;
          }
        }
        debugPrint('Gemini: all keys rate limited');
        return _getFallbackResponse(coach, userMessage);
      } else {
        debugPrint('Gemini API error: ${response.statusCode} ${response.body}');
        return _getFallbackResponse(coach, userMessage);
      }
    } catch (e) {
      debugPrint('Gemini error: $e');
      return _getFallbackResponse(coach, userMessage);
    }
  }

  String _getFallbackResponse(Coach coach, String userMessage) {
    // Multiple fallbacks per personality to avoid repetition
    final responses = {
      'warm': [
        'I appreciate you sharing that with me. What you just said holds something important... Let me sit with it for a moment. What feels most alive in what you just shared?',
        'Thank you for trusting me with that. I notice there\'s a deeper layer here. Before we go further — how does it feel to have said that out loud?',
        'That resonates with something I\'ve seen in many of my clients. The courage to name it is the first step. What would feel like progress for you today?',
      ],
      'direct': [
        'Got it. Here\'s what I\'m hearing: there\'s a gap between where you are and where you want to be. Let\'s close it. What\'s the ONE bottleneck right now?',
        'Clear. Let\'s not overthink this — what\'s the smallest action you could take in the next 24 hours that would move the needle? Start there.',
        'I\'ve seen this pattern before. The fix is usually simpler than it feels. Tell me: what have you already tried?',
      ],
      'analytical': [
        'Interesting. Let me map this out. There are usually 2-3 key variables driving this kind of situation. Walk me through the main factors — I want to see the full picture before we optimize.',
        'Let\'s break this into components. What\'s the root cause vs. the symptoms? Often what we think is the problem is actually a downstream effect of something else entirely.',
        'Data point noted. Let me ask you a diagnostic question: if you could change ONE variable in this situation, which one would have the biggest ripple effect?',
      ],
      'playful': [
        'Ooh, now THAT\'S interesting! My brain just lit up. Okay — wild idea incoming — what if you did the complete OPPOSITE of what you\'re thinking? Just as an experiment!',
        'Love this energy! Here\'s what I want to try: forget the "right" answer for a second. If there were zero consequences, what would you ACTUALLY want to do?',
        'Ha! You know what this reminds me of? Every great breakthrough starts exactly like this — a mess with potential. Let\'s find the gold in the chaos.',
      ],
      'empathetic': [
        'I hear you... and I want you to know that what you\'re feeling makes complete sense given what you\'ve been through. You don\'t have to have it all figured out right now. What feels most pressing?',
        'That sounds heavy. I\'m right here with you. Before we try to solve anything — just breathe for a moment. How does your body feel right now?',
        'Thank you for letting me see this. It takes real strength to be this honest. What do you need most right now — to be heard, or to find a way forward?',
      ],
    };
    final list = responses[coach.personality] ?? responses['warm']!;
    return list[DateTime.now().millisecond % list.length];
  }
}
