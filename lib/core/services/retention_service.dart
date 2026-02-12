import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SessionRecord {
  final String coachId;
  final String topic;
  final int durationMinutes;
  final int moodBefore;
  final int moodAfter;
  final DateTime timestamp;

  SessionRecord({
    required this.coachId,
    required this.topic,
    required this.durationMinutes,
    required this.moodBefore,
    required this.moodAfter,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'coachId': coachId,
        'topic': topic,
        'durationMinutes': durationMinutes,
        'moodBefore': moodBefore,
        'moodAfter': moodAfter,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SessionRecord.fromJson(Map<String, dynamic> json) => SessionRecord(
        coachId: json['coachId'] as String,
        topic: json['topic'] as String,
        durationMinutes: json['durationMinutes'] as int,
        moodBefore: json['moodBefore'] as int,
        moodAfter: json['moodAfter'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

class WeeklyInsights {
  final int sessionsThisWeek;
  final double avgMoodBefore;
  final double avgMoodAfter;
  final String? topCoachId;
  final int currentStreak;
  final int totalSessions;
  final String motivationalMessage;

  WeeklyInsights({
    required this.sessionsThisWeek,
    required this.avgMoodBefore,
    required this.avgMoodAfter,
    this.topCoachId,
    required this.currentStreak,
    required this.totalSessions,
    required this.motivationalMessage,
  });

  Map<String, dynamic> toJson() => {
        'sessionsThisWeek': sessionsThisWeek,
        'avgMoodBefore': avgMoodBefore,
        'avgMoodAfter': avgMoodAfter,
        'topCoachId': topCoachId,
        'currentStreak': currentStreak,
        'totalSessions': totalSessions,
        'motivationalMessage': motivationalMessage,
      };

  factory WeeklyInsights.fromJson(Map<String, dynamic> json) => WeeklyInsights(
        sessionsThisWeek: json['sessionsThisWeek'] as int,
        avgMoodBefore: (json['avgMoodBefore'] as num).toDouble(),
        avgMoodAfter: (json['avgMoodAfter'] as num).toDouble(),
        topCoachId: json['topCoachId'] as String?,
        currentStreak: json['currentStreak'] as int,
        totalSessions: json['totalSessions'] as int,
        motivationalMessage: json['motivationalMessage'] as String,
      );
}

class RetentionService {
  static final RetentionService _instance = RetentionService._();
  factory RetentionService() => _instance;
  RetentionService._();

  static const String _keyCurrentStreak = 'retention_current_streak';
  static const String _keyLongestStreak = 'retention_longest_streak';
  static const String _keyLastActiveDate = 'retention_last_active_date';
  static const String _keySessions = 'retention_sessions';
  static const String _keyMilestones = 'retention_milestones';

  // === STREAK SYSTEM ===

  Future<void> recordDailyVisit() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateOnly(DateTime.now());
    final lastActiveStr = prefs.getString(_keyLastActiveDate);
    int currentStreak = prefs.getInt(_keyCurrentStreak) ?? 0;
    int longestStreak = prefs.getInt(_keyLongestStreak) ?? 0;

    if (lastActiveStr != null) {
      final lastActive = DateTime.parse(lastActiveStr);
      final diff = today.difference(lastActive).inDays;

      if (diff == 0) {
        return; // Already recorded today
      } else if (diff == 1) {
        currentStreak += 1;
      } else {
        currentStreak = 1;
      }
    } else {
      currentStreak = 1;
    }

    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    await prefs.setInt(_keyCurrentStreak, currentStreak);
    await prefs.setInt(_keyLongestStreak, longestStreak);
    await prefs.setString(_keyLastActiveDate, today.toIso8601String());
  }

  Future<Map<String, dynamic>> getStreakData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'current': prefs.getInt(_keyCurrentStreak) ?? 0,
      'longest': prefs.getInt(_keyLongestStreak) ?? 0,
      'lastActive': prefs.getString(_keyLastActiveDate),
    };
  }

  // === SESSION MEMORY ===

  Future<List<SessionRecord>> _getAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keySessions);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SessionRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveSessions(List<SessionRecord> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _keySessions, jsonEncode(sessions.map((s) => s.toJson()).toList()));
  }

  Future<void> recordSession(String coachId, String topic,
      int durationMinutes, int moodBefore, int moodAfter) async {
    final sessions = await _getAllSessions();
    sessions.add(SessionRecord(
      coachId: coachId,
      topic: topic,
      durationMinutes: durationMinutes,
      moodBefore: moodBefore,
      moodAfter: moodAfter,
      timestamp: DateTime.now(),
    ));
    await _saveSessions(sessions);
  }

  Future<List<SessionRecord>> getCoachHistory(String coachId) async {
    final sessions = await _getAllSessions();
    return sessions.where((s) => s.coachId == coachId).toList();
  }

  Future<int> getTotalSessions() async {
    final sessions = await _getAllSessions();
    return sessions.length;
  }

  Future<double> getAverageMoodImprovement() async {
    final sessions = await _getAllSessions();
    if (sessions.isEmpty) return 0.0;
    double total = 0;
    for (final s in sessions) {
      total += (s.moodAfter - s.moodBefore);
    }
    return total / sessions.length;
  }

  // === MILESTONE SYSTEM ===

  static const List<String> _allMilestones = [
    'first_session',
    'streak_7',
    'streak_30',
    'streak_100',
    'sessions_10',
    'sessions_50',
    'sessions_100',
    'mood_improved_5x',
    'all_coaches_tried',
    'first_technique',
    'journal_7_days',
    'transformation_50',
  ];

  Future<List<String>> getUnlockedMilestones() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_keyMilestones);
    return raw ?? [];
  }

  Future<List<String>> checkAndUnlockMilestones() async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = (prefs.getStringList(_keyMilestones) ?? []).toSet();
    final newlyUnlocked = <String>[];

    final sessions = await _getAllSessions();
    final streak = prefs.getInt(_keyCurrentStreak) ?? 0;
    final totalSessions = sessions.length;

    // first_session
    if (!unlocked.contains('first_session') && totalSessions >= 1) {
      newlyUnlocked.add('first_session');
    }

    // streak milestones
    if (!unlocked.contains('streak_7') && streak >= 7) {
      newlyUnlocked.add('streak_7');
    }
    if (!unlocked.contains('streak_30') && streak >= 30) {
      newlyUnlocked.add('streak_30');
    }
    if (!unlocked.contains('streak_100') && streak >= 100) {
      newlyUnlocked.add('streak_100');
    }

    // session count milestones
    if (!unlocked.contains('sessions_10') && totalSessions >= 10) {
      newlyUnlocked.add('sessions_10');
    }
    if (!unlocked.contains('sessions_50') && totalSessions >= 50) {
      newlyUnlocked.add('sessions_50');
    }
    if (!unlocked.contains('sessions_100') && totalSessions >= 100) {
      newlyUnlocked.add('sessions_100');
    }

    // mood_improved_5x: at least 5 sessions with positive mood change
    if (!unlocked.contains('mood_improved_5x')) {
      final improved =
          sessions.where((s) => s.moodAfter > s.moodBefore).length;
      if (improved >= 5) newlyUnlocked.add('mood_improved_5x');
    }

    // all_coaches_tried: sessions with at least 5 distinct coaches
    if (!unlocked.contains('all_coaches_tried')) {
      final coaches = sessions.map((s) => s.coachId).toSet();
      if (coaches.length >= 5) newlyUnlocked.add('all_coaches_tried');
    }

    // transformation_50: total mood improvement points >= 50
    if (!unlocked.contains('transformation_50')) {
      double totalImprovement = 0;
      for (final s in sessions) {
        final diff = s.moodAfter - s.moodBefore;
        if (diff > 0) totalImprovement += diff;
      }
      if (totalImprovement >= 50) newlyUnlocked.add('transformation_50');
    }

    // first_technique and journal_7_days are event-driven; provide unlock helpers
    // They can be triggered externally via unlockMilestone()

    if (newlyUnlocked.isNotEmpty) {
      unlocked.addAll(newlyUnlocked);
      await prefs.setStringList(_keyMilestones, unlocked.toList());
    }

    return newlyUnlocked;
  }

  /// Manually unlock a milestone (for event-driven milestones like first_technique, journal_7_days).
  Future<bool> unlockMilestone(String milestone) async {
    if (!_allMilestones.contains(milestone)) return false;
    final prefs = await SharedPreferences.getInstance();
    final unlocked = (prefs.getStringList(_keyMilestones) ?? []).toSet();
    if (unlocked.contains(milestone)) return false;
    unlocked.add(milestone);
    await prefs.setStringList(_keyMilestones, unlocked.toList());
    return true;
  }

  // === WEEKLY INSIGHTS ===

  Future<WeeklyInsights> getWeeklyInsights() async {
    final sessions = await _getAllSessions();
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final weeklySessions =
        sessions.where((s) => s.timestamp.isAfter(weekAgo)).toList();

    double avgBefore = 0;
    double avgAfter = 0;
    if (weeklySessions.isNotEmpty) {
      avgBefore = weeklySessions.map((s) => s.moodBefore).reduce((a, b) => a + b) /
          weeklySessions.length;
      avgAfter = weeklySessions.map((s) => s.moodAfter).reduce((a, b) => a + b) /
          weeklySessions.length;
    }

    // Find top coach this week
    String? topCoach;
    if (weeklySessions.isNotEmpty) {
      final counts = <String, int>{};
      for (final s in weeklySessions) {
        counts[s.coachId] = (counts[s.coachId] ?? 0) + 1;
      }
      topCoach = counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    }

    final streakData = await getStreakData();
    final currentStreak = streakData['current'] as int;
    final totalSessions = sessions.length;

    String message;
    if (weeklySessions.isEmpty) {
      message = "It's a new week — a perfect time to reconnect with yourself.";
    } else if (avgAfter > avgBefore) {
      message =
          "Your mood improved this week! Keep nurturing that positive momentum. 🌱";
    } else if (weeklySessions.length >= 5) {
      message =
          "Amazing dedication — ${weeklySessions.length} sessions this week! You're building something powerful. 💪";
    } else {
      message =
          "Every session counts. You showed up ${weeklySessions.length} time${weeklySessions.length == 1 ? '' : 's'} this week — that's what matters.";
    }

    return WeeklyInsights(
      sessionsThisWeek: weeklySessions.length,
      avgMoodBefore: avgBefore,
      avgMoodAfter: avgAfter,
      topCoachId: topCoach,
      currentStreak: currentStreak,
      totalSessions: totalSessions,
      motivationalMessage: message,
    );
  }

  // === RE-ENGAGEMENT ===

  Future<int> getDaysSinceLastVisit() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActiveStr = prefs.getString(_keyLastActiveDate);
    if (lastActiveStr == null) return -1;
    final lastActive = DateTime.parse(lastActiveStr);
    return _dateOnly(DateTime.now()).difference(lastActive).inDays;
  }

  Future<String> getWelcomeBackMessage() async {
    final days = await getDaysSinceLastVisit();
    if (days <= 0) {
      return "Welcome back! You're on a roll 🔥";
    } else if (days <= 2) {
      return "Good to see you again! Let's pick up where we left off.";
    } else if (days <= 7) {
      return "I've missed our conversations. Ready to reconnect?";
    } else if (days <= 30) {
      return "Welcome back! It takes courage to return. I'm glad you did. 💜";
    } else {
      return "Every journey has pauses. What matters is you're here now. Let's start fresh.";
    }
  }

  // === COACH RELATIONSHIP SCORE ===

  Future<int> getRelationshipScore(String coachId) async {
    final sessions = await getCoachHistory(coachId);
    if (sessions.isEmpty) return 0;

    // Session count component (0-40): logarithmic scaling
    final sessionScore = (sessions.length.clamp(0, 100) / 100 * 40).round();

    // Consistency component (0-30): how regularly they visit this coach
    double consistencyScore = 0;
    if (sessions.length >= 2) {
      sessions.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final totalDays = sessions.last.timestamp
              .difference(sessions.first.timestamp)
              .inDays +
          1;
      final density = sessions.length / totalDays;
      consistencyScore = (density.clamp(0.0, 1.0) * 30);
    } else {
      consistencyScore = 5;
    }

    // Mood improvement component (0-30)
    double moodScore = 0;
    int improvedCount = 0;
    double totalImprovement = 0;
    for (final s in sessions) {
      final diff = s.moodAfter - s.moodBefore;
      if (diff > 0) {
        improvedCount++;
        totalImprovement += diff;
      }
    }
    if (sessions.isNotEmpty) {
      final improvementRate = improvedCount / sessions.length;
      final avgImprovement =
          totalImprovement / (improvedCount > 0 ? improvedCount : 1);
      moodScore = (improvementRate * 15) + ((avgImprovement / 10).clamp(0, 1) * 15);
    }

    return (sessionScore + consistencyScore + moodScore).round().clamp(0, 100);
  }

  Future<String?> getFavoriteCoach() async {
    final sessions = await _getAllSessions();
    if (sessions.isEmpty) return null;

    final counts = <String, int>{};
    for (final s in sessions) {
      counts[s.coachId] = (counts[s.coachId] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  // === HELPERS ===

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  // === COMEBACK SYSTEM ===

  Future<ComebackMessage?> checkComeback() async {
    final days = await getDaysSinceLastVisit();
    if (days <= 0) return null;
    final message = await getWelcomeBackMessage();
    String title;
    if (days <= 2) {
      title = 'Welcome Back!';
    } else if (days <= 7) {
      title = 'We Missed You!';
    } else if (days <= 30) {
      title = 'It\'s Been a While 💜';
    } else {
      title = 'A Fresh Start 🌱';
    }
    return ComebackMessage(title: title, message: message, daysAway: days);
  }

  // === WEEKLY CHALLENGE SYSTEM ===

  static const String _keyChallengeStart = 'retention_challenge_start';
  static const String _keyChallengeDays = 'retention_challenge_days';
  static const String _keyChallengeIndex = 'retention_challenge_index';

  static const List<Map<String, String>> _challenges = [
    {'title': 'Mindful Check-In', 'desc': 'Start each day with a 2-minute mood check-in for 7 days.'},
    {'title': 'Gratitude Sprint', 'desc': 'Write down 3 things you\'re grateful for each day this week.'},
    {'title': 'Coach Explorer', 'desc': 'Try a session with a different coach each day.'},
    {'title': 'Mood Tracker', 'desc': 'Log your mood before and after every session this week.'},
    {'title': 'Reflection Week', 'desc': 'Spend 5 minutes journaling after each coaching session.'},
  ];

  Future<WeeklyChallenge?> getCurrentChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final startStr = prefs.getString(_keyChallengeStart);
    final now = DateTime.now();

    int index = prefs.getInt(_keyChallengeIndex) ?? 0;
    List<String> completedDays = prefs.getStringList(_keyChallengeDays) ?? [];

    if (startStr == null || now.difference(DateTime.parse(startStr)).inDays >= 7) {
      // Start new challenge
      if (startStr != null) index = (index + 1) % _challenges.length;
      await prefs.setString(_keyChallengeStart, _dateOnly(now).toIso8601String());
      await prefs.setInt(_keyChallengeIndex, index);
      await prefs.setStringList(_keyChallengeDays, []);
      completedDays = [];
    }

    final challenge = _challenges[index];
    final start = DateTime.parse(prefs.getString(_keyChallengeStart)!);

    return WeeklyChallenge(
      title: challenge['title']!,
      description: challenge['desc']!,
      startDate: start,
      completedDays: completedDays.length,
      daysRequired: 7,
    );
  }

  Future<void> markChallengeDayComplete() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateOnly(DateTime.now()).toIso8601String();
    final days = prefs.getStringList(_keyChallengeDays) ?? [];
    if (!days.contains(today)) {
      days.add(today);
      await prefs.setStringList(_keyChallengeDays, days);
    }
  }

  // === COMPATIBILITY OVERLOADS ===

  /// No-arg version for quick session logging from home screen.
  Future<void> recordSessionSimple() async {
    await recordSession('general', 'app_session', 0, 5, 5);
  }

  /// Named-parameter version for milestone checking from home screen.
  Future<List<String>> checkAndUnlockMilestonesCompat({int sessionCount = 0}) async {
    return checkAndUnlockMilestones();
  }
}

class ComebackMessage {
  final String title;
  final String message;
  final int daysAway;

  ComebackMessage({required this.title, required this.message, required this.daysAway});
}

class WeeklyChallenge {
  final String title;
  final String description;
  final DateTime startDate;
  final int completedDays;
  final int daysRequired;
  final int xpReward;

  WeeklyChallenge({
    required this.title,
    required this.description,
    required this.startDate,
    required this.completedDays,
    required this.daysRequired,
    this.xpReward = 50,
  });

  double get progress => daysRequired > 0 ? (completedDays / daysRequired).clamp(0.0, 1.0) : 0.0;
  bool get isCompleted => completedDays >= daysRequired;
}
