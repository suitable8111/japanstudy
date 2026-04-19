import 'package:flutter/material.dart';
import '../widgets/banner_ad_widget.dart';
import 'package:provider/provider.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart'
    as mlkit;
import '../models/kana.dart';
import '../providers/kana_provider.dart';
import '../services/kana_service.dart';
import '../widgets/recognition_canvas.dart';

class KanaWritingScreen extends StatefulWidget {
  final String kanaType; // 'hiragana' or 'katakana'
  final bool shuffle;
  final bool blindMode; // 글자를 가리고 발음/음절만으로 써보기

  const KanaWritingScreen({
    super.key,
    required this.kanaType,
    this.shuffle = false,
    this.blindMode = false,
  });

  @override
  State<KanaWritingScreen> createState() => _KanaWritingScreenState();
}

class _KanaWritingScreenState extends State<KanaWritingScreen> {
  final KanaService _kanaService = KanaService();
  final ValueNotifier<List<List<TimedPoint>>> _strokesNotifier =
      ValueNotifier([]);

  List<Kana> _kanaList = [];
  List<Kana> _pairedKanaList = []; // 'both' 모드: 가타카나 병렬 리스트
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _revealed = false;

  // ML Kit 상태
  bool _modelReady = false;
  String? _modelError;
  bool _recognizing = false;
  String? _resultText;
  bool? _isCorrect;
  mlkit.DigitalInkRecognizer? _recognizer;

  bool get _isHiragana => widget.kanaType == 'hiragana';
  bool get _isBoth => widget.kanaType == 'both';
  String get _title {
    final typeName = _isBoth
        ? '히라가나 + 가타카나'
        : (_isHiragana ? '히라가나' : '가타카나');
    return widget.blindMode ? '$typeName 써보기 (발음만)' : '$typeName 써보기';
  }

  MaterialColor get _themeColor =>
      _isBoth ? Colors.deepPurple : (_isHiragana ? Colors.teal : Colors.orange);

  static const _seionHiragana = {
    'あ행', 'か행', 'さ행', 'た행', 'な행', 'は행', 'ま행', 'や행', 'ら행', 'わ행'
  };
  static const _seionKatakana = {
    'ア행', 'カ행', 'サ행', 'タ행', 'ナ행', 'ハ행', 'マ행', 'ヤ행', 'ラ행', 'ワ행'
  };

  @override
  void initState() {
    super.initState();
    _loadData();
    _downloadAndInitModel();
  }

  Future<void> _loadData() async {
    await _kanaService.loadKana();

    List<Kana> primary;
    List<Kana> paired = [];

    if (_isBoth) {
      final hiragana = _kanaService.getKanaByType('hiragana');
      final katakana = _kanaService.getKanaByType('katakana');
      final hSeion =
          hiragana.where((k) => _seionHiragana.contains(k.row)).toList();
      final kSeion =
          katakana.where((k) => _seionKatakana.contains(k.row)).toList();

      if (widget.shuffle) {
        final indices = List.generate(hSeion.length, (i) => i)..shuffle();
        primary = indices.map((i) => hSeion[i]).toList();
        paired = indices.map((i) => kSeion[i]).toList();
      } else {
        primary = hSeion;
        paired = kSeion;
      }
    } else {
      final allKana = _kanaService.getKanaByType(widget.kanaType);
      final seionRows = _isHiragana ? _seionHiragana : _seionKatakana;
      primary = allKana.where((k) => seionRows.contains(k.row)).toList();
      if (widget.shuffle) primary.shuffle();
    }

    setState(() {
      _kanaList = primary;
      _pairedKanaList = paired;
      _isLoading = false;
    });

    if (_kanaList.isNotEmpty) {
      _speakCurrent();
    }
  }

  Future<void> _downloadAndInitModel() async {
    const languageTag = 'ja';
    try {
      final modelManager = mlkit.DigitalInkRecognizerModelManager();
      final isDownloaded = await modelManager.isModelDownloaded(languageTag);
      if (!isDownloaded) {
        await modelManager.downloadModel(languageTag, isWifiRequired: false);
      }
      _recognizer = mlkit.DigitalInkRecognizer(languageCode: languageTag);
      if (mounted) {
        setState(() => _modelReady = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _modelError = '모델 다운로드 실패: $e');
      }
    }
  }

  Future<void> _retryModelDownload() async {
    setState(() {
      _modelError = null;
      _modelReady = false;
    });
    await _downloadAndInitModel();
  }

  void _speakCurrent() {
    final ttsService = context.read<KanaProvider>().ttsService;
    ttsService.speakJapanese(_kanaList[_currentIndex].japanese);
  }

  void _clearCanvas() {
    _strokesNotifier.value = [];
    setState(() {
      _resultText = null;
      _isCorrect = null;
      _revealed = false;
    });
  }

  void _prevKana() {
    if (_currentIndex <= 0) return;
    setState(() {
      _currentIndex--;
      _revealed = false;
      _resultText = null;
      _isCorrect = null;
    });
    _strokesNotifier.value = [];
    _speakCurrent();
  }

  void _nextKana() {
    if (_currentIndex >= _kanaList.length - 1) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _currentIndex++;
      _revealed = false;
      _resultText = null;
      _isCorrect = null;
    });
    _strokesNotifier.value = [];
    _speakCurrent();
  }

  Future<void> _recognize() async {
    final strokes = _strokesNotifier.value;
    if (strokes.isEmpty) return;

    setState(() => _recognizing = true);

    try {
      final ink = mlkit.Ink();
      ink.strokes = strokes.map((stroke) {
        final s = mlkit.Stroke();
        s.points = stroke
            .map((p) => mlkit.StrokePoint(x: p.x, y: p.y, t: p.t))
            .toList();
        return s;
      }).toList();

      final candidates = await _recognizer!.recognize(ink);
      final target = _kanaList[_currentIndex].japanese;
      final pairTarget =
          _isBoth ? _pairedKanaList[_currentIndex].japanese : null;

      final correct = candidates.take(10).any(
            (c) => c.text == target || (pairTarget != null && c.text == pairTarget),
          );

      if (mounted) {
        setState(() {
          _recognizing = false;
          _isCorrect = correct;
          _resultText =
              candidates.isNotEmpty ? candidates.first.text : '(인식 실패)';
          _revealed = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _recognizing = false;
          _resultText = '(인식 오류)';
          _isCorrect = false;
          _revealed = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _recognizer?.close();
    _strokesNotifier.dispose();
    super.dispose();
  }

  Widget _buildCharacterDisplay() {
    if (_isBoth) {
      final showQuestion = widget.blindMode && !_revealed;
      final hiraChar =
          showQuestion ? '?' : _kanaList[_currentIndex].japanese;
      final kataChar =
          showQuestion ? '?' : _pairedKanaList[_currentIndex].japanese;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text('ひ',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.teal.shade300,
                      fontWeight: FontWeight.bold)),
              Text(hiraChar,
                  style: TextStyle(
                      fontSize: 72,
                      color: Colors.teal.shade200,
                      fontWeight: FontWeight.w300)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
            child: Text('·',
                style: TextStyle(fontSize: 40, color: Colors.white24)),
          ),
          Column(
            children: [
              Text('カ',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.shade300,
                      fontWeight: FontWeight.bold)),
              Text(kataChar,
                  style: TextStyle(
                      fontSize: 72,
                      color: Colors.orange.shade200,
                      fontWeight: FontWeight.w300)),
            ],
          ),
        ],
      );
    }
    if (widget.blindMode && !_revealed) {
      return Text('?',
          style: TextStyle(
              fontSize: 80,
              color: _themeColor.shade200,
              fontWeight: FontWeight.w300));
    }
    return Text(_kanaList[_currentIndex].japanese,
        style: const TextStyle(
            fontSize: 80, color: Colors.white, fontWeight: FontWeight.w300));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: const BannerAdWidget(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : _kanaList.isEmpty
              ? const Center(
                  child: Text(
                    '데이터를 불러올 수 없습니다.',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : SafeArea(
                  child: Column(
                    children: [
                      // 모델 상태 배너
                      if (_modelError != null)
                        Container(
                          width: double.infinity,
                          color: Colors.red.withValues(alpha: 0.8),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _modelError!,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              TextButton(
                                onPressed: _retryModelDownload,
                                child: const Text('재시도',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12)),
                              ),
                            ],
                          ),
                        )
                      else if (!_modelReady)
                        Container(
                          width: double.infinity,
                          color: _themeColor.withValues(alpha: 0.7),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: const Row(
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              ),
                              SizedBox(width: 10),
                              Text('ML Kit 일본어 모델 준비 중...',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),

                      // Progress
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        child: Text(
                          '진행: ${_currentIndex + 1} / ${_kanaList.length}',
                          style: TextStyle(
                            color: _themeColor.shade200,
                            fontSize: 15,
                          ),
                        ),
                      ),

                      // Guide character
                      _buildCharacterDisplay(),
                      const SizedBox(height: 4),

                      // Korean + romanji
                      if (widget.blindMode && !_revealed)
                        Text(
                          _kanaList[_currentIndex].korean,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white70),
                        )
                      else
                        Text(
                          '${_kanaList[_currentIndex].korean} (${_kanaList[_currentIndex].reading})',
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white70),
                        ),
                      const SizedBox(height: 12),

                      // Canvas
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          child: RecognitionCanvas(
                              strokesNotifier: _strokesNotifier),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ML Kit 인식 결과
                      if (_resultText != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            decoration: BoxDecoration(
                              color: (_isCorrect == true
                                      ? Colors.green
                                      : Colors.red)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isCorrect == true
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isCorrect == true
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: _isCorrect == true
                                      ? Colors.green
                                      : Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isCorrect == true ? '正解！' : '틀렸습니다',
                                  style: TextStyle(
                                    color: _isCorrect == true
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '인식: $_resultText  정답: ${_kanaList[_currentIndex].japanese}',
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Blind mode 정답 보기 (결과 미표시 상태에서만)
                      if (widget.blindMode && _resultText == null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _speakCurrent,
                                  icon: const Icon(Icons.volume_up, size: 20),
                                  label: const Text('다시 듣기'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _themeColor.shade200,
                                    side: BorderSide(
                                        color: _themeColor
                                            .withValues(alpha: 0.5)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _revealed
                                      ? null
                                      : () =>
                                          setState(() => _revealed = true),
                                  icon: Icon(
                                    _revealed
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    size: 20,
                                  ),
                                  label: Text(
                                      _revealed ? '정답 표시중' : '정답 보기'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.amber.shade200,
                                    disabledForegroundColor: Colors.white38,
                                    side: BorderSide(
                                      color: _revealed
                                          ? Colors.white24
                                          : Colors.amber
                                              .withValues(alpha: 0.5),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 8),

                      // 하단 버튼: 이전 / 지우기 / 확인(다음)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        child: Row(
                          children: [
                            // 이전
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed:
                                    _currentIndex > 0 ? _prevKana : null,
                                icon: const Icon(Icons.arrow_back, size: 20),
                                label: const Text('이전'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                  disabledForegroundColor: Colors.white24,
                                  side: BorderSide(
                                    color: _currentIndex > 0
                                        ? Colors.white.withValues(alpha: 0.3)
                                        : Colors.white.withValues(alpha: 0.1),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // 지우기
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _clearCanvas,
                                icon:
                                    const Icon(Icons.refresh, size: 20),
                                label: const Text('지우기'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                  side: BorderSide(
                                    color:
                                        Colors.white.withValues(alpha: 0.3),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // 확인 / 다음
                            Expanded(
                              child: _resultText == null
                                  ? ElevatedButton.icon(
                                      onPressed: (!_modelReady || _recognizing)
                                          ? null
                                          : _recognize,
                                      icon: _recognizing
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(Icons.check, size: 20),
                                      label: Text(
                                          _recognizing ? '인식 중...' : '확인'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _themeColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                      ),
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: _nextKana,
                                      icon: Icon(
                                        _currentIndex >= _kanaList.length - 1
                                            ? Icons.check
                                            : Icons.arrow_forward,
                                        size: 20,
                                      ),
                                      label: Text(
                                        _currentIndex >= _kanaList.length - 1
                                            ? '완료'
                                            : '다음',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _themeColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
