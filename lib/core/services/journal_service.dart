import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JournalEntry {
  final String id;
  final String coachId;
  final String coachName;
  final String coachEmoji;
  final DateTime timestamp;
  final int messageCount;
  final String? moodLabel;
  final String? moodEmoji;
  final double? moodScore;
  final List<String> keyTopics;
  final String summary;
  final List<String> conversationHighlights;

  JournalEntry({
    required this.id,
    required this.coachId,
    required this.coachName,
    required this.coachEmoji,
    required this.timestamp,
    required this.messageCount,
    this.moodLabel,
    this.moodEmoji,
    this.moodScore,
    this.keyTopics = const [],
    this.summary = '',
    this.conversationHighlights = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'coachId': coachId,
    'coachName': coachName,
    'coachEmoji': coachEmoji,
    'timestamp': timestamp.toIso8601String(),
    'messageCount': messageCount,
    'moodLabel': moodLabel,
    'moodEmoji': moodEmoji,
    'moodScore': moodScore,
    'keyTopics': keyTopics,
    'summary': summary,
    'conversationHighlights': conversationHighlights,
  };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
    id: json['id'],
    coachId: json['coachId'],
    coachName: json['coachName'],
    coachEmoji: json['coachEmoji'],
    timestamp: DateTime.parse(json['timestamp']),
    messageCount: json['messageCount'] ?? 0,
    moodLabel: json['moodLabel'],
    moodEmoji: json['moodEmoji'],
    moodScore: (json['moodScore'] as num?)?.toDouble(),
    keyTopics: List<String>.from(json['keyTopics'] ?? []),
    summary: json['summary'] ?? '',
    conversationHighlights: List<String>.from(json['conversationHighlights'] ?? []),
  );
}

class JournalService {
  static final JournalService _instance = JournalService._();
  factory JournalService() => _instance;
  JournalService._();

  static const _key = 'journal_entries';
  final List<JournalEntry> _entries = [];
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _entries.clear();
    for (final s in raw) {
      try {
        _entries.add(JournalEntry.fromJson(jsonDecode(s)));
      } catch (e) {
        debugPrint('JournalService parse error: $e');
      }
    }
    _loaded = true;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      _entries.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> addEntry(JournalEntry entry) async {
    await _ensureLoaded();
    _entries.insert(0, entry);
    // Keep last 200 entries
    if (_entries.length > 200) _entries.removeLast();
    await _save();
  }

  Future<List<JournalEntry>> getEntries({
    String? coachId,
    String? moodLabel,
    DateTime? from,
    DateTime? to,
  }) async {
    await _ensureLoaded();
    var results = _entries.toList();
    if (coachId != null) {
      results = results.where((e) => e.coachId == coachId).toList();
    }
    if (moodLabel != null) {
      results = results.where((e) => e.moodLabel == moodLabel).toList();
    }
    if (from != null) {
      results = results.where((e) => e.timestamp.isAfter(from)).toList();
    }
    if (to != null) {
      results = results.where((e) => e.timestamp.isBefore(to)).toList();
    }
    return results;
  }

  Future<int> get totalSessions async {
    await _ensureLoaded();
    return _entries.length;
  }

  Future<List<String>> getInsights() async {
    await _ensureLoaded();
    final insights = <String>[];
    if (_entries.isEmpty) return insights;

    // Most used coach
    final coachCounts = <String, int>{};
    for (final e in _entries) {
      coachCounts[e.coachName] = (coachCounts[e.coachName] ?? 0) + 1;
    }
    if (coachCounts.isNotEmpty) {
      final topCoach = coachCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
      insights.add('Your favorite coach is ${topCoach.key} (${topCoach.value} sessions)');
    }

    // Mood patterns
    final moodEntries = _entries.where((e) => e.moodLabel != null).toList();
    if (moodEntries.length >= 3) {
      final moodCounts = <String, int>{};
      for (final e in moodEntries) {
        moodCounts[e.moodLabel!] = (moodCounts[e.moodLabel!] ?? 0) + 1;
      }
      final topMood = moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
      insights.add('You most often feel ${topMood.key.toLowerCase()} before sessions');
    }

    // Day of week pattern
    final dayCounts = <int, int>{};
    for (final e in _entries) {
      dayCounts[e.timestamp.weekday] = (dayCounts[e.timestamp.weekday] ?? 0) + 1;
    }
    if (dayCounts.isNotEmpty) {
      final topDay = dayCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
      const dayNames = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      insights.add('You tend to coach most on ${dayNames[topDay.key]}s');
    }

    // Topic frequency
    final topicCounts = <String, int>{};
    for (final e in _entries) {
      for (final t in e.keyTopics) {
        topicCounts[t] = (topicCounts[t] ?? 0) + 1;
      }
    }
    if (topicCounts.isNotEmpty) {
      final topTopic = topicCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
      insights.add('Your top topic: "${topTopic.key}"');
    }

    // Session frequency
    if (_entries.length >= 2) {
      final first = _entries.last.timestamp;
      final last = _entries.first.timestamp;
      final days = last.difference(first).inDays + 1;
      final avgPerWeek = (_entries.length / (days / 7)).toStringAsFixed(1);
      insights.add('You average $avgPerWeek sessions per week');
    }

    return insights;
  }
}
