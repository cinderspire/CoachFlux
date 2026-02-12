import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Achievement {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int targetValue;
  final int xp;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.targetValue,
    required this.xp,
  });
}

class AchievementProgress {
  final String achievementId;
  int currentValue;
  bool unlocked;
  DateTime? unlockedAt;

  AchievementProgress({
    required this.achievementId,
    this.currentValue = 0,
    this.unlocked = false,
    this.unlockedAt,
  });

  double get progress => unlocked ? 1.0 : (currentValue / _getTarget(achievementId)).clamp(0.0, 1.0);

  static int _getTarget(String id) {
    final a = AchievementService.allAchievements.firstWhere(
      (a) => a.id == id,
      orElse: () => const Achievement(id: '', name: '', description: '', emoji: '', targetValue: 1, xp: 0),
    );
    return a.targetValue;
  }

  Map<String, dynamic> toJson() => {
    'achievementId': achievementId,
    'currentValue': currentValue,
    'unlocked': unlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
  };

  factory AchievementProgress.fromJson(Map<String, dynamic> json) => AchievementProgress(
    achievementId: json['achievementId'],
    currentValue: json['currentValue'] ?? 0,
    unlocked: json['unlocked'] ?? false,
    unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
  );
}

class AchievementService {
  static final AchievementService _instance = AchievementService._();
  factory AchievementService() => _instance;
  AchievementService._();

  static const _key = 'achievement_progress';
  final Map<String, AchievementProgress> _progress = {};
  bool _loaded = false;

  static const List<Achievement> allAchievements = [
    Achievement(id: 'first_session', name: 'First Session', description: 'Complete your first coaching session', emoji: '🎉', targetValue: 1, xp: 50),
    Achievement(id: 'seven_day_streak', name: '7-Day Streak', description: 'Chat with a coach 7 days in a row', emoji: '🔥', targetValue: 7, xp: 150),
    Achievement(id: 'mood_master', name: 'Mood Master', description: 'Track 30 moods', emoji: '🎭', targetValue: 30, xp: 200),
    Achievement(id: 'deep_diver', name: 'Deep Diver', description: 'Send 50+ messages in one session', emoji: '🤿', targetValue: 50, xp: 200),
    Achievement(id: 'all_coaches', name: 'All Coaches', description: 'Talk to every free coach', emoji: '🌟', targetValue: 6, xp: 300),
    Achievement(id: 'growth_spurt', name: 'Growth Spurt', description: 'Mood improved 3 days in a row', emoji: '🌱', targetValue: 3, xp: 150),
    Achievement(id: 'night_owl', name: 'Night Owl', description: 'Start a session after 10pm', emoji: '🦉', targetValue: 1, xp: 75),
    Achievement(id: 'early_bird', name: 'Early Bird', description: 'Start a session before 7am', emoji: '🐦', targetValue: 1, xp: 75),
    Achievement(id: 'vulnerability', name: 'Vulnerability', description: 'Share 3+ sad moods', emoji: '💙', targetValue: 3, xp: 100),
    Achievement(id: 'wisdom_collector', name: 'Wisdom Collector', description: 'Complete 10+ sessions', emoji: '📚', targetValue: 10, xp: 250),
    Achievement(id: 'chemistry_master', name: 'Chemistry Master', description: 'Reach 90%+ chemistry with a coach', emoji: '⚗️', targetValue: 90, xp: 350),
    Achievement(id: 'custom_coach', name: 'Custom Coach', description: 'Create your own coach', emoji: '🛠️', targetValue: 1, xp: 100),
  ];

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in map.entries) {
        try {
          _progress[entry.key] = AchievementProgress.fromJson(entry.value);
        } catch (e) {
          debugPrint('AchievementService parse error: $e');
        }
      }
    }
    _loaded = true;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(
      _progress.map((k, v) => MapEntry(k, v.toJson())),
    ));
  }

  Future<AchievementProgress> getProgress(String achievementId) async {
    await _ensureLoaded();
    return _progress[achievementId] ?? AchievementProgress(achievementId: achievementId);
  }

  Future<List<AchievementProgress>> getAllProgress() async {
    await _ensureLoaded();
    return allAchievements.map((a) {
      return _progress[a.id] ?? AchievementProgress(achievementId: a.id);
    }).toList();
  }

  /// Increment progress and return true if newly unlocked
  Future<bool> increment(String achievementId, {int amount = 1}) async {
    await _ensureLoaded();
    final p = _progress.putIfAbsent(achievementId, () => AchievementProgress(achievementId: achievementId));
    if (p.unlocked) return false;
    p.currentValue += amount;
    final target = allAchievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => const Achievement(id: '', name: '', description: '', emoji: '', targetValue: 1, xp: 0),
    ).targetValue;
    if (p.currentValue >= target) {
      p.unlocked = true;
      p.unlockedAt = DateTime.now();
      await _save();
      return true;
    }
    await _save();
    return false;
  }

  /// Set progress to exact value
  Future<bool> setProgress(String achievementId, int value) async {
    await _ensureLoaded();
    final p = _progress.putIfAbsent(achievementId, () => AchievementProgress(achievementId: achievementId));
    if (p.unlocked) return false;
    p.currentValue = value;
    final target = allAchievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => const Achievement(id: '', name: '', description: '', emoji: '', targetValue: 1, xp: 0),
    ).targetValue;
    if (p.currentValue >= target) {
      p.unlocked = true;
      p.unlockedAt = DateTime.now();
      await _save();
      return true;
    }
    await _save();
    return false;
  }

  Future<int> get totalXP async {
    await _ensureLoaded();
    int xp = 0;
    for (final a in allAchievements) {
      final p = _progress[a.id];
      if (p != null && p.unlocked) xp += a.xp;
    }
    return xp;
  }

  Future<int> get level async {
    final xp = await totalXP;
    // Every 200 XP = 1 level
    return (xp / 200).floor() + 1;
  }

  Future<int> get unlockedCount async {
    await _ensureLoaded();
    return _progress.values.where((p) => p.unlocked).length;
  }
}
