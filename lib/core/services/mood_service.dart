import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Mood {
  happy('😊', 'Happy', 1.0),
  neutral('😐', 'Neutral', 0.6),
  sad('😔', 'Sad', 0.3),
  angry('😤', 'Angry', 0.2),
  tired('😴', 'Tired', 0.4);

  final String emoji;
  final String label;
  final double score;
  const Mood(this.emoji, this.label, this.score);
}

class MoodEntry {
  final Mood mood;
  final DateTime timestamp;
  final String? coachId;

  MoodEntry({required this.mood, required this.timestamp, this.coachId});

  Map<String, dynamic> toJson() => {
    'mood': mood.name,
    'timestamp': timestamp.toIso8601String(),
    'coachId': coachId,
  };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
    mood: Mood.values.firstWhere((m) => m.name == json['mood'], orElse: () => Mood.neutral),
    timestamp: DateTime.parse(json['timestamp']),
    coachId: json['coachId'],
  );
}

class MoodService {
  static final MoodService _instance = MoodService._();
  factory MoodService() => _instance;
  MoodService._();

  static const _key = 'mood_history';
  final List<MoodEntry> _entries = [];
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _entries.clear();
    for (final s in raw) {
      try {
        _entries.add(MoodEntry.fromJson(jsonDecode(s)));
      } catch (e) {
        debugPrint('MoodService parse error: $e');
      }
    }
    _loaded = true;
  }

  Future<void> record(Mood mood, {String? coachId}) async {
    await _ensureLoaded();
    _entries.add(MoodEntry(mood: mood, timestamp: DateTime.now(), coachId: coachId));
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _entries.map((e) => jsonEncode(e.toJson())).toList());
  }

  Future<List<MoodEntry>> getHistory({int days = 7}) async {
    await _ensureLoaded();
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _entries.where((e) => e.timestamp.isAfter(cutoff)).toList();
  }

  Future<List<double>> last7DaysScores() async {
    final now = DateTime.now();
    final scores = <double>[];
    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final dayEntries = (await getHistory(days: 7))
          .where((e) => e.timestamp.year == day.year && e.timestamp.month == day.month && e.timestamp.day == day.day)
          .toList();
      if (dayEntries.isEmpty) {
        scores.add(-1); // no data
      } else {
        scores.add(dayEntries.map((e) => e.mood.score).reduce((a, b) => a + b) / dayEntries.length);
      }
    }
    return scores;
  }

  Mood? get currentSessionMood => _entries.isEmpty ? null : _entries.last.mood;

  String getCoachToneModifier(Mood mood) {
    switch (mood) {
      case Mood.happy:
        return 'The user is feeling happy and energized. Be encouraging, set ambitious goals, and match their positive energy. Push them to dream bigger.';
      case Mood.neutral:
        return 'The user is feeling neutral. Be balanced and structured. Provide clear frameworks and actionable steps.';
      case Mood.sad:
        return 'The user is feeling sad. Be empathetic, gentle, and deeply supportive. Validate their feelings before offering solutions. Use warm language.';
      case Mood.angry:
        return 'The user is feeling frustrated or angry. Be calming and offer perspective-shifting insights. Help them channel this energy productively. Don\'t dismiss their feelings.';
      case Mood.tired:
        return 'The user is feeling tired or low-energy. Keep messages short and light. Be motivational but don\'t overwhelm. Suggest small, easy wins.';
    }
  }
}
