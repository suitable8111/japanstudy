import 'package:flutter_tts/flutter_tts.dart';
import '../providers/tts_settings_provider.dart';
import 'google_cloud_tts_service.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  final GoogleCloudTtsService _cloudTts = GoogleCloudTtsService();
  bool _isInitialized = false;
  List<Map<String, String>> _japaneseVoices = [];
  TtsSettingsProvider? _currentSettings;

  Future<void> init() async {
    if (_isInitialized) return;

    await _flutterTts.setLanguage('ja-JP');
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.05);
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
      ],
      IosTextToSpeechAudioMode.defaultMode,
    );

    final voices = await _flutterTts.getVoices;
    if (voices != null) {
      _japaneseVoices = (voices as List)
          .where((v) => v['locale']?.toString().startsWith('ja') == true)
          .map((v) => {
                'name': v['name']?.toString() ?? '',
                'locale': v['locale']?.toString() ?? '',
              })
          .toList();
    }

    _isInitialized = true;
  }

  List<Map<String, String>> get japaneseVoices => _japaneseVoices;
  bool get isCloudConfigured => _cloudTts.isConfigured;

  Future<void> applySettings(TtsSettingsProvider settings) async {
    await init();
    _currentSettings = settings;

    // Google Cloud TTS API 키 설정
    if (settings.apiKey.isNotEmpty) {
      _cloudTts.setApiKey(settings.apiKey);
    }

    // 기기 TTS 설정 적용
    await _flutterTts.setSpeechRate(settings.speechRate);
    await _flutterTts.setPitch(settings.pitch);

    if (settings.selectedVoiceName != null) {
      final voice = _japaneseVoices
          .where((v) => v['name'] == settings.selectedVoiceName)
          .firstOrNull;
      if (voice != null) {
        await _flutterTts.setVoice(voice);
        return;
      }
    }

    await _selectVoiceByGender(settings.voiceGender);
  }

  Future<void> _selectVoiceByGender(String gender) async {
    if (_japaneseVoices.isEmpty) return;

    final preferred = _japaneseVoices.where((v) {
      final name = v['name']?.toLowerCase() ?? '';
      if (gender == 'male') {
        return name.contains('jab') ||
            name.contains('jad') ||
            name.contains('male');
      } else {
        return name.contains('jac') ||
            name.contains('htm') ||
            name.contains('female');
      }
    }).toList();

    if (preferred.isNotEmpty) {
      await _flutterTts.setVoice(preferred.first);
    }
  }

  Future<void> speakJapanese(String text) async {
    await init();

    if (_currentSettings?.engine == 'google_cloud' && _cloudTts.isConfigured) {
      // Google Cloud TTS 사용
      final rate = _currentSettings!.speechRate * 2; // 0~1 → 0~2 범위 변환
      final pitch = (_currentSettings!.pitch - 1.0) * 10; // 피치 범위 변환
      await _cloudTts.speak(
        text,
        voiceName: _currentSettings!.cloudVoiceName,
        speakingRate: rate.clamp(0.25, 4.0),
        pitch: pitch.clamp(-20.0, 20.0),
      );
    } else {
      // 기기 TTS 사용
      await _flutterTts.setLanguage('ja-JP');
      await _flutterTts.speak(text);
    }
  }

  Future<void> speakKorean(String text) async {
    await init();
    // 한국어는 항상 기기 TTS 사용
    await _flutterTts.setLanguage('ko-KR');
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    await _cloudTts.stop();
  }

  void dispose() {
    _flutterTts.stop();
    _cloudTts.dispose();
  }
}
