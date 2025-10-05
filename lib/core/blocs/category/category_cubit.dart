import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:story/core/blocs/category/category_state.dart';
import 'package:story/core/blocs/extension.dart';
import 'package:story/core/blocs/handle_error.dart';
import 'package:story/core/repos/category_repo.dart';
import 'package:story/models/story_category.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepo _repo;

  CategoryCubit(CategoryRepo repo)
    : _repo = repo,
      super(CategoryInitialState());

  Future<List<StoryCategory>?> getCategoryList() async {
    try {
      SmartDialog.showLoading();
      Response res = await _repo.getCategoryList();
      List<StoryCategory> items =
          (res.data as List).map((e) => StoryCategory.fromJson(e)).toList();
      maybeEmit(CategoryListSuccessState(items));
      return items;
    } catch (e, s) {
      handleError(e, stackTrace: s);
      return null;
    } finally {
      SmartDialog.dismiss();
    }
  }
}
