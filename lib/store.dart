import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:story/core/blocs/category/category_cubit.dart';
import 'package:story/core/blocs/story/story_cubit.dart';
import 'package:story/core/repos/category_repo.dart';
import 'package:story/core/repos/story_repo.dart';
import 'package:story/models/story.dart';
import 'package:story/utils/sp_util.dart';

/// 全局状态管理
class Store {
  Store._internal();

  // 初始化
  static init(Widget child) {
    return MultiProvider(
      providers: [
        // 国际化
        ChangeNotifierProvider.value(
          value: LocaleStore(SPUtil.getLanguageCode()),
        ),
        // 分类
        BlocProvider(create: (_) => CategoryCubit(CategoryRepo())),
        // 故事
        BlocProvider(create: (_) => StoryCubit(StoryRepo())),
        // 播放器
        ChangeNotifierProvider.value(value: PlayerStore()),
      ],
      child: child,
    );
  }
}

class PlayerStore with ChangeNotifier {
  final AudioPlayer player = AudioPlayer();

  int? _index;
  List<Story> _playList = [];
  bool _isPlaying = false;
  String _selectedVoiceType = 'roumei'; // 默认使用柔美音色

  // 主题色
  Color _themeColor = Color(SPUtil.getThemeColor());
  Color get themeColor => _themeColor;

  Timer? _timer;
  int? _remainingSeconds;

  PlayerStore() {
    _initAudioPlayer();
    _loadSelectedVoice();
  }

  void _initAudioPlayer() {
    player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState?.currentSource != null) {
        final index = sequenceState!.currentIndex;
        if (_index != index) {
          _index = index;
          notifyListeners();
        }
      }
    });
  }

  Future<void> _loadSelectedVoice() async {
    try {
      _selectedVoiceType = SPUtil.getVoiceType();
    } catch (e) {
      debugPrint('Error loading voice preference: $e');
    }
  }

  // Getters
  List<Story> get playList => _playList;
  int? get index => _index;
  bool get isPlaying => _isPlaying;
  String get selectedVoiceType => _selectedVoiceType;
  Story? get currentStory =>
      _index != null && _playList.isNotEmpty ? _playList[_index!] : null;
  bool get hasNext => _index != null && _index! < _playList.length - 1;
  bool get hasPrevious => _index != null && _index! > 0;

  // 获取剩余时间
  String? get remainingTimeText {
    if (_remainingSeconds == null) return null;
    final minutes = _remainingSeconds! ~/ 60;
    final seconds = _remainingSeconds! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  int? get remainingSeconds => _remainingSeconds;
  bool get isTimerActive => _timer != null;

  // Setters
  set playList(List<Story> value) {
    if (_playList != value) {
      _playList = value;
      notifyListeners();
    }
  }

  set index(int? value) {
    if (value != _index &&
        value != null &&
        value >= 0 &&
        value < _playList.length) {
      _index = value;
      _seekToIndex();
      notifyListeners();
    }
  }

  set selectedVoiceType(String value) {
    if (_selectedVoiceType != value) {
      _selectedVoiceType = value;
      SPUtil.setVoiceType(value);
      // 如果当前有播放列表，需要更新音频源
      if (_playList.isNotEmpty) {
        updatePlaylistAndPlay(_playList, _index ?? 0);
      }
      notifyListeners();
    }
  }

  Future<void> _seekToIndex() async {
    if (_index != null) {
      await player.seek(Duration.zero, index: _index);
    }
  }

  Future<void> updatePlaylistAndPlay(List<Story> stories, int index) async {
    if (stories.isEmpty || index < 0 || index >= stories.length) return;

    try {
      // 更新内部状态
      _playList = stories;
      _index = index;
      notifyListeners();

      // 创建播放列表
      final playlist = ConcatenatingAudioSource(
        children:
            stories.map((story) {
              // 根据选择的音色类型获取对应的URL
              String url;
              switch (_selectedVoiceType) {
                case 'gaoleng':
                  url = story.urlGaoleng;
                  break;
                case 'yangguang':
                  url = story.urlYangguang;
                  break;
                case 'wennuan':
                  url = story.urlWennuan;
                  break;
                case 'roumei':
                default:
                  url = story.urlRoumei;
                  break;
              }

              return AudioSource.uri(
                Uri.parse(url),
                tag: MediaItem(
                  id: story.name,
                  album: story.category.name,
                  artUri: Uri.parse(story.category.cover),
                  title: story.name,
                  displayTitle: story.name,
                  displaySubtitle: "正在播放",
                ),
              );
            }).toList(),
      );

      // 设置音频源并播放
      await player.setAudioSource(playlist, initialIndex: index);
      await player.play();
    } catch (e) {
      debugPrint('Error updating playlist: $e');
      _playList = [];
      _index = null;
      notifyListeners();
    }
  }

  // Player controls
  Future<void> play() async {
    if (_playList.isNotEmpty) {
      await player.play();
    }
  }

  Future<void> pause() async {
    await player.pause();
  }

  Future<void> playNext() async {
    if (hasNext) {
      await player.seekToNext();
    }
  }

  Future<void> playPrevious() async {
    if (hasPrevious) {
      await player.seekToPrevious();
    }
  }

  void clearPlayList() {
    _playList = [];
    _index = null;
    player.stop();
    notifyListeners();
  }

  // 开始倒计时
  void startTimer(int minutes) {
    _timer?.cancel();
    _remainingSeconds = minutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds! > 0) {
        _remainingSeconds = _remainingSeconds! - 1;
        notifyListeners();
      } else {
        // 倒计时结束
        cancelTimer();
        // 只有在正在播放时才暂停
        if (_isPlaying) {
          pause(); // 暂停播放
        }
      }
    });
    notifyListeners();
  }

  // 取消倒计时
  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
    _remainingSeconds = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    player.dispose();
    super.dispose();
  }

  // 更新主题色
  void updateThemeColor(Color color) {
    _themeColor = color;
    notifyListeners();
  }
}

/// 语言
class LocaleStore with ChangeNotifier {
  String _languageCode;

  LocaleStore(this._languageCode);

  String get languageCode => _languageCode;

  void setLanguageCode(String languageCode) {
    _languageCode = languageCode;
    SPUtil.setLanguageCode(languageCode);
    notifyListeners();
  }
}
