import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../providers/tts_settings_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/word_provider.dart';
import '../services/google_cloud_tts_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Map<String, String>> _deviceVoices = [];
  bool _isLoadingVoices = true;
  final _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVoices();
    _apiKeyController.text = context.read<TtsSettingsProvider>().apiKey;
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadVoices() async {
    final wordProvider = context.read<WordProvider>();
    await wordProvider.ttsService.init();
    setState(() {
      _deviceVoices = wordProvider.ttsService.japaneseVoices;
      _isLoadingVoices = false;
    });
  }

  Future<void> _testTts(String text) async {
    final wordProvider = context.read<WordProvider>();
    final settings = context.read<TtsSettingsProvider>();
    await wordProvider.ttsService.applySettings(settings);
    await wordProvider.ttsService.speakJapanese(text);
  }

  void _applySettings() {
    final wordProvider = context.read<WordProvider>();
    final settings = context.read<TtsSettingsProvider>();
    wordProvider.ttsService.applySettings(settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TtsSettingsProvider>(
        builder: (context, settings, _) {
          final themeProvider = context.watch<ThemeProvider>();
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // 앱 테마
              _buildSectionTitle('앱 테마'),
              const SizedBox(height: 4),
              const Text(
                '홈 화면 색상 테마를 선택하세요',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(ThemeProvider.presets.length, (i) {
                  final preset = ThemeProvider.presets[i];
                  final isSelected = themeProvider.selectedIndex == i;
                  return GestureDetector(
                    onTap: () => themeProvider.selectTheme(i),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [preset.start, preset.end],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: preset.start.withValues(alpha: 0.6), blurRadius: 8)]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 22)
                              : null,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          preset.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : Colors.white54,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),
              const Divider(color: Colors.white12),
              const SizedBox(height: 20),
              // 퀴즈 문항 수 설정
              _buildSectionTitle('퀴즈 문항 수'),
              const SizedBox(height: 4),
              const Text(
                '퀴즈 한 회차에 출제되는 문제 수',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                children: [10, 20, 30, 50].map((count) {
                  final isSelected = settings.quizCount == count;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => settings.setQuizCount(count),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFe96743).withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFe96743)
                                  : Colors.white24,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$count개',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white54,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // 퀴즈 자동 음성
              _buildSectionTitle('퀴즈 자동 음성'),
              const SizedBox(height: 4),
              const Text(
                '퀴즈 문제가 나올 때 자동으로 음성을 재생합니다',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: settings.quizAutoTts,
                onChanged: (value) => settings.setQuizAutoTts(value),
                title: Text(
                  settings.quizAutoTts ? '자동 재생 켜짐' : '자동 재생 꺼짐',
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
                subtitle: Text(
                  settings.quizAutoTts
                      ? '문제마다 음성이 먼저 나옵니다'
                      : '음성 없이 문장을 읽고 풀 수 있습니다',
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                ),
                activeThumbColor: const Color(0xFF667eea),
                inactiveThumbColor: Colors.white38,
                inactiveTrackColor: Colors.white12,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 28),

              // TTS 엔진 선택
              _buildSectionTitle('TTS 엔진'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildEngineButton(
                      icon: Icons.phone_android,
                      label: '기기 TTS',
                      subtitle: '무료 / 오프라인',
                      isSelected: settings.engine == 'device',
                      onTap: () {
                        settings.setEngine('device');
                        _applySettings();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildEngineButton(
                      icon: Icons.cloud,
                      label: 'Cloud TTS',
                      subtitle: '고품질 / API 키',
                      isSelected: settings.engine == 'google_cloud',
                      onTap: () {
                        settings.setEngine('google_cloud');
                        _applySettings();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // 엔진별 설정
              if (settings.engine == 'device') ...[
                _buildDeviceTtsSettings(settings),
              ] else ...[
                _buildCloudTtsSettings(settings),
              ],

              const SizedBox(height: 28),

              // 공통: 말하기 속도
              _buildSectionTitle('말하기 속도'),
              const SizedBox(height: 4),
              Text(
                _getSpeedLabel(settings.speechRate),
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              Slider(
                value: settings.speechRate,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                activeColor: const Color(0xFF667eea),
                inactiveColor: Colors.white24,
                onChanged: (value) => settings.setSpeechRate(value),
                onChangeEnd: (_) => _applySettings(),
              ),
              _buildSliderLabels('느리게', '보통', '빠르게'),
              const SizedBox(height: 20),

              // 공통: 피치
              _buildSectionTitle('음높이 (피치)'),
              const SizedBox(height: 4),
              Text(
                _getPitchLabel(settings.pitch),
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              Slider(
                value: settings.pitch,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                activeColor: const Color(0xFF667eea),
                inactiveColor: Colors.white24,
                onChanged: (value) => settings.setPitch(value),
                onChangeEnd: (_) => _applySettings(),
              ),
              _buildSliderLabels('낮게', '보통', '높게'),
              const SizedBox(height: 32),

              // 테스트 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _testTts('こんにちは、日本語の勉強を始めましょう'),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('음성 테스트', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // 데이터 초기화
              const Divider(color: Colors.white12),
              const SizedBox(height: 20),
              _buildSectionTitle('데이터 관리'),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showResetConfirmDialog(),
                  icon: const Icon(Icons.delete_forever, size: 20),
                  label: const Text('모든 학습 초기화',
                      style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '학습 기록, 퀴즈 결과, 랭킹 통계가 모두 삭제됩니다.',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  void _showResetConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: const Text(
          '모든 학습 초기화',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '학습 기록, 퀴즈 결과, 랭킹 통계가 모두 삭제됩니다.\n\n이 작업은 되돌릴 수 없습니다. 정말 초기화하시겠습니까?',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<HistoryProvider>().clearAllData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('모든 학습 기록이 초기화되었습니다.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }

  // ===== 기기 TTS 설정 =====
  Widget _buildDeviceTtsSettings(TtsSettingsProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 성별 선택
        _buildSectionTitle('음성 성별'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGenderButton(
                icon: Icons.female,
                label: '여성',
                isSelected: settings.voiceGender == 'female',
                onTap: () {
                  settings.setVoiceGender('female');
                  settings.setSelectedVoiceName(null);
                  _applySettings();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderButton(
                icon: Icons.male,
                label: '남성',
                isSelected: settings.voiceGender == 'male',
                onTap: () {
                  settings.setVoiceGender('male');
                  settings.setSelectedVoiceName(null);
                  _applySettings();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 음성 직접 선택
        _buildSectionTitle('음성 직접 선택'),
        const SizedBox(height: 4),
        const Text(
          '기기에 설치된 일본어 음성',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(height: 12),
        if (_isLoadingVoices)
          const Center(
            child: CircularProgressIndicator(color: Color(0xFF667eea)),
          )
        else if (_deviceVoices.isEmpty)
          _buildInfoBox(
            '일본어 음성이 없습니다.\n'
            '폰 설정 → 일반 관리 → TTS → Google TTS 설정\n'
            '→ 일본어 음성 데이터 다운로드',
          )
        else
          ..._deviceVoices.map((voice) => _buildDeviceVoiceTile(voice, settings)),
      ],
    );
  }

  // ===== Google Cloud TTS 설정 =====
  Widget _buildCloudTtsSettings(TtsSettingsProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // API 키 입력
        _buildSectionTitle('Google Cloud API 키'),
        const SizedBox(height: 8),
        TextField(
          controller: _apiKeyController,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'API 키를 입력하세요',
            hintStyle: const TextStyle(color: Colors.white30),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF667eea)),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.save, color: Colors.white54),
              onPressed: () {
                settings.setApiKey(_apiKeyController.text.trim());
                _applySettings();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API 키가 저장되었습니다')),
                );
              },
            ),
          ),
          onSubmitted: (value) {
            settings.setApiKey(value.trim());
            _applySettings();
          },
        ),
        const SizedBox(height: 8),
        _buildInfoBox(
          'Google Cloud Console → API 및 서비스 → 사용자 인증 정보\n'
          '→ API 키 생성 → Cloud Text-to-Speech API 활성화',
        ),
        const SizedBox(height: 20),

        // 음성 선택
        _buildSectionTitle('음성 선택'),
        const SizedBox(height: 4),
        const Text(
          'Neural2 > WaveNet > Standard 순으로 고품질',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(height: 12),

        // 성별 필터
        Row(
          children: [
            Expanded(
              child: _buildGenderButton(
                icon: Icons.female,
                label: '여성',
                isSelected: settings.voiceGender == 'female',
                onTap: () => settings.setVoiceGender('female'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderButton(
                icon: Icons.male,
                label: '남성',
                isSelected: settings.voiceGender == 'male',
                onTap: () => settings.setVoiceGender('male'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Cloud 음성 목록
        ...GoogleCloudTtsService.japaneseVoices
            .where((v) => v['gender'] == settings.voiceGender)
            .map((voice) => _buildCloudVoiceTile(voice, settings)),
      ],
    );
  }

  // ===== 공통 위젯들 =====

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSliderLabels(String left, String center, String right) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        Text(center, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        Text(right, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  Widget _buildInfoBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
      ),
    );
  }

  Widget _buildEngineButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF667eea).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF667eea) : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? const Color(0xFF667eea) : Colors.white54,
                size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF667eea).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF667eea) : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? const Color(0xFF667eea) : Colors.white54,
                size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceVoiceTile(
      Map<String, String> voice, TtsSettingsProvider settings) {
    final isSelected = settings.selectedVoiceName == voice['name'];
    final name = voice['name'] ?? '';

    String displayName = name;
    if (name.contains('x-jac') || name.contains('x-htm')) {
      displayName = '여성 - $name';
    } else if (name.contains('x-jab') || name.contains('x-jad')) {
      displayName = '남성 - $name';
    }

    return _buildVoiceTile(
      displayName: displayName,
      isSelected: isSelected,
      onTap: () {
        settings.setSelectedVoiceName(name);
        _applySettings();
      },
      onPlay: () {
        settings.setSelectedVoiceName(name);
        _applySettings();
        _testTts('こんにちは');
      },
    );
  }

  Widget _buildCloudVoiceTile(
      Map<String, String> voice, TtsSettingsProvider settings) {
    final isSelected = settings.cloudVoiceName == voice['name'];
    final label = voice['label'] ?? voice['name'] ?? '';

    return _buildVoiceTile(
      displayName: label,
      isSelected: isSelected,
      onTap: () {
        settings.setCloudVoiceName(voice['name']!);
        _applySettings();
      },
      onPlay: () {
        settings.setCloudVoiceName(voice['name']!);
        _applySettings();
        _testTts('こんにちは');
      },
    );
  }

  Widget _buildVoiceTile({
    required String displayName,
    required bool isSelected,
    required VoidCallback onTap,
    required VoidCallback onPlay,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected
            ? const Color(0xFF667eea).withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected ? const Color(0xFF667eea) : Colors.white38,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.play_circle_outline, size: 24),
                  color: Colors.white54,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  onPressed: onPlay,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getSpeedLabel(double rate) {
    if (rate <= 0.2) return '매우 느리게';
    if (rate <= 0.35) return '느리게';
    if (rate <= 0.5) return '보통';
    if (rate <= 0.7) return '빠르게';
    return '매우 빠르게';
  }

  String _getPitchLabel(double pitch) {
    if (pitch <= 0.7) return '매우 낮게';
    if (pitch <= 0.9) return '낮게';
    if (pitch <= 1.2) return '보통';
    if (pitch <= 1.5) return '높게';
    return '매우 높게';
  }
}
