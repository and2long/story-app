import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:story/components/yt_network_image.dart';
import 'package:story/core/blocs/story/story_cubit.dart';
import 'package:story/core/blocs/story/story_state.dart';
import 'package:story/core/event_bus.dart';
import 'package:story/models/story.dart';
import 'package:story/models/story_category.dart';
import 'package:story/store.dart';

class StoryListPage extends StatefulWidget {
  final StoryCategory category;

  const StoryListPage({super.key, required this.category});

  @override
  State<StoryListPage> createState() => _StoryListPageState();
}

class _StoryListPageState extends State<StoryListPage> {
  List<Story> _stories = [];

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    context.read<StoryCubit>().getStoryList(categoryId: widget.category.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoryCubit, StoryState>(
      listener: (BuildContext context, StoryState state) {
        if (state is StoryListSuccessState) {
          setState(() {
            _stories = state.items;
          });
        }
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200.0,
              pinned: true,
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final expandRatio =
                      (constraints.maxHeight - kToolbarHeight) /
                      (200.0 - kToolbarHeight);
                  final showTitle = expandRatio < 0.5;

                  return FlexibleSpaceBar(
                    centerTitle: true,
                    title:
                        showTitle
                            ? Text(
                              widget.category.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            : null,
                    titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        YTNetworkImage(
                          imageUrl: widget.category.cover,
                          fit: BoxFit.cover,
                        ),
                        Container(color: Colors.black.withValues(alpha: 0.5)),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.category.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.category.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 8),
                              BlocBuilder<StoryCubit, StoryState>(
                                builder: (context, state) {
                                  int count = 0;
                                  if (state is StoryListSuccessState) {
                                    count = state.items.length;
                                  }
                                  return Text(
                                    '共$count个故事',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(
                top: 16,
                right: 16,
                left: 16,
                bottom: 250,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final story = _stories[index];
                  return StoryCard(
                    story: story,
                    index: index,
                    onTap: () {
                      context.read<PlayerStore>().playList = _stories;
                      context.read<PlayerStore>().index = index;
                      EventBus().fire(StartPlayEvent());
                    },
                    stories: _stories,
                  );
                }, childCount: _stories.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PausePlayEvent {}

class StoryCard extends StatelessWidget {
  final Story story;
  final int index;
  final GestureTapCallback? onTap;
  final List<Story> stories;

  const StoryCard({
    super.key,
    required this.story,
    required this.onTap,
    required this.index,
    required this.stories,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerStore>(
      builder: (context, store, child) {
        final bool isPlaying =
            store.isPlaying &&
            store.playList.isNotEmpty &&
            store.index != null &&
            store.playList[store.index!].name == story.name;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () async {
              if (isPlaying) {
                await store.pause();
              } else {
                await store.updatePlaylistAndPlay(stories, index);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _PlayButton(
                    isPlaying: isPlaying,
                    onTap: () async {
                      if (isPlaying) {
                        await store.pause();
                      } else {
                        await store.updatePlaylistAndPlay(stories, index);
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      story.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        color:
                            isPlaying
                                ? Theme.of(context).primaryColor
                                : Colors.black87,
                      ),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlayButton extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onTap;

  const _PlayButton({required this.isPlaying, required this.onTap});

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(_PlayButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color:
            widget.isPlaying
                ? Theme.of(context).primaryColor
                : Theme.of(context).primaryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(18),
          child:
              widget.isPlaying
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAnimatedBar(0.6, 0),
                      const SizedBox(width: 2),
                      _buildAnimatedBar(1.0, 1),
                      const SizedBox(width: 2),
                      _buildAnimatedBar(0.8, 2),
                    ],
                  )
                  : Icon(
                    Icons.play_arrow_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBar(double height, int delay) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final animation = Tween(begin: 0.3, end: height).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              delay * 0.2,
              0.6 + delay * 0.2,
              curve: Curves.easeInOut,
            ),
          ),
        );

        return Container(
          width: 3,
          height: 16 * animation.value,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(1.5),
          ),
        );
      },
    );
  }
}
