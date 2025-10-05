import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story/store.dart';
import 'package:story/utils/sp_util.dart';

class VoiceSettingsPage extends StatefulWidget {
  const VoiceSettingsPage({super.key});

  @override
  State<VoiceSettingsPage> createState() => _VoiceSettingsPageState();
}

class _VoiceSettingsPageState extends State<VoiceSettingsPage> {
  String _selectedVoice = 'roumei'; // 默认选择柔美音色

  @override
  void initState() {
    super.initState();
    _loadSelectedVoice();
  }

  void _loadSelectedVoice() {
    setState(() {
      _selectedVoice = SPUtil.getVoiceType();
    });
  }

  Future<void> _saveSelectedVoice(String voice) async {
    SPUtil.setVoiceType(voice);

    // 更新 PlayerStore 中的音色设置
    final store = Provider.of<PlayerStore>(context, listen: false);
    store.selectedVoiceType = voice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('音色设置'),
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
          left: MediaQuery.of(context).padding.left,
          right: MediaQuery.of(context).padding.right,
          bottom: MediaQuery.of(context).padding.bottom + 100,
        ),
        children: [
          const SizedBox(height: 20),
          Text(
            '选择您喜欢的音色',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          _buildVoiceOption(
            title: '柔美音色',
            description: '温柔甜美的女声，适合睡前故事',
            icon: Icons.nightlight_round,
            value: 'roumei',
            color: Colors.purple,
          ),
          _buildVoiceOption(
            title: '高冷音色',
            description: '成熟稳重的女声，适合知识类故事',
            icon: Icons.school,
            value: 'gaoleng',
            color: Colors.blue,
          ),
          _buildVoiceOption(
            title: '阳光音色',
            description: '活力四溢的男声，适合冒险故事',
            icon: Icons.wb_sunny,
            value: 'yangguang',
            color: Colors.orange,
          ),
          _buildVoiceOption(
            title: '温暖音色',
            description: '温和亲切的男声，适合日常故事',
            icon: Icons.favorite,
            value: 'wennuan',
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceOption({
    required String title,
    required String description,
    required IconData icon,
    required String value,
    required Color color,
  }) {
    final isSelected = _selectedVoice == value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side:
              isSelected
                  ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
                  : BorderSide.none,
        ),
        child: InkWell(
          onTap: () async {
            setState(() {
              _selectedVoice = value;
            });
            await _saveSelectedVoice(value);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
