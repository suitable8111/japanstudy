import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class GoogleCloudTtsService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _apiKey;

  // 사용 가능한 일본어 음성 목록
  static const List<Map<String, String>> japaneseVoices = [
    {'name': 'ja-JP-Neural2-B', 'gender': 'male', 'label': '남성 1 (Neural2)', 'type': 'Neural2'},
    {'name': 'ja-JP-Neural2-C', 'gender': 'female', 'label': '여성 1 (Neural2)', 'type': 'Neural2'},
    {'name': 'ja-JP-Neural2-D', 'gender': 'male', 'label': '남성 2 (Neural2)', 'type': 'Neural2'},
    {'name': 'ja-JP-Wavenet-A', 'gender': 'female', 'label': '여성 1 (WaveNet)', 'type': 'WaveNet'},
    {'name': 'ja-JP-Wavenet-B', 'gender': 'female', 'label': '여성 2 (WaveNet)', 'type': 'WaveNet'},
    {'name': 'ja-JP-Wavenet-C', 'gender': 'male', 'label': '남성 1 (WaveNet)', 'type': 'WaveNet'},
    {'name': 'ja-JP-Wavenet-D', 'gender': 'male', 'label': '남성 2 (WaveNet)', 'type': 'WaveNet'},
    {'name': 'ja-JP-Standard-A', 'gender': 'female', 'label': '여성 (Standard)', 'type': 'Standard'},
    {'name': 'ja-JP-Standard-B', 'gender': 'female', 'label': '여성 2 (Standard)', 'type': 'Standard'},
    {'name': 'ja-JP-Standard-C', 'gender': 'male', 'label': '남성 (Standard)', 'type': 'Standard'},
    {'name': 'ja-JP-Standard-D', 'gender': 'male', 'label': '남성 2 (Standard)', 'type': 'Standard'},
  ];

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;

  Future<void> speak(String text, {
    String voiceName = 'ja-JP-Neural2-C',
    double speakingRate = 0.9,
    double pitch = 0.0,
  }) async {
    if (!isConfigured) return;

    final url = Uri.parse(
      'https://texttospeech.googleapis.com/v1/text:synthesize?key=$_apiKey',
    );

    final body = jsonEncode({
      'input': {'text': text},
      'voice': {
        'languageCode': 'ja-JP',
        'name': voiceName,
      },
      'audioConfig': {
        'audioEncoding': 'MP3',
        'speakingRate': speakingRate,
        'pitch': pitch,
      },
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final audioContent = data['audioContent'] as String;
        final bytes = base64Decode(audioContent);

        // 임시 파일로 저장 후 재생
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/tts_output.mp3');
        await file.writeAsBytes(bytes);

        await _audioPlayer.stop();
        await _audioPlayer.play(DeviceFileSource(file.path));
      }
    } catch (e) {
      // API 호출 실패 시 무시
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
