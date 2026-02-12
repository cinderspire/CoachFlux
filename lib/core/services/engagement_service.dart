import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles all behavioral psychology hooks:
/// Streak tracking, relationship levels, variable rewards,
/// commitment goals, social proof data.
class EngagementService {
  static final EngagementService _instance = EngagementService._();
  factory EngagementService() => _instance;
  EngagementService._();

  bool _loaded = false;
  final _rand = Random();

  // Streak
  int _currentStreak = 0;
  int _bestStreak = 0;
  List<String> _activeDays = []; // ISO date strings

  // Commitment
  String? _selectedGoal;
  int _commitmentDay = 0;
  static const int commitmentTotalDays = 21;

  // Relationship levels per coach
  Map<String, int> _coachMessageCounts = {};

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _currentStreak = prefs.getInt('streak_current') ?? 0;
    _bestStreak = prefs.getInt('streak_best') ?? 0;
    _activeDays = prefs.getStringList('streak_days') ?? [];
    _selectedGoal = prefs.getString('commitment_goal');
    _commitmentDay = prefs.getInt('commitment_day') ?? 0;
    final raw = prefs.getString('coach_msg_counts');
    if (raw != null) {
      _coachMessageCounts = Map<String, int>.from(jsonDecode(raw));
    }
    _recalculateStreak();
    _loaded = true;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('streak_current', _currentStreak);
    await prefs.setInt('streak_best', _bestStreak);
    await prefs.setStringList('streak_days', _activeDays);
    if (_selectedGoal != null) await prefs.setString('commitment_goal', _selectedGoal!);
    await prefs.setInt('commitment_day', _commitmentDay);
    await prefs.setString('coach_msg_counts', jsonEncode(_coachMessageCounts));
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _recalculateStreak() {
    if (_activeDays.isEmpty) {
      _currentStreak = 0;
      return;
    }
    final today = _dateKey(DateTime.now());
    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));

    if (!_activeDays.contains(today) && !_activeDays.contains(yesterday)) {
      _currentStreak = 0;
      return;
    }

    int streak = 0;
    var check = DateTime.now();
    // If today not logged yet, start from yesterday
    if (!_activeDays.contains(_dateKey(check))) {
      check = check.subtract(const Duration(days: 1));
    }
    while (_activeDays.contains(_dateKey(check))) {
      streak++;
      check = check.subtract(const Duration(days: 1));
    }
    _currentStreak = streak;
    if (_currentStreak > _bestStreak) _bestStreak = _currentStreak;
  }

  // === PUBLIC API ===

  Future<int> get currentStreak async {
    await _ensureLoaded();
    return _currentStreak;
  }

  Future<int> get bestStreak async {
    await _ensureLoaded();
    return _bestStreak;
  }

  Future<bool> get isTodayActive async {
    await _ensureLoaded();
    return _activeDays.contains(_dateKey(DateTime.now()));
  }

  Future<bool> get isStreakAtRisk async {
    await _ensureLoaded();
    final today = _dateKey(DateTime.now());
    return _currentStreak > 0 && !_activeDays.contains(today);
  }

  Future<void> recordActivity() async {
    await _ensureLoaded();
    final today = _dateKey(DateTime.now());
    if (!_activeDays.contains(today)) {
      _activeDays.add(today);
      // Keep only last 90 days
      if (_activeDays.length > 90) _activeDays.removeAt(0);
      _recalculateStreak();
      // Advance commitment day
      if (_selectedGoal != null) {
        _commitmentDay = (_commitmentDay + 1).clamp(0, commitmentTotalDays);
      }
      await _save();
    }
  }

  // --- ATTACHMENT THEORY: Relationship levels ---

  Future<int> getCoachMessageCount(String coachId) async {
    await _ensureLoaded();
    return _coachMessageCounts[coachId] ?? 0;
  }

  Future<void> incrementCoachMessages(String coachId) async {
    await _ensureLoaded();
    _coachMessageCounts[coachId] = (_coachMessageCounts[coachId] ?? 0) + 1;
    await _save();
  }

  /// Returns relationship level info based on message count
  RelationshipLevel getRelationshipLevel(int messageCount) {
    if (messageCount >= 50) {
      return RelationshipLevel(
        level: 5,
        title: 'Soul Bond',
        description: 'An unbreakable connection 💫',
        emoji: '💫',
      );
    } else if (messageCount >= 25) {
      return RelationshipLevel(
        level: 4,
        title: 'Deep Trust',
        description: 'has formed a deep bond with you',
        emoji: '💜',
      );
    } else if (messageCount >= 10) {
      return RelationshipLevel(
        level: 3,
        title: 'Special Bond',
        description: 'has formed a special bond with you',
        emoji: '💜',
      );
    } else if (messageCount >= 3) {
      return RelationshipLevel(
        level: 2,
        title: 'Getting to Know You',
        description: 'is getting to know you...',
        emoji: '🌱',
      );
    } else {
      return RelationshipLevel(
        level: 1,
        title: 'New Acquaintance',
        description: 'is ready to listen',
        emoji: '👋',
      );
    }
  }

  // --- VARIABLE REWARD: Surprise insights ---

  String generateInsight(String coachName, {String? userMessage}) {
    final insights = [
      'I noticed something about you: you express yourself with real clarity. That\'s a superpower 💎',
      'Today\'s insight: You showed resilience in how you approached that. Don\'t underestimate yourself 💪',
      'You have a pattern of pushing through discomfort — that\'s rare and valuable 🔥',
      'Here\'s what I see: you\'re someone who cares deeply about growth. That puts you ahead of 95% of people 📈',
      'Something special about our chat today: you asked the right questions. That matters more than having all the answers ✨',
      'Your self-awareness is remarkable. Most people don\'t reflect this deeply 🪞',
      'I see real emotional intelligence in how you process things. That\'s your edge 🧠',
      'Today you showed courage by being honest about what\'s hard. That\'s where breakthroughs happen 🌊',
      'Fun fact: people who seek coaching are 73% more likely to achieve their goals. You\'re already winning 🏆',
      'Your consistency tells me something: you\'re building something lasting, not chasing quick fixes 🌱',
    ];
    return insights[_rand.nextInt(insights.length)];
  }

  // --- SOCIAL PROOF: Mock engagement data ---

  SocialProofData getSocialProof(String coachId) {
    // Deterministic-ish based on coachId hash so it's consistent per coach
    final hash = coachId.hashCode.abs();
    final weeklyUsers = 1200 + (hash % 3000);
    final topics = [
      ['Career transitions', 'Work-life balance', 'Leadership skills'],
      ['Morning routines', 'Deep work habits', 'Digital detox'],
      ['Stress management', 'Emotional regulation', 'Self-compassion'],
      ['Goal setting', 'Accountability', 'Motivation'],
      ['Creative blocks', 'Side projects', 'Finding purpose'],
    ];
    final topicSet = topics[hash % topics.length];
    return SocialProofData(
      weeklyUsers: weeklyUsers,
      topTopic: topicSet[0],
      trending: topicSet[1],
    );
  }

  // --- COMMITMENT ESCALATION ---

  Future<void> setCommitmentGoal(String goal) async {
    await _ensureLoaded();
    _selectedGoal = goal;
    _commitmentDay = 0;
    await _save();
  }

  Future<String?> get commitmentGoal async {
    await _ensureLoaded();
    return _selectedGoal;
  }

  Future<int> get commitmentDayNumber async {
    await _ensureLoaded();
    return _commitmentDay;
  }

  Future<double> get commitmentProgress async {
    await _ensureLoaded();
    if (_selectedGoal == null) return 0;
    return (_commitmentDay / commitmentTotalDays).clamp(0.0, 1.0);
  }

  // --- PEAK-END RULE: Session summary ---

  SessionSummary generateSessionSummary(String coachName, int messageCount, String? lastUserMessage) {
    final quotes = [
      '"The secret of getting ahead is getting started." — Mark Twain',
      '"Small daily improvements are the key to staggering long-term results."',
      '"You don\'t have to be great to start, but you have to start to be great."',
      '"Progress is impossible without change."',
      '"The best time to plant a tree was 20 years ago. The second best time is now."',
      '"Consistency is the mother of mastery."',
      '"What you do every day matters more than what you do once in a while."',
      '"Believe you can and you\'re halfway there." — Theodore Roosevelt',
    ];
    final summaries = [
      'You explored new perspectives and showed real openness to growth.',
      'Great session — you identified clear next steps to move forward.',
      'You dug deep today. That kind of honesty accelerates everything.',
      'Productive conversation — you\'re building momentum.',
      'You showed up and did the work. That\'s what matters most.',
    ];

    return SessionSummary(
      messageCount: messageCount,
      summary: summaries[_rand.nextInt(summaries.length)],
      quote: quotes[_rand.nextInt(quotes.length)],
      coachName: coachName,
    );
  }

  // --- WISDOM CARDS: Collectible insights ---

  static const _wisdoms = [
    'Growth isn\'t about speed — it\'s about direction.',
    'The questions you ask reveal more than the answers you seek.',
    'Discomfort is not a stop sign — it\'s a growth signal.',
    'Small wins compound into transformative change.',
    'Your inner dialogue shapes your outer reality.',
    'Rest is not the opposite of productivity — it\'s the foundation.',
    'Vulnerability is not weakness — it\'s the birthplace of innovation.',
    'The goal isn\'t perfection. It\'s progress with intention.',
    'What you practice consistently becomes who you are.',
    'Clarity comes from action, not thought alone.',
    'Your energy is your most valuable currency. Invest wisely.',
    'The best version of you isn\'t found — it\'s built, day by day.',
  ];

  String getWisdom(int sessionCount) {
    return _wisdoms[(sessionCount - 1) % _wisdoms.length];
  }

  int get totalWisdomCards => _wisdoms.length;

  // --- WEEKLY REFLECTION ---

  Future<WeeklyReflection> getWeeklyReflection() async {
    await _ensureLoaded();
    final totalSessions = _coachMessageCounts.values.fold<int>(0, (a, b) => a + b);
    final coachesUsed = _coachMessageCounts.keys.length;
    return WeeklyReflection(
      totalSessions: totalSessions,
      coachesUsed: coachesUsed,
      streak: _currentStreak,
      bestStreak: _bestStreak,
    );
  }

  // --- COACH NUDGE MESSAGES ---

  String? getCoachNudge(String coachName) {
    final hour = DateTime.now().hour;
    if (hour < 8 || hour > 22) return null; // respect quiet hours

    final nudges = [
      'Hey! Haven\'t heard from you today. Everything okay? 💜',
      'I was thinking about our last conversation. Ready to continue? ✨',
      'Just checking in. Your growth matters to me 🌱',
      'Got a quick win for you today — want to hear it? 🎯',
      'Remember that goal we set? Let\'s make progress today 🚀',
    ];
    return '$coachName: ${nudges[_rand.nextInt(nudges.length)]}';
  }

  // --- SESSION COUNT ---

  Future<int> get totalSessionCount async {
    await _ensureLoaded();
    return _coachMessageCounts.values.fold<int>(0, (a, b) => a + b);
  }
}

class WeeklyReflection {
  final int totalSessions;
  final int coachesUsed;
  final int streak;
  final int bestStreak;

  const WeeklyReflection({
    required this.totalSessions,
    required this.coachesUsed,
    required this.streak,
    required this.bestStreak,
  });
}

class RelationshipLevel {
  final int level;
  final String title;
  final String description;
  final String emoji;

  const RelationshipLevel({
    required this.level,
    required this.title,
    required this.description,
    required this.emoji,
  });
}

class SocialProofData {
  final int weeklyUsers;
  final String topTopic;
  final String trending;

  const SocialProofData({
    required this.weeklyUsers,
    required this.topTopic,
    required this.trending,
  });
}

class SessionSummary {
  final int messageCount;
  final String summary;
  final String quote;
  final String coachName;

  const SessionSummary({
    required this.messageCount,
    required this.summary,
    required this.quote,
    required this.coachName,
  });
}
