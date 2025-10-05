import 'dart:convert';

class StoryCategory {
  final int id;
  final String theme;
  final String name;
  final String description;
  final String cover;
  final int count;

  StoryCategory({
    required this.id,
    required this.name,
    required this.theme,
    this.count = 0,
    this.description = '',
    this.cover = '',
  });

  factory StoryCategory.fromJson(Map<String, dynamic> json) {
    return StoryCategory(
      id: json['id'] ?? 0,
      theme: json['theme'] ?? '',
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
      description: json['description'] ?? '',
      cover: json['cover'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'theme': theme,
      'name': name,
      'count': count,
      'description': description,
      'cover': cover,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
