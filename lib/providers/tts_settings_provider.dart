import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TtsSettingsProvider extends ChangeNotifier {
  // 공통 설정
  String _engine = 'device'; // 'device' or 'google_cloud'
  double _speechRate = 0.45;
  double _pitch = 1.05;
  String _voiceGender = 'female';

  // 기기 TTS 설정
  String? _selectedVoiceName;
  List<Map<String, String>> _availableVoices = [];

  // Google Cloud TTS 설정
  String _apiKey = '';
  String _cloudVoiceName = 'ja-JP-Neural2-C';

  // Getters
  String get engine => _engine;
  double get speechRate => _speechRate;
  double get pitch => _pitch;
  String get voiceGender => _voiceGender;
  String? get selectedVoiceName => _selectedVoiceName;
  List<Map<String, String>> get availableVoices => _availableVoices;
  String get apiKey => _apiKey;
  String get cloudVoiceName => _cloudVoiceName;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _engine = prefs.getString('tts_engine') ?? 'device';
    _speechRate = prefs.getDouble('tts_speech_rate') ?? 0.45;
    _pitch = prefs.getDouble('tts_pitch') ?? 1.05;
    _voiceGender = prefs.getString('tts_voice_gender') ?? 'female';
    _selectedVoiceName = prefs.getString('tts_voice_name');
    _apiKey = prefs.getString('tts_api_key') ?? '';
    _cloudVoiceName = prefs.getString('tts_cloud_voice') ?? 'ja-JP-Neural2-C';
    notifyListeners();
  }

  Future<void> setEngine(String engine) async {
    _engine = engine;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tts_engine', engine);
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_speech_rate', rate);
  }

  Future<void> setPitch(double pitch) async {
    _pitch = pitch;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_pitch', pitch);
  }

  Future<void> setVoiceGender(String gender) async {
    _voiceGender = gender;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tts_voice_gender', gender);
  }

  Future<void> setSelectedVoiceName(String? name) async {
    _selectedVoiceName = name;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (name != null) {
      await prefs.setString('tts_voice_name', name);
    } else {
      await prefs.remove('tts_voice_name');
    }
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tts_api_key', key);
  }

  Future<void> setCloudVoiceName(String name) async {
    _cloudVoiceName = name;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tts_cloud_voice', name);
  }

  void setAvailableVoices(List<Map<String, String>> voices) {
    _availableVoices = voices;
    notifyListeners();
  }
}
