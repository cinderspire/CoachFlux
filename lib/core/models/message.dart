class ChatMessage {
  final String id;
  final String coachId;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;

  const ChatMessage({
    required this.id,
    required this.coachId,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'coachId': coachId,
    'content': content,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'],
    coachId: json['coachId'],
    content: json['content'],
    isUser: json['isUser'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class UserProfile {
  final String? name;
  final List<String> values;
  final List<String> goals;
  final List<String> challenges;
  final String? bio;

  const UserProfile({
    this.name,
    this.values = const [],
    this.goals = const [],
    this.challenges = const [],
    this.bio,
  });

  String toContextString() {
    final parts = <String>[];
    if (name != null) parts.add('My name is $name.');
    if (values.isNotEmpty) parts.add('My core values: ${values.join(", ")}.');
    if (goals.isNotEmpty) parts.add('My current goals: ${goals.join(", ")}.');
    if (challenges.isNotEmpty) parts.add('My challenges: ${challenges.join(", ")}.');
    if (bio != null) parts.add('About me: $bio');
    return parts.join(' ');
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'values': values,
    'goals': goals,
    'challenges': challenges,
    'bio': bio,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'],
    values: List<String>.from(json['values'] ?? []),
    goals: List<String>.from(json['goals'] ?? []),
    challenges: List<String>.from(json['challenges'] ?? []),
    bio: json['bio'],
  );
}
