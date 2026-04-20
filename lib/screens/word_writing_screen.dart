import 'package:flutter/material.dart';
import '../widgets/banner_ad_widget.dart';
import 'package:provider/provider.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart'
    as mlkit;
import '../models/word.dart';
import '../providers/word_provider.dart';
import '../widgets/recognition_canvas.dart';
import '../providers/tts_settings_provider.dart';

class WordWritingScreen extends StatefulWidget {
  final String? level;

  const WordWritingScreen({super.key, this.level});

  @override
  State<WordWritingScreen> createState() => _WordWritingScreenState();
}

class _WordWritingScreenState extends State<WordWritingScreen> {
  List<Word> _wordList = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _modelReady = false;
  String? _modelError;
  bool _recognizing = false;
  String? _resultText;
  bool? _isCorrect;
  bool _hintShown = false;

  mlkit.DigitalInkRecognizer? _recognizer;
  final _strokesNotifier = ValueNotifier<List<List<TimedPoint>>>([]);

  @override
  void initState() {
    super.initState();
    _loadWords();
    _downloadAndInitModel();
  }

  Future<void> _loadWords() async {
    final provider = context.read<WordProvider>();
    await provider.startTest(level: widget.level);
    if (mounted) {
      setState(() {
        _wordList = List.from(provider.studyWords);
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadAndInitModel() async {
    const languageTag = 'ja';
    try {
      final modelManager = mlkit.DigitalInkRecognizerModelManager();
      final isDownloaded = await modelManager.isModelDownloaded(languageTag);
      if (!isDownloaded) {
        // isWifiRequired: false — WiFi 없이도 다운로드 허용
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

  void _clearCanvas() {
    _strokesNotifier.value = [];
    setState(() {
      _resultText = null;
      _isCorrect = null;
    });
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
      final correct = candidates
          .take(10)
          .any((c) => c.text == _wordList[_currentIndex].japanese);

      if (mounted) {
        setState(() {
          _recognizing = false;
          _isCorrect = correct;
          _resultText =
              candidates.isNotEmpty ? candidates.first.text : '(인식 실패)';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _recognizing = false;
          _resultText = '(인식 오류)';
          _isCorrect = false;
        });
      }
    }
  }

  void _goNext() {
    if (_currentIndex < _wordList.length - 1) {
      setState(() {
        _currentIndex++;
        _hintShown = false;
      });
      _strokesNotifier.value = [];
      setState(() {
        _resultText = null;
        _isCorrect = null;
      });
    }
  }

  void _goPrev() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _hintShown = false;
      });
      _strokesNotifier.value = [];
      setState(() {
        _resultText = null;
        _isCorrect = null;
      });
    }
  }

  @override
  void dispose() {
    _recognizer?.close();
    _strokesNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.level != null
        ? '단어 써보기 (${widget.level})'
        : '단어 써보기';

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading && _wordList.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${_currentIndex + 1} / ${_wordList.length}',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const BannerAdWidget(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _wordList.isEmpty
              ? const Center(
                  child: Text(
                    '단어가 없습니다.',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    final word = _wordList[_currentIndex];

    return Column(
      children: [
        // 모델 상태 배너
        if (_modelError != null)
          Container(
            width: double.infinity,
            color: Colors.red.withValues(alpha: 0.8),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _modelError!,
                    style:
                        const TextStyle(color: Colors.white, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: _retryModelDownload,
                  child: const Text('재시도',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          )
        else if (!_modelReady)
          Container(
            width: double.infinity,
            color: const Color(0xFF5c6bc0).withValues(alpha: 0.8),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'ML Kit 일본어 모델 다운로드 중...',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 진행 표시
                Text(
                  '진행: ${_currentIndex + 1} / ${_wordList.length}',
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // 한국어 뜻
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        word.meaning(context.read<TtsSettingsProvider>().displayLanguage),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_hintShown) ...[
                        const SizedBox(height: 8),
                        Text(
                          word.reading,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 힌트 버튼
                if (!_hintShown)
                  TextButton.icon(
                    onPressed: () => setState(() => _hintShown = true),
                    icon: const Icon(Icons.lightbulb_outline,
                        color: Colors.amber, size: 18),
                    label: const Text(
                      '힌트 보기 (읽기)',
                      style: TextStyle(color: Colors.amber),
                    ),
                  ),

                const SizedBox(height: 16),

                // 필기 캔버스
                SizedBox(
                  height: 220,
                  child: RecognitionCanvas(strokesNotifier: _strokesNotifier),
                ),
                const SizedBox(height: 16),

                // 결과 영역
                if (_resultText != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (_isCorrect == true
                              ? Colors.green
                              : Colors.red)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isCorrect == true ? Colors.green : Colors.red,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isCorrect == true
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: _isCorrect == true
                                  ? Colors.green
                                  : Colors.red,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isCorrect == true ? '正解！' : '틀렸습니다',
                              style: TextStyle(
                                color: _isCorrect == true
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '인식: $_resultText',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 15),
                        ),
                        Text(
                          '정답: ${word.japanese}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 15),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // 하단 버튼
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                // 이전
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _currentIndex > 0 ? _goPrev : null,
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('이전'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side:
                          const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 지우기
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearCanvas,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('지우기'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side:
                          const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 확인 / 다음
                Expanded(
                  child: _resultText == null
                      ? ElevatedButton.icon(
                          onPressed:
                              (!_modelReady || _recognizing) ? null : _recognize,
                          icon: _recognizing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check, size: 18),
                          label: Text(_recognizing ? '인식 중...' : '확인'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5c6bc0),
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: _currentIndex < _wordList.length - 1
                              ? _goNext
                              : null,
                          icon: const Icon(Icons.arrow_forward, size: 18),
                          label: _currentIndex < _wordList.length - 1
                              ? const Text('다음')
                              : const Text('완료'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF43a047),
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
