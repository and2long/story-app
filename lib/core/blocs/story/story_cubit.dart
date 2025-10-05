import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:story/core/blocs/extension.dart';
import 'package:story/core/blocs/handle_error.dart';
import 'package:story/core/blocs/story/story_state.dart';
import 'package:story/core/repos/story_repo.dart';
import 'package:story/models/story.dart';

class StoryCubit extends Cubit<StoryState> {
  final StoryRepo _repo;

  StoryCubit(StoryRepo repo) : _repo = repo, super(StoryInitialState());

  Future<List<Story>?> getStoryList({
    int categoryId = 0,
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        maybeEmit(StoryLoadingState());
      }

      Response res = await _repo.getStoryList(categoryId: categoryId);
      List<Story> items =
          (res.data as List).map((e) => Story.fromJson(e)).toList();
      maybeEmit(StoryListSuccessState(items));
      return items;
    } catch (e, s) {
      handleError(e, stackTrace: s);
      maybeEmit(StoryErrorState('获取故事列表失败'));
      return null;
    }
  }

  Future<Story?> getStoryDetail(int storyId) async {
    try {
      SmartDialog.showLoading();
      Response res = await _repo.getStoryDetail(storyId);
      Story story = Story.fromJson(res.data);
      return story;
    } catch (e, s) {
      handleError(e, stackTrace: s);
      return null;
    } finally {
      SmartDialog.dismiss();
    }
  }
}
