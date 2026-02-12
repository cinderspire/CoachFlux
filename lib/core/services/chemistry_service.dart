import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class ChemistryData {
  final String coachId;
  int messageCount;
  List<int> messageLengths;
  List<double> responseTimes; // seconds
  List<double> moodScores;
  int sessionCount;
  DateTime lastSession;

  ChemistryData({
    required this.coachId,
    this.messageCount = 0,
    List<int>? messageLengths,
    List<double>? responseTimes,
    List<double>? moodScores,
    this.sessionCount = 1,
    DateTime? lastSession,
  })  : messageLengths = messageLengths ?? [],
        responseTimes = responseTimes ?? [],
        moodScores = moodScores ?? [],
        lastSession = lastSession ?? DateTime.now();

  double get score {
    if (messageCount < 5) return 0;

    // Message length variety (0-25): std deviation of lengths normalized
    double lengthVariety = 0;
    if (messageLengths.length > 2) {
      final mean = messageLengths.reduce((a, b) => a + b) / messageLengths.length;
      final variance = messageLengths.map((l) => pow(l - mean, 2)).reduce((a, b) => a + b) / messageLengths.length;
      final stdDev = sqrt(variance);
      lengthVariety = (stdDev / (mean + 1)).clamp(0, 1) * 25;
    }

    // Engagement (0-25): based on message count and session count
    final engagement = ((messageCount / 50).clamp(0, 0.5) + (sessionCount / 10).clamp(0, 0.5)) * 25;

    // Mood improvement (0-25)
    double moodImprovement = 12.5; // default middle
    if (moodScores.length >= 2) {
      final first = moodScores.take(moodScores.length ~/ 2).reduce((a, b) => a + b) / (moodScores.length ~/ 2);
      final second = moodScores.skip(moodScores.length ~/ 2).reduce((a, b) => a + b) / (moodScores.length - moodScores.length ~/ 2);
      moodImprovement = ((second - first + 0.5) * 25).clamp(0, 25);
    }

    // Consistency (0-25): session count relative to days
    final daysSinceFirst = DateTime.now().difference(lastSession).inDays.abs() + 1;
    final consistency = ((sessionCount / max(daysSinceFirst, 1)) * 25).clamp(0, 25);

    return (lengthVariety + engagement + moodImprovement + consistency).clamp(0, 100);
  }

  Map<String, dynamic> toJson() => {
    'coachId': coachId,
    'messageCount': messageCount,
    'messageLengths': messageLengths,
    'responseTimes': responseTimes,
    'moodScores': moodScores,
    'sessionCount': sessionCount,
    'lastSession': lastSession.toIso8601String(),
  };

  factory ChemistryData.fromJson(Map<String, dynamic> json) => ChemistryData(
    coachId: json['coachId'],
    messageCount: json['messageCount'] ?? 0,
    messageLengths: List<int>.from(json['messageLengths'] ?? []),
    responseTimes: List<double>.from((json['responseTimes'] ?? []).map((e) => (e as num).toDouble())),
    moodScores: List<double>.from((json['moodScores'] ?? []).map((e) => (e as num).toDouble())),
    sessionCount: json['sessionCount'] ?? 1,
    lastSession: json['lastSession'] != null ? DateTime.parse(json['lastSession']) : DateTime.now(),
  );
}

class ChemistryService {
  static final ChemistryService _instance = ChemistryService._();
  factory ChemistryService() => _instance;
  ChemistryService._();

  static const _key = 'chemistry_data';
  final Map<String, ChemistryData> _data = {};
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in map.entries) {
        _data[entry.key] = ChemistryData.fromJson(entry.value);
      }
    }
    _loaded = true;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_data.map((k, v) => MapEntry(k, v.toJson()))));
  }

  Future<ChemistryData> getChemistry(String coachId) async {
    await _ensureLoaded();
    return _data[coachId] ?? ChemistryData(coachId: coachId);
  }

  Future<void> recordMessage(String coachId, int length, {double? moodScore}) async {
    await _ensureLoaded();
    final data = _data.putIfAbsent(coachId, () => ChemistryData(coachId: coachId));
    data.messageCount++;
    data.messageLengths.add(length);
    if (moodScore != null) data.moodScores.add(moodScore);
    // Keep last 100 entries
    if (data.messageLengths.length > 100) data.messageLengths.removeAt(0);
    if (data.moodScores.length > 100) data.moodScores.removeAt(0);
    await _save();
  }

  Future<void> recordSession(String coachId) async {
    await _ensureLoaded();
    final data = _data.putIfAbsent(coachId, () => ChemistryData(coachId: coachId));
    data.sessionCount++;
    data.lastSession = DateTime.now();
    await _save();
  }

  Future<String?> getTopCoachId() async {
    await _ensureLoaded();
    if (_data.isEmpty) return null;
    String? topId;
    double topScore = 0;
    for (final entry in _data.entries) {
      final s = entry.value.score;
      if (s > topScore) {
        topScore = s;
        topId = entry.key;
      }
    }
    return topScore > 0 ? topId : null;
  }
}
