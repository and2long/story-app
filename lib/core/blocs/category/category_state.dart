import 'package:story/models/story_category.dart';

abstract class CategoryState {}

class CategoryInitialState extends CategoryState {}

class CategoryDeleteScuuessState extends CategoryState {
  final int id;
  CategoryDeleteScuuessState(this.id);
}

class CategoryListSuccessState extends CategoryState {
  final List<StoryCategory> items;
  CategoryListSuccessState(this.items);
}
