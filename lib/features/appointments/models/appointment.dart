import 'dart:convert';

enum SessionType { textChat, voiceCall, videoCall }

enum SessionDuration {
  short15(15, 4.99, 'appointment_15min'),
  medium30(30, 9.99, 'appointment_30min'),
  long60(60, 19.99, 'appointment_60min');

  final int minutes;
  final double price;
  final String productId;
  const SessionDuration(this.minutes, this.price, this.productId);

  String get label => '$minutes min';
  String get priceLabel => '\$${price.toStringAsFixed(2)}';
}

enum AppointmentStatus { upcoming, inProgress, completed, cancelled }

class MoodEntry {
  final int score; // 1-5
  final DateTime timestamp;

  const MoodEntry({required this.score, required this.timestamp});

  Map<String, dynamic> toJson() => {
    'score': score,
    'timestamp': timestamp.toIso8601String(),
  };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
    score: json['score'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class Appointment {
  final String id;
  final String coachId;
  final String coachName;
  final String coachEmoji;
  final SessionType sessionType;
  final SessionDuration duration;
  final DateTime scheduledAt;
  final AppointmentStatus status;
  final MoodEntry? moodBefore;
  final MoodEntry? moodAfter;
  final String? sessionNotes;
  final String? sessionSummary;
  final List<String> keyInsights;
  final List<String> actionItems;
  final bool isPaid;
  final bool isVideoAddon;

  const Appointment({
    required this.id,
    required this.coachId,
    required this.coachName,
    required this.coachEmoji,
    required this.sessionType,
    required this.duration,
    required this.scheduledAt,
    this.status = AppointmentStatus.upcoming,
    this.moodBefore,
    this.moodAfter,
    this.sessionNotes,
    this.sessionSummary,
    this.keyInsights = const [],
    this.actionItems = const [],
    this.isPaid = false,
    this.isVideoAddon = false,
  });

  Appointment copyWith({
    AppointmentStatus? status,
    MoodEntry? moodBefore,
    MoodEntry? moodAfter,
    String? sessionNotes,
    String? sessionSummary,
    List<String>? keyInsights,
    List<String>? actionItems,
    bool? isPaid,
  }) =>
      Appointment(
        id: id,
        coachId: coachId,
        coachName: coachName,
        coachEmoji: coachEmoji,
        sessionType: sessionType,
        duration: duration,
        scheduledAt: scheduledAt,
        status: status ?? this.status,
        moodBefore: moodBefore ?? this.moodBefore,
        moodAfter: moodAfter ?? this.moodAfter,
        sessionNotes: sessionNotes ?? this.sessionNotes,
        sessionSummary: sessionSummary ?? this.sessionSummary,
        keyInsights: keyInsights ?? this.keyInsights,
        actionItems: actionItems ?? this.actionItems,
        isPaid: isPaid ?? this.isPaid,
        isVideoAddon: isVideoAddon,
      );

  double get totalPrice {
    var p = duration.price;
    if (isVideoAddon) p += 2.99;
    return p;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'coachId': coachId,
    'coachName': coachName,
    'coachEmoji': coachEmoji,
    'sessionType': sessionType.index,
    'duration': duration.index,
    'scheduledAt': scheduledAt.toIso8601String(),
    'status': status.index,
    'moodBefore': moodBefore?.toJson(),
    'moodAfter': moodAfter?.toJson(),
    'sessionNotes': sessionNotes,
    'sessionSummary': sessionSummary,
    'keyInsights': keyInsights,
    'actionItems': actionItems,
    'isPaid': isPaid,
    'isVideoAddon': isVideoAddon,
  };

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    id: json['id'],
    coachId: json['coachId'],
    coachName: json['coachName'],
    coachEmoji: json['coachEmoji'],
    sessionType: SessionType.values[json['sessionType']],
    duration: SessionDuration.values[json['duration']],
    scheduledAt: DateTime.parse(json['scheduledAt']),
    status: AppointmentStatus.values[json['status']],
    moodBefore: json['moodBefore'] != null
        ? MoodEntry.fromJson(json['moodBefore'])
        : null,
    moodAfter: json['moodAfter'] != null
        ? MoodEntry.fromJson(json['moodAfter'])
        : null,
    sessionNotes: json['sessionNotes'],
    sessionSummary: json['sessionSummary'],
    keyInsights: List<String>.from(json['keyInsights'] ?? []),
    actionItems: List<String>.from(json['actionItems'] ?? []),
    isPaid: json['isPaid'] ?? false,
    isVideoAddon: json['isVideoAddon'] ?? false,
  );

  static String encodeList(List<Appointment> list) =>
      jsonEncode(list.map((a) => a.toJson()).toList());

  static List<Appointment> decodeList(String source) =>
      (jsonDecode(source) as List)
          .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
          .toList();
}
