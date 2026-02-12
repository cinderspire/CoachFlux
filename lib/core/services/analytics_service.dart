import 'dart:convert';
import 'mood_service.dart';
import 'journal_service.dart';

class AnalyticsData {
  final List<double> weeklyMoodScores; // 7 days
  final List<double> monthlyMoodScores; // 30 days
  final Map<String, int> topicCounts;
  final Map<String, int> coachUsageCounts;
  final double personalGrowthScore;
  final List<String> motivationalInsights;
  final int totalSessions;
  final int totalMessages;

  AnalyticsData({
    this.weeklyMoodScores = const [],
    this.monthlyMoodScores = const [],
    this.topicCounts = const {},
    this.coachUsageCounts = const {},
    this.personalGrowthScore = 0,
    this.motivationalInsights = const [],
    this.totalSessions = 0,
    this.totalMessages = 0,
  });
}

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  factory AnalyticsService() => _instance;
  AnalyticsService._();

  Future<AnalyticsData> getAnalytics() async {
    final weeklyScores = await MoodService().last7DaysScores();

    // Monthly scores
    final monthlyHistory = await MoodService().getHistory(days: 30);
    final monthlyScores = <double>[];
    final now = DateTime.now();
    for (int i = 29; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final dayEntries = monthlyHistory.where((e) =>
        e.timestamp.year == day.year &&
        e.timestamp.month == day.month &&
        e.timestamp.day == day.day
      ).toList();
      if (dayEntries.isEmpty) {
        monthlyScores.add(-1);
      } else {
        monthlyScores.add(
          dayEntries.map((e) => e.mood.score).reduce((a, b) => a + b) / dayEntries.length,
        );
      }
    }

    // Journal data
    final entries = await JournalService().getEntries();
    final topicCounts = <String, int>{};
    final coachUsage = <String, int>{};
    int totalMessages = 0;

    for (final e in entries) {
      coachUsage[e.coachName] = (coachUsage[e.coachName] ?? 0) + 1;
      totalMessages += e.messageCount;
      for (final t in e.keyTopics) {
        topicCounts[t] = (topicCounts[t] ?? 0) + 1;
      }
    }

    // Growth score: based on consistency, mood trend, session count
    double growth = 0;
    final validWeekly = weeklyScores.where((s) => s >= 0).toList();
    if (validWeekly.length >= 2) {
      final first = validWeekly.take(validWeekly.length ~/ 2);
      final second = validWeekly.skip(validWeekly.length ~/ 2);
      final firstAvg = first.reduce((a, b) => a + b) / first.length;
      final secondAvg = second.reduce((a, b) => a + b) / second.length;
      growth = ((secondAvg - firstAvg + 0.5) * 50).clamp(0, 100);
    } else {
      growth = entries.length.clamp(0, 50).toDouble();
    }

    // Motivational insights
    final insights = <String>[];
    if (validWeekly.isNotEmpty) {
      // Best day
      final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      double bestScore = -1;
      int bestIdx = 0;
      for (int i = 0; i < weeklyScores.length; i++) {
        if (weeklyScores[i] > bestScore) {
          bestScore = weeklyScores[i];
          bestIdx = i;
        }
      }
      final bestDay = DateTime.now().subtract(Duration(days: 6 - bestIdx));
      insights.add('You tend to feel best on ${dayNames[bestDay.weekday - 1]}s! 🌟');
    }
    if (entries.length >= 5) {
      insights.add('You\'ve completed ${entries.length} sessions — that\'s impressive dedication! 💪');
    }
    if (coachUsage.length >= 3) {
      insights.add('You\'ve explored ${coachUsage.length} different coaches — great diversity! 🌈');
    }
    if (totalMessages > 100) {
      insights.add('$totalMessages messages exchanged — you\'re a deep conversationalist! 💬');
    }
    if (growth > 60) {
      insights.add('Your mood is trending upward! Keep going! 📈');
    }

    return AnalyticsData(
      weeklyMoodScores: weeklyScores,
      monthlyMoodScores: monthlyScores,
      topicCounts: topicCounts,
      coachUsageCounts: coachUsage,
      personalGrowthScore: growth,
      motivationalInsights: insights,
      totalSessions: entries.length,
      totalMessages: totalMessages,
    );
  }

  Future<String> exportData() async {
    final data = await getAnalytics();
    final journal = await JournalService().getEntries();
    final moodHistory = await MoodService().getHistory(days: 365);

    final export = {
      'exportDate': DateTime.now().toIso8601String(),
      'totalSessions': data.totalSessions,
      'totalMessages': data.totalMessages,
      'growthScore': data.personalGrowthScore,
      'coachUsage': data.coachUsageCounts,
      'topTopics': data.topicCounts,
      'journalEntries': journal.map((e) => e.toJson()).toList(),
      'moodHistory': moodHistory.map((e) => e.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(export);
  }
}
