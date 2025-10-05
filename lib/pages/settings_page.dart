import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ytnavigator/flutter_ytnavigator.dart';
import 'package:provider/provider.dart';
import 'package:story/pages/voice_settings_page.dart';
import 'package:story/store.dart';
import 'package:story/utils/sp_util.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Color _selectedThemeColor = Colors.deepPurple;

  final List<Color> _themeColors = [
    Colors.deepPurple,
    Colors.purple,
    Colors.purpleAccent,
    Colors.lightGreen,
    Colors.green,
    Colors.teal,
    Colors.lightBlue,
    Colors.cyan,
    Colors.lightBlueAccent,
    Colors.blue,
    Colors.indigo,
    Colors.blueGrey,
    Colors.brown,
    Colors.black,
    Colors.orange,
    Colors.amber,
    Colors.orangeAccent,
    Colors.red,
    Colors.deepOrange,
    Colors.pink,
  ];

  final List<int> _timerOptions = [5, 10, 20, 30, -1]; // -1 表示自定义时间

  // 添加自定义时间输入控制器
  final TextEditingController _customTimerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _customTimerController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _selectedThemeColor = Color(SPUtil.getThemeColor());
    });
  }

  void _saveTimer(int minutes) {
    final store = Provider.of<PlayerStore>(context, listen: false);
    if (minutes > 0) {
      store.startTimer(minutes);
    } else {
      store.cancelTimer();
    }
  }

  Future<void> _saveThemeColor(Color color) async {
    SPUtil.setThemeColor(color.toARGB32());
    setState(() {
      _selectedThemeColor = color;
    });
    // 更新全局主题色
    Provider.of<PlayerStore>(context, listen: false).updateThemeColor(color);
  }

  // 显示自定义时间选择器
  void _showCustomTimerDialog() {
    int selectedMinutes = 30;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('自定义时长'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Slider(
                        value: selectedMinutes.toDouble(),
                        min: 1,
                        max: 60,
                        divisions: 59,
                        label: '$selectedMinutes分钟',
                        onChanged: (value) {
                          setState(() {
                            selectedMinutes = value.round();
                          });
                        },
                        activeColor: Theme.of(context).primaryColor,
                      ),
                      Text(
                        '$selectedMinutes分钟',
                        style: TextStyle(
                          fontSize: 24,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        '取消',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _saveTimer(selectedMinutes);
                        Navigator.pop(context);
                      },
                      child: Text(
                        '确定',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  // 格式化时间显示
  String _formatTime(int minutes) {
    if (minutes == 0) return '关闭';
    if (minutes < 60) return '$minutes分钟';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '$hours小时';
    return '$hours小时$mins分钟';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          top: 16,
          left: 16 + MediaQuery.of(context).padding.left,
          right: 16 + MediaQuery.of(context).padding.right,
          bottom: 16 + MediaQuery.of(context).padding.bottom + 100,
        ),
        children: [
          _buildSection(
            title: const Text(
              '主题颜色',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  _themeColors.map((color) {
                    return _buildColorOption(color);
                  }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          _buildTimerSection(),
          const SizedBox(height: 24),
          _buildSection(
            title: const Text(
              '音色设置',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            child: _buildNavigationCard(
              icon: Icons.music_note,
              title: '选择音色',
              subtitle: '设置故事朗读的音色',
              onTap: () {
                NavigatorUtil.push(context, VoiceSettingsPage());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required Widget title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [title, const SizedBox(height: 16), child],
    );
  }

  Widget _buildColorOption(Color color) {
    final isSelected = _selectedThemeColor.toARGB32() == color.toARGB32();
    return GestureDetector(
      onTap: () => _saveThemeColor(color),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: isSelected ? 8 : 4,
              spreadRadius: isSelected ? 2 : 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child:
            isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
      ),
    );
  }

  Widget _buildTimerSection() {
    return Consumer<PlayerStore>(
      builder: (context, store, child) {
        final selectedTimer =
            store.remainingSeconds != null
                ? (store.remainingSeconds! / 60).ceil()
                : 0;

        return _buildSection(
          title: const Text(
            '定时关闭',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    if (store.remainingTimeText != null)
                      Text(
                        '剩余 ${store.remainingTimeText}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    else
                      Text(
                        '上次定时 ${_formatTime(selectedTimer)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    const Spacer(),
                    Switch(
                      value: store.isTimerActive,
                      onChanged: (value) {
                        if (value) {
                          _saveTimer(5);
                        } else {
                          _saveTimer(0);
                        }
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      _timerOptions.map((minutes) {
                        final isSelected = selectedTimer == minutes;
                        if (minutes == -1) {
                          return _buildCustomTimerButton();
                        }
                        return GestureDetector(
                          onTap: () => _saveTimer(minutes),
                          child: _buildTimerChip(minutes, isSelected),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimerChip(int minutes, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:
            isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isSelected
                  ? Colors.transparent
                  : Theme.of(context).primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Text(
        '$minutes分钟',
        style: TextStyle(
          color: isSelected ? Colors.white : Theme.of(context).primaryColor,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildCustomTimerButton() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showCustomTimerDialog,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '自定义',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
