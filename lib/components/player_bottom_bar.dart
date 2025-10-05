import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story/components/yt_network_image.dart';
import 'package:story/pages/player_fullscreen_page.dart';
import 'package:story/store.dart';

class PlayerBottomBar extends StatefulWidget {
  const PlayerBottomBar({super.key});

  @override
  State<PlayerBottomBar> createState() => _PlayerBottomBarState();
}

class _PlayerBottomBarState extends State<PlayerBottomBar>
    with SingleTickerProviderStateMixin {
  final GlobalKey _containerKey = GlobalKey();
  bool _isExpanding = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // 初始显示时的动画
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _expandToFullscreen() async {
    // 获取当前底部栏的位置和大小
    final RenderBox? renderBox =
        _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final originRect = Rect.fromLTWH(
      position.dx,
      position.dy,
      size.width,
      size.height,
    );

    // 播放收起动画
    await _animationController.reverse();

    if (!mounted) return;

    setState(() {
      _isExpanding = true;
    });

    // 导航到全屏播放页面，使用透明路由
    await Navigator.of(context).push(
      _TransparentPageRoute(
        builder: (context) => PlayerFullscreenPage(originRect: originRect),
      ),
    );

    if (!mounted) return;

    setState(() {
      _isExpanding = false;
    });

    // 重新显示时播放展开动画
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (_isExpanding) {
      return const SizedBox.shrink();
    }

    return Consumer<PlayerStore>(
      builder: (context, store, child) {
        if (store.playList.isEmpty || store.currentStory == null) {
          return const SizedBox.shrink();
        }

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, (1.0 - _slideAnimation.value) * 200),
              child: GestureDetector(
                onTap: _expandToFullscreen,
                child: Container(
                  key: _containerKey,
                  height: 64 + MediaQuery.of(context).padding.bottom,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 进度条
                      _buildProgressBar(context, store),

                      // 主要内容
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 16 + MediaQuery.of(context).padding.left,
                            right: 16 + MediaQuery.of(context).padding.right,
                            bottom: MediaQuery.of(context).padding.bottom,
                          ),
                          child: Row(
                            children: [
                              // 封面
                              Hero(
                                tag: 'player_cover',
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child:
                                        store
                                                    .currentStory
                                                    ?.category
                                                    .cover
                                                    .isNotEmpty ==
                                                true
                                            ? YTNetworkImage(
                                              imageUrl:
                                                  store
                                                      .currentStory!
                                                      .category
                                                      .cover,
                                              fit: BoxFit.cover,
                                            )
                                            : Icon(
                                              Icons.auto_stories_rounded,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                              size: 24,
                                            ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // 标题和播放序号
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // 标题
                                    Hero(
                                      tag: 'player_title',
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Text(
                                          store.currentStory!.name,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[800],
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    // 播放序号
                                    Text(
                                      '第 ${store.index! + 1} / ${store.playList.length} 个故事',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 播放按钮
                              _buildPlayButton(
                                isPlaying: store.isPlaying,
                                onPressed: () {
                                  if (store.isPlaying) {
                                    store.pause();
                                  } else {
                                    store.play();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProgressBar(BuildContext context, PlayerStore store) {
    return StreamBuilder<Duration>(
      stream: store.player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = store.player.duration ?? Duration.zero;

        return SizedBox(
          height: 2,
          child: LinearProgressIndicator(
            value:
                duration.inMilliseconds > 0
                    ? position.inMilliseconds / duration.inMilliseconds
                    : 0,
            backgroundColor: Theme.of(
              context,
            ).primaryColor.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayButton({
    required bool isPlaying,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(
        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
        color: Theme.of(context).primaryColor,
        size: 32,
      ),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}

// 自定义路由
class _TransparentPageRoute<T> extends PageRoute<T> {
  _TransparentPageRoute({required this.builder, super.settings})
    : super(fullscreenDialog: false);

  final WidgetBuilder builder;

  @override
  bool get opaque => true;

  @override
  bool get barrierDismissible => false;

  @override
  Color? get barrierColor => Colors.black;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
