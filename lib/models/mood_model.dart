enum MoodLevel { veryHappy, happy, neutral, sad, verySad }

class Mood {
  final int id;
  final String userId;
  final MoodLevel level;
  final String? note;
  final DateTime date;
  final DateTime createdAt;

  Mood({
    required this.id,
    required this.userId,
    required this.level,
    this.note,
    required this.date,
    required this.createdAt,
  });

  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      level: MoodLevel.values.firstWhere(
        (e) => e.toString() == 'MoodLevel.${json['level']}',
        orElse: () => MoodLevel.neutral,
      ),
      note: json['note'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'level': level.toString().split('.').last,
      'note': note,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Mood copyWith({
    int? id,
    String? userId,
    MoodLevel? level,
    String? note,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Mood(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      level: level ?? this.level,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
