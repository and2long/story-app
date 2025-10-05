import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story/store.dart';

class PlaylistBottomSheet extends StatelessWidget {
  final PlayerStore store;

  const PlaylistBottomSheet({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width / size.height > 1.5 || size.width > 900;

    return Container(
      height: isWideScreen ? size.height * 0.8 : size.height * 0.7,
      width: isWideScreen ? size.width * 0.85 : size.width,
      margin:
          isWideScreen
              ? EdgeInsets.symmetric(horizontal: size.width * 0.075)
              : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.grey[900], // 设置为深灰色背景
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isWideScreen ? 30 : 20),
          topRight: Radius.circular(isWideScreen ? 30 : 20),
        ),
      ),
      child: Column(
        children: [
          // 顶部拖动条
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 标题
          Padding(
            padding: EdgeInsets.all(isWideScreen ? 24 : 16),
            child: Row(
              children: [
                Icon(
                  Icons.queue_music,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '播放列表 (${store.playList.length})',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isWideScreen ? 22 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // 列表
          Expanded(
            child: Consumer<PlayerStore>(
              builder: (context, playerStore, child) {
                return ListView.builder(
                  itemCount: playerStore.playList.length,
                  itemBuilder: (context, index) {
                    final story = playerStore.playList[index];
                    final isPlaying =
                        playerStore.index == index && playerStore.isPlaying;
                    final isSelected = playerStore.index == index;

                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isWideScreen ? 24 : 16,
                        vertical: isWideScreen ? 8 : 4,
                      ),
                      leading: Container(
                        width: isWideScreen ? 50 : 40,
                        height: isWideScreen ? 50 : 40,
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            isWideScreen ? 10 : 8,
                          ),
                        ),
                        child: Center(
                          child:
                              isPlaying
                                  ? Icon(
                                    Icons.pause,
                                    color: Colors.white,
                                    size: isWideScreen ? 24 : 20,
                                  )
                                  : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isWideScreen ? 18 : 14,
                                    ),
                                  ),
                        ),
                      ),
                      title: Text(
                        story.name,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.white,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: isWideScreen ? 18 : 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        if (isSelected && isPlaying) {
                          playerStore.pause();
                        } else if (isSelected && !isPlaying) {
                          playerStore.play();
                        } else {
                          playerStore.index = index;
                          playerStore.play();
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
