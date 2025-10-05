import 'package:story/models/story_category.dart';

class Story {
  final String name;
  final String urlGaoleng; // 高冷音色URL
  final String urlRoumei; // 柔美音色URL
  final String urlYangguang; // 阳光音色URL
  final String urlWennuan; // 温暖音色URL
  final StoryCategory category;

  Story({
    required this.name,
    required this.category,
    required this.urlGaoleng,
    required this.urlRoumei,
    required this.urlYangguang,
    required this.urlWennuan,
  });

  // 从JSON映射创建Story对象
  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      name: json['name'] ?? '',
      category: StoryCategory.fromJson(json['category']),
      urlGaoleng: json['url_gaoleng'] ?? '',
      urlRoumei: json['url_roumei'] ?? '',
      urlYangguang: json['url_yangguang'] ?? '',
      urlWennuan: json['url_wennuan'] ?? '',
    );
  }

  // 将Story对象转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url_gaoleng': urlGaoleng,
      'url_roumei': urlRoumei,
      'url_yangguang': urlYangguang,
      'url_wennuan': urlWennuan,
    };
  }
}
