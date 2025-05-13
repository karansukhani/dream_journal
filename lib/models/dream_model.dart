import 'package:intl/intl.dart';

enum DreamClarity { veryVivid, vivid, moderate, vague, veryVague }
enum DreamType { lucid, nightmare, recurring, normal }

class Dream {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime date;
  final List<String> tags;
  final DreamClarity clarity;
  final DreamType type;
  final int? moodId;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Dream({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.date,
    required this.tags,
    required this.clarity,
    required this.type,
    this.moodId,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Dream.fromJson(Map<String, dynamic> json) {
    return Dream(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      tags: (json['tags'] as List).map((tag) => tag as String).toList(),
      clarity: DreamClarity.values.firstWhere(
        (e) => e.toString() == 'DreamClarity.${json['clarity']}',
        orElse: () => DreamClarity.moderate,
      ),
      type: DreamType.values.firstWhere(
        (e) => e.toString() == 'DreamType.${json['type']}',
        orElse: () => DreamType.normal,
      ),
      moodId: json['mood_id'] as int?,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'tags': tags,
      'clarity': clarity.toString().split('.').last,
      'type': type.toString().split('.').last,
      'mood_id': moodId,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Dream copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? date,
    List<String>? tags,
    DreamClarity? clarity,
    DreamType? type,
    int? moodId,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Dream(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      tags: tags ?? this.tags,
      clarity: clarity ?? this.clarity,
      type: type ?? this.type,
      moodId: moodId ?? this.moodId,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
