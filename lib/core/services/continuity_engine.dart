import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// The Continuity Engine creates a sense of ongoing journey and progress.
/// It makes the user feel like the app KNOWS them and their story.
class ContinuityEngine {
  static final ContinuityEngine _instance = ContinuityEngine._();
  factory ContinuityEngine() => _instance;
  ContinuityEngine._();

  static const String _keyJourneyStart = 'ce_journey_start';
  static const String _keySessionLog = 'ce_session_log';
  static const String _keyMoodLog = 'ce_mood_log';
  static const String _keyPromptIndex = 'ce_prompt_index';
  
  

  // ──────────────────────────────────────────────
  // PERSONAL GROWTH PLAN
  // ──────────────────────────────────────────────

  static const List<Map<String, dynamic>> _phases = [
    {
      'number': 1,
      'name': 'Foundation',
      'description':
          'Build self-awareness and establish your emotional baseline. This is about understanding where you are right now — without judgment.',
      'weeklyGoals': [
        'Complete your first 3 coaching sessions and notice how each feels',
        'Track your mood daily and identify your emotional range',
        'Write down 3 personal goals you want to explore over the next 12 weeks',
      ],
    },
    {
      'number': 2,
      'name': 'Exploration',
      'description':
          'Try different coaches and techniques. Discover what resonates with you — there\'s no wrong answer here.',
      'weeklyGoals': [
        'Have sessions with at least 2 new coaches you haven\'t tried',
        'Experiment with a technique outside your comfort zone',
        'Reflect on which coaching style clicks best with your personality',
      ],
    },
    {
      'number': 3,
      'name': 'Deepening',
      'description':
          'Go deeper with the coaches and methods that work for you. This is where real breakthroughs happen.',
      'weeklyGoals': [
        'Have 2+ sessions with your preferred coach on a recurring theme',
        'Identify one core pattern you want to shift',
        'Practice a technique from your sessions in your daily life',
      ],
    },
    {
      'number': 4,
      'name': 'Integration',
      'description':
          'Apply what you\'ve learned and build lasting independence. You\'re becoming your own coach.',
      'weeklyGoals': [
        'Use a coaching technique on your own before seeking a session',
        'Share an insight with someone you trust',
        'Set intentions for your next growth cycle',
      ],
    },
  ];

  Future<DateTime> _getJourneyStart() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_keyJourneyStart);
    if (stored != null) return DateTime.parse(stored);
    final now = DateTime.now();
    await prefs.setString(_keyJourneyStart, now.toIso8601String());
    return now;
  }

  Future<int> _getCurrentWeek() async {
    final start = await _getJourneyStart();
    final days = DateTime.now().difference(start).inDays;
    return (days ~/ 7) + 1;
  }

  Future<GrowthPhase> getCurrentPhase() async {
    final week = await _getCurrentWeek();
    final clampedWeek = week.clamp(1, 12);
    final phaseIndex = ((clampedWeek - 1) ~/ 3).clamp(0, 3);
    final phase = _phases[phaseIndex];
    final phaseStartWeek = phaseIndex * 3 + 1;
    final weeksIntoPhase = clampedWeek - phaseStartWeek;
    final progress = (weeksIntoPhase + 1) / 3.0;

    return GrowthPhase(
      phaseNumber: phase['number'] as int,
      name: phase['name'] as String,
      description: phase['description'] as String,
      currentWeek: clampedWeek,
      weeklyGoals: List<String>.from(phase['weeklyGoals'] as List),
      progress: progress.clamp(0.0, 1.0),
    );
  }

  Future<String> getWeeklyFocus() async {
    final phase = await getCurrentPhase();
    final weekInPhase = ((phase.currentWeek - 1) % 3);
    if (weekInPhase < phase.weeklyGoals.length) {
      return phase.weeklyGoals[weekInPhase];
    }
    return phase.weeklyGoals.last;
  }

  Future<double> getPhaseProgress() async {
    final phase = await getCurrentPhase();
    return phase.progress;
  }

  // ──────────────────────────────────────────────
  // DAILY REFLECTION PROMPTS (60+ per phase)
  // ──────────────────────────────────────────────

  static const Map<int, List<String>> _prompts = {
    1: [
      'What emotion visited you most today?',
      'Name one thing you did for yourself today — no matter how small.',
      'If your body could talk right now, what would it say?',
      'What drained your energy today? What restored it?',
      'Describe your mood in a single color. Why that one?',
      'What thought kept circling back today?',
      'When did you feel most like yourself today?',
      'What would "enough" look like for you right now?',
      'Name something you\'re carrying that isn\'t yours to carry.',
      'What did you need today that you didn\'t ask for?',
      'If today had a title, what would it be?',
      'What surprised you about how you felt today?',
      'Where in your body do you hold stress? Check in with that spot now.',
      'What\'s one belief about yourself you\'d like to question?',
      'When was the last time you felt truly calm? What was happening?',
      'What are you afraid to admit you want?',
    ],
    2: [
      'What new perspective did you encounter this week?',
      'Which coaching technique felt most natural to you? Why?',
      'What would you try if you knew you couldn\'t fail?',
      'Describe a moment this week where you responded differently than usual.',
      'What pattern are you starting to notice in your sessions?',
      'If you could ask any question and get an honest answer, what would it be?',
      'What does courage look like for you this week?',
      'Name a boundary you set or wish you had set recently.',
      'What would your ideal Tuesday look like?',
      'Which coach\'s words stayed with you? What did they say?',
      'What part of yourself are you getting reacquainted with?',
      'How do you sabotage your own peace? Be honest.',
      'What would change if you trusted yourself 10% more?',
      'When someone asks how you\'re doing, what do you leave out?',
      'What technique felt uncomfortable but useful?',
      'What are you learning about how you relate to others?',
    ],
    3: [
      'What pattern are you ready to break?',
      'What would you tell your younger self about this week?',
      'How has your definition of "progress" changed since you started?',
      'What truth have you been dancing around?',
      'Name one way you\'ve grown that nobody else would notice.',
      'What would happen if you stopped performing strength?',
      'Describe the version of you that exists on the other side of this work.',
      'What have you forgiven yourself for recently?',
      'What conversation are you avoiding? What would it take to have it?',
      'How do you know when you\'re being authentic vs. performing?',
      'What coping mechanism has outlived its usefulness?',
      'If your current struggle had a gift inside it, what might it be?',
      'What relationship in your life mirrors your relationship with yourself?',
      'Name something you used to believe that you\'ve outgrown.',
      'What does safety feel like in your body?',
      'What are you grieving that you haven\'t named yet?',
    ],
    4: [
      'What insight from your journey do you want to carry forward?',
      'How would you coach a friend through what you\'ve been facing?',
      'What does your "after" look like compared to your "before"?',
      'Name three things you now know about yourself that you didn\'t 12 weeks ago.',
      'What will you do differently when the next hard season comes?',
      'Write a permission slip to yourself. What does it say?',
      'How has your relationship with your emotions changed?',
      'What would you include in a letter to future-you?',
      'What part of this journey was harder than expected? Easier?',
      'Who in your life has noticed a change in you?',
      'What does independence mean for your mental health?',
      'Name a moment from your sessions that changed how you see things.',
      'What ritual or habit from this journey will you keep?',
      'How do you want to show up in the world going forward?',
      'What are you proud of that has nothing to do with achievement?',
      'If you met yourself for the first time today, what would you notice?',
    ],
  };

  Future<String> getDailyPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    final phase = await getCurrentPhase();
    final phaseNum = phase.phaseNumber;
    final prompts = _prompts[phaseNum]!;
    final indexKey = '${_keyPromptIndex}_$phaseNum';
    int index = prefs.getInt(indexKey) ?? 0;

    // Advance daily: use day-of-year so it changes each day
    final dayOfYear = DateTime.now().difference(
      DateTime(DateTime.now().year),
    ).inDays;
    index = dayOfYear % prompts.length;

    await prefs.setInt(indexKey, index);
    return prompts[index];
  }

  // ──────────────────────────────────────────────
  // SESSION & MOOD LOGGING
  // ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _getSessionLog() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keySessionLog);
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(raw) as List);
  }

  Future<void> logSession({
    required String coachId,
    required String technique,
    required double moodBefore,
    required double moodAfter,
    String? insight,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final log = await _getSessionLog();
    log.add({
      'coachId': coachId,
      'technique': technique,
      'moodBefore': moodBefore,
      'moodAfter': moodAfter,
      'insight': insight,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await prefs.setString(_keySessionLog, jsonEncode(log));

    // Also log mood
    final moods = await _getMoodLog();
    moods.add({
      'before': moodBefore,
      'after': moodAfter,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await prefs.setString(_keyMoodLog, jsonEncode(moods));
  }

  Future<List<Map<String, dynamic>>> _getMoodLog() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyMoodLog);
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(raw) as List);
  }

  // ──────────────────────────────────────────────
  // COACH RECOMMENDATIONS
  // ──────────────────────────────────────────────

  static const List<String> _defaultCoaches = [
    'dr_aura',
    'coach_ember',
    'sage',
    'luna',
    'atlas',
  ];

  static const Map<String, List<String>> _coachTechniques = {
    'dr_aura': ['cognitive reframing', 'anxiety mapping', 'thought journaling'],
    'coach_ember': ['motivation anchoring', 'goal visualization', 'habit stacking'],
    'sage': ['mindfulness meditation', 'body scan', 'breath work'],
    'luna': ['inner child work', 'emotional processing', 'dream analysis'],
    'atlas': ['stoic reflection', 'value clarification', 'decision frameworks'],
  };

  Future<String> getRecommendedCoach() async {
    final log = await _getSessionLog();
    final phase = await getCurrentPhase();

    if (log.isEmpty) return _defaultCoaches[0];

    // Phase 2: recommend least-used coach to encourage exploration
    if (phase.phaseNumber == 2) {
      final usage = <String, int>{};
      for (final c in _defaultCoaches) {
        usage[c] = 0;
      }
      for (final s in log) {
        final id = s['coachId'] as String;
        usage[id] = (usage[id] ?? 0) + 1;
      }
      final sorted = usage.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      return sorted.first.key;
    }

    // Phase 3-4: recommend coach with best mood improvement
    final coachMoodDelta = <String, List<double>>{};
    for (final s in log) {
      final id = s['coachId'] as String;
      final delta = (s['moodAfter'] as num) - (s['moodBefore'] as num);
      coachMoodDelta.putIfAbsent(id, () => []).add(delta.toDouble());
    }

    String bestCoach = _defaultCoaches[0];
    double bestAvg = -999;
    for (final entry in coachMoodDelta.entries) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      if (avg > bestAvg) {
        bestAvg = avg;
        bestCoach = entry.key;
      }
    }
    return bestCoach;
  }

  Future<String> getRecommendedTechnique() async {
    final coach = await getRecommendedCoach();
    final techniques = _coachTechniques[coach];
    if (techniques == null || techniques.isEmpty) return 'mindfulness meditation';
    final dayIndex = DateTime.now().day % techniques.length;
    return techniques[dayIndex];
  }

  Future<DailyChallenge> getDailyChallenge() async {
    final phase = await getCurrentPhase();
    final coach = await getRecommendedCoach();
    final technique = await getRecommendedTechnique();

    const categories = ['mindset', 'social', 'physical', 'creative', 'reflective'];
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final category = categories[dayOfYear % categories.length];

    final challenges = <String, Map<String, String>>{
      'mindset': {
        'title': 'Reframe one negative thought',
        'description':
            'Catch one negative thought today and consciously rewrite it. Use "$technique" to guide you.',
      },
      'social': {
        'title': 'Genuine connection moment',
        'description':
            'Have one conversation today where you truly listen without planning your response.',
      },
      'physical': {
        'title': 'Body check-in',
        'description':
            'Set 3 random alarms today. When they ring, pause and notice what your body feels.',
      },
      'creative': {
        'title': 'Express without words',
        'description':
            'Draw, hum, or move to express how you\'re feeling right now. No editing, no judgment.',
      },
      'reflective': {
        'title': 'Micro-journaling',
        'description':
            'Write 3 sentences before bed: what you felt, what you learned, what you\'re letting go of.',
      },
    };

    final challenge = challenges[category]!;
    final xp = 50 + (phase.phaseNumber * 10);

    return DailyChallenge(
      title: challenge['title']!,
      description: challenge['description']!,
      coachId: coach,
      xpReward: xp,
      category: category,
    );
  }

  // ──────────────────────────────────────────────
  // PROGRESS NARRATIVE
  // ──────────────────────────────────────────────

  Future<String> getProgressNarrative() async {
    final log = await _getSessionLog();
    final phase = await getCurrentPhase();
    final week = phase.currentWeek;

    if (log.isEmpty) {
      return 'Your AI CoachFlux journey begins now. You\'re in the ${phase.name} '
          'phase — a time for ${phase.description.toLowerCase()} '
          'Start your first session whenever you\'re ready.';
    }

    final totalSessions = log.length;
    final coaches = <String>{};
    double moodBeforeSum = 0;
    double moodAfterSum = 0;
    for (final s in log) {
      coaches.add(s['coachId'] as String);
      moodBeforeSum += (s['moodBefore'] as num).toDouble();
      moodAfterSum += (s['moodAfter'] as num).toDouble();
    }
    final avgBefore = (moodBeforeSum / totalSessions).toStringAsFixed(1);
    final avgAfter = (moodAfterSum / totalSessions).toStringAsFixed(1);

    // Find best coach
    final coachDelta = <String, double>{};
    final coachCount = <String, int>{};
    for (final s in log) {
      final id = s['coachId'] as String;
      final delta = (s['moodAfter'] as num) - (s['moodBefore'] as num);
      coachDelta[id] = (coachDelta[id] ?? 0) + delta.toDouble();
      coachCount[id] = (coachCount[id] ?? 0) + 1;
    }
    String bestCoach = coaches.first;
    double bestDelta = -999;
    for (final entry in coachDelta.entries) {
      final avg = entry.value / (coachCount[entry.key] ?? 1);
      if (avg > bestDelta) {
        bestDelta = avg;
        bestCoach = entry.key;
      }
    }
    final coachName = bestCoach.replaceAll('_', ' ').split(' ').map(
      (w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}',
    ).join(' ');

    final weekLabel = week == 1 ? '1 week' : '$week weeks';

    final buffer = StringBuffer()
      ..write('In $weekLabel with AI CoachFlux, you\'ve had $totalSessions ')
      ..write('session${totalSessions == 1 ? '' : 's'} across ${coaches.length} ')
      ..write('coach${coaches.length == 1 ? '' : 'es'}. ')
      ..write('Your average mood shifted from $avgBefore to $avgAfter. ');

    if (bestDelta > 0) {
      buffer.write('$coachName helped you most with mood improvement. ');
    }

    buffer.write('You\'re in the ${phase.name} phase');
    switch (phase.phaseNumber) {
      case 1:
        buffer.write(' — keep building that self-awareness foundation!');
        break;
      case 2:
        buffer.write(' — keep experimenting with different approaches!');
        break;
      case 3:
        buffer.write(' — you\'re going deep. Real change is happening.');
        break;
      case 4:
        buffer.write(' — you\'re integrating everything. Almost there!');
        break;
    }

    return buffer.toString();
  }

  // ──────────────────────────────────────────────
  // MONTHLY REVIEW
  // ──────────────────────────────────────────────

  Future<MonthlyReview> getMonthlyReview() async {
    final log = await _getSessionLog();
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    // Filter to current month
    final monthSessions = log.where((s) {
      final ts = DateTime.parse(s['timestamp'] as String);
      return ts.isAfter(monthStart) || ts.isAtSameMomentAs(monthStart);
    }).toList();

    final totalSessions = monthSessions.length;

    double avgMoodStart = 0;
    double avgMoodEnd = 0;
    final coachUsage = <String, int>{};
    final insights = <String>[];

    if (monthSessions.isNotEmpty) {
      double sumBefore = 0;
      double sumAfter = 0;
      for (final s in monthSessions) {
        sumBefore += (s['moodBefore'] as num).toDouble();
        sumAfter += (s['moodAfter'] as num).toDouble();
        final coach = s['coachId'] as String;
        coachUsage[coach] = (coachUsage[coach] ?? 0) + 1;
        if (s['insight'] != null && (s['insight'] as String).isNotEmpty) {
          insights.add(s['insight'] as String);
        }
      }
      avgMoodStart = sumBefore / totalSessions;
      avgMoodEnd = sumAfter / totalSessions;
    }

    // Generate suggested focus
    String suggestedFocus;
    if (totalSessions == 0) {
      suggestedFocus = 'Start with your first session this month — even one conversation can shift your perspective.';
    } else if (avgMoodEnd < avgMoodStart) {
      suggestedFocus = 'This has been a tough month. Consider focusing on self-compassion and grounding techniques.';
    } else if (coachUsage.length < 2) {
      suggestedFocus = 'Try exploring a different coach to get fresh perspectives on your growth.';
    } else {
      suggestedFocus = 'You\'re making great progress. Deepen your practice with your most effective coach.';
    }

    // Calculate milestones
    int milestones = 0;
    if (totalSessions >= 1) milestones++;
    if (totalSessions >= 5) milestones++;
    if (totalSessions >= 10) milestones++;
    if (coachUsage.length >= 3) milestones++;
    if (avgMoodEnd > avgMoodStart) milestones++;
    if (insights.length >= 3) milestones++;

    // Keep top 5 insights
    final topInsights = insights.length > 5 ? insights.sublist(insights.length - 5) : insights;
    if (topInsights.isEmpty) {
      topInsights.add('Start logging insights after your sessions to track your growth.');
    }

    return MonthlyReview(
      totalSessions: totalSessions,
      avgMoodStart: double.parse(avgMoodStart.toStringAsFixed(1)),
      avgMoodEnd: double.parse(avgMoodEnd.toStringAsFixed(1)),
      coachUsage: coachUsage,
      topInsights: topInsights,
      suggestedFocus: suggestedFocus,
      milestonesReached: milestones,
    );
  }
}

// ══════════════════════════════════════════════
// DATA MODELS
// ══════════════════════════════════════════════

class GrowthPhase {
  final int phaseNumber;
  final String name;
  final String description;
  final int currentWeek;
  final List<String> weeklyGoals;
  final double progress;

  const GrowthPhase({
    required this.phaseNumber,
    required this.name,
    required this.description,
    required this.currentWeek,
    required this.weeklyGoals,
    required this.progress,
  });

  Map<String, dynamic> toJson() => {
        'phaseNumber': phaseNumber,
        'name': name,
        'description': description,
        'currentWeek': currentWeek,
        'weeklyGoals': weeklyGoals,
        'progress': progress,
      };

  factory GrowthPhase.fromJson(Map<String, dynamic> json) => GrowthPhase(
        phaseNumber: json['phaseNumber'] as int,
        name: json['name'] as String,
        description: json['description'] as String,
        currentWeek: json['currentWeek'] as int,
        weeklyGoals: List<String>.from(json['weeklyGoals'] as List),
        progress: (json['progress'] as num).toDouble(),
      );
}

class DailyChallenge {
  final String title;
  final String description;
  final String coachId;
  final int xpReward;
  final String category;

  const DailyChallenge({
    required this.title,
    required this.description,
    required this.coachId,
    required this.xpReward,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'coachId': coachId,
        'xpReward': xpReward,
        'category': category,
      };

  factory DailyChallenge.fromJson(Map<String, dynamic> json) => DailyChallenge(
        title: json['title'] as String,
        description: json['description'] as String,
        coachId: json['coachId'] as String,
        xpReward: json['xpReward'] as int,
        category: json['category'] as String,
      );
}

class MonthlyReview {
  final int totalSessions;
  final double avgMoodStart;
  final double avgMoodEnd;
  final Map<String, int> coachUsage;
  final List<String> topInsights;
  final String suggestedFocus;
  final int milestonesReached;

  const MonthlyReview({
    required this.totalSessions,
    required this.avgMoodStart,
    required this.avgMoodEnd,
    required this.coachUsage,
    required this.topInsights,
    required this.suggestedFocus,
    required this.milestonesReached,
  });

  Map<String, dynamic> toJson() => {
        'totalSessions': totalSessions,
        'avgMoodStart': avgMoodStart,
        'avgMoodEnd': avgMoodEnd,
        'coachUsage': coachUsage,
        'topInsights': topInsights,
        'suggestedFocus': suggestedFocus,
        'milestonesReached': milestonesReached,
      };

  factory MonthlyReview.fromJson(Map<String, dynamic> json) => MonthlyReview(
        totalSessions: json['totalSessions'] as int,
        avgMoodStart: (json['avgMoodStart'] as num).toDouble(),
        avgMoodEnd: (json['avgMoodEnd'] as num).toDouble(),
        coachUsage: Map<String, int>.from(json['coachUsage'] as Map),
        topInsights: List<String>.from(json['topInsights'] as List),
        suggestedFocus: json['suggestedFocus'] as String,
        milestonesReached: json['milestonesReached'] as int,
      );
}
