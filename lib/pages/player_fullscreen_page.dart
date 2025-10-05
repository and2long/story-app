import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story/components/global_overlay.dart';
import 'package:story/components/player_bottom_bar.dart';
import 'package:story/components/playlist_bottom_sheet.dart';
import 'package:story/components/yt_network_image.dart';
import 'package:story/store.dart';

class PlayerFullscreenPage extends StatefulWidget {
  final Rect? originRect;

  const PlayerFullscreenPage({super.key, this.originRect});

  @override
  State<PlayerFullscreenPage> createState() => _PlayerFullscreenPageState();
}

class _PlayerFullscreenPageState extends State<PlayerFullscreenPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Offset _initialSwipeOffset;
  late Offset _currentSwipeOffset;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuad),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // 隐藏底部控制栏
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GlobalOverlay.remove();
    });

    _animationController.forward();
    _initialSwipeOffset = Offset.zero;
    _currentSwipeOffset = Offset.zero;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showPlaylistMenu(BuildContext context, PlayerStore store) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PlaylistBottomSheet(store: store),
    );
  }

  // 判断是否为宽屏设备
  bool _isWideScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // 宽高比大于1.5或宽度大于600认为是宽屏
    return size.width / size.height > 1.5 || size.width > 900;
  }

  // 根据屏幕尺寸计算封面大小
  double _calculateCoverSize(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = _isWideScreen(context);

    if (isWide) {
      // 宽屏设备上，封面大小相对较小
      return size.height * 0.4;
    } else {
      // 窄屏设备上，封面大小相对较大
      return size.width * 0.6;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) async {
        if (!didPop) {
          // 只处理系统返回事件，不处理已经pop的情况
          await _closeFullscreen();
        }
      },
      child: GestureDetector(
        onVerticalDragStart: (details) {
          _initialSwipeOffset = details.globalPosition;
        },
        onVerticalDragUpdate: (details) {
          setState(() {
            _currentSwipeOffset = details.globalPosition;
          });
        },
        onVerticalDragEnd: (details) async {
          final swipeDistance = _currentSwipeOffset.dy - _initialSwipeOffset.dy;
          if (swipeDistance > 100) {
            await _closeFullscreen();
          } else {
            setState(() {
              _initialSwipeOffset = Offset.zero;
              _currentSwipeOffset = Offset.zero;
            });
          }
        },
        child: Consumer<PlayerStore>(
          builder: (context, store, child) {
            if (store.playList.isEmpty || store.currentStory == null) {
              return Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: Text(
                    '没有正在播放的内容',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }

            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Scaffold(
                  backgroundColor: Colors.black,
                  body: Stack(
                    children: [
                      // 背景渐变
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Theme.of(context).primaryColor,
                              Colors.black,
                            ],
                          ),
                        ),
                      ),

                      // 内容 - 使用抽屉式动画
                      AnimatedBuilder(
                        animation: _slideAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              0,
                              MediaQuery.of(context).size.height *
                                  _slideAnimation.value,
                            ),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: SafeArea(
                                child:
                                    _isWideScreen(context)
                                        ? _buildWideScreenLayout(
                                          context,
                                          store,
                                          _calculateCoverSize(context),
                                        )
                                        : _buildNarrowScreenLayout(
                                          context,
                                          store,
                                          _calculateCoverSize(context),
                                        ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // 宽屏布局
  Widget _buildWideScreenLayout(
    BuildContext context,
    PlayerStore store,
    double coverSize,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // 顶部栏
          _buildTopBar(context, store),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 左侧封面
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Hero(
                      tag: 'player_cover',
                      child: Container(
                        width: coverSize,
                        height: coverSize,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child:
                              store.currentStory?.category.cover.isNotEmpty ==
                                      true
                                  ? YTNetworkImage(
                                    imageUrl:
                                        store.currentStory!.category.cover,
                                    fit: BoxFit.cover,
                                  )
                                  : Icon(
                                    Icons.auto_stories_rounded,
                                    color: Colors.white,
                                    size: coverSize * 0.5,
                                  ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 右侧控制区域
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 标题和描述
                        Hero(
                          tag: 'player_title',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              store.currentStory!.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '第 ${store.index! + 1} / ${store.playList.length} 个故事',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 进度条
                        _buildProgressBar(context, store),

                        const SizedBox(height: 32),

                        // 控制按钮
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildControlButton(
                              icon: Icons.skip_previous_rounded,
                              onPressed:
                                  store.hasPrevious ? store.playPrevious : null,
                              size: 70,
                            ),
                            const SizedBox(width: 32),
                            _buildPlayButton(
                              isPlaying: store.isPlaying,
                              onPressed: () {
                                if (store.isPlaying) {
                                  store.pause();
                                } else {
                                  store.play();
                                }
                              },
                              size: 90,
                            ),
                            const SizedBox(width: 32),
                            _buildControlButton(
                              icon: Icons.skip_next_rounded,
                              onPressed: store.hasNext ? store.playNext : null,
                              size: 70,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 窄屏布局
  Widget _buildNarrowScreenLayout(
    BuildContext context,
    PlayerStore store,
    double coverSize,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 顶部栏
        _buildTopBar(context, store),

        const Spacer(flex: 1),

        // 封面图标
        Hero(
          tag: 'player_cover',
          child: Container(
            width: coverSize,
            height: coverSize,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child:
                  store.currentStory?.category.cover.isNotEmpty == true
                      ? YTNetworkImage(
                        imageUrl: store.currentStory!.category.cover,
                        fit: BoxFit.cover,
                      )
                      : Icon(
                        Icons.auto_stories_rounded,
                        color: Colors.white,
                        size: coverSize * 0.5,
                      ),
            ),
          ),
        ),

        const Spacer(flex: 1),

        // 标题和描述
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Hero(
                tag: 'player_title',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    store.currentStory!.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '第 ${store.index! + 1} / ${store.playList.length} 个故事',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        const Spacer(flex: 1),

        // 进度条
        _buildProgressBar(context, store),

        const SizedBox(height: 24),

        // 控制按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(
              icon: Icons.skip_previous_rounded,
              onPressed: store.hasPrevious ? store.playPrevious : null,
              size: 60,
            ),
            const SizedBox(width: 24),
            _buildPlayButton(
              isPlaying: store.isPlaying,
              onPressed: () {
                if (store.isPlaying) {
                  store.pause();
                } else {
                  store.play();
                }
              },
              size: 80,
            ),
            const SizedBox(width: 24),
            _buildControlButton(
              icon: Icons.skip_next_rounded,
              onPressed: store.hasNext ? store.playNext : null,
              size: 60,
            ),
          ],
        ),

        const Spacer(flex: 1),
      ],
    );
  }

  // 顶部栏
  Widget _buildTopBar(BuildContext context, PlayerStore store) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 32,
            ),
            onPressed: _closeFullscreen,
          ),
          Text(
            '正在播放',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.queue_music, color: Colors.white),
            onPressed: () => _showPlaylistMenu(context, store),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, PlayerStore store) {
    final isWideScreen = _isWideScreen(context);
    final horizontalPadding = isWideScreen ? 0.0 : 32.0;

    return StreamBuilder<Duration>(
      stream: store.player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = store.player.duration ?? Duration.zero;

        return Column(
          children: [
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: isWideScreen ? 10 : 8,
                ),
                overlayShape: RoundSliderOverlayShape(
                  overlayRadius: isWideScreen ? 20 : 16,
                ),
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                thumbColor: Colors.white,
                overlayColor: Colors.white.withValues(alpha: 0.3),
              ),
              child: Slider(
                min: 0,
                max: duration.inMilliseconds.toDouble(),
                value: position.inMilliseconds.toDouble().clamp(
                  0,
                  duration.inMilliseconds.toDouble(),
                ),
                onChanged: (value) {
                  store.player.seek(Duration(milliseconds: value.toInt()));
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(position),
                    style: TextStyle(
                      fontSize: isWideScreen ? 16 : 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    _formatDuration(duration),
                    style: TextStyle(
                      fontSize: isWideScreen ? 16 : 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required double size,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color:
                onPressed != null
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.3),
            size: size * 0.6,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton({
    required bool isPlaying,
    required VoidCallback onPressed,
    required double size,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: Theme.of(context).primaryColor,
            size: size * 0.6,
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _closeFullscreen() async {
    await _animationController.reverse();
    if (mounted) {
      // 显示底部控制栏
      GlobalOverlay.show(context: context, view: const PlayerBottomBar());
      Navigator.of(context).pop();
    }
  }
}
