import 'package:story/models/story.dart';

abstract class StoryState {}

class StoryInitialState extends StoryState {}

class StoryLoadingState extends StoryState {}

class StoryListSuccessState extends StoryState {
  final List<Story> items;
  StoryListSuccessState(this.items);
}

class StoryErrorState extends StoryState {
  final String message;
  StoryErrorState(this.message);
}
