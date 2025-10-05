import 'package:dio/dio.dart';
import 'package:story/constants.dart';
import 'package:story/core/network/http.dart';

class StoryRepo {
  Future<Response> getStoryList({int categoryId = 0}) async {
    return XHttp.instance.get(
      ConstantsHttp.stories,
      queryParameters: {'category_id': categoryId},
    );
  }

  Future<Response> getStoryDetail(int storyId) async {
    return XHttp.instance.get('${ConstantsHttp.stories}/$storyId');
  }
}
