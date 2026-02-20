import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/kana.dart';
import '../providers/kana_provider.dart';
import '../services/kana_service.dart';
import '../widgets/drawing_canvas.dart';

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
  final ValueNotifier<List<List<Offset>>> _strokesNotifier =
      ValueNotifier([]);

  List<Kana> _kanaList = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _revealed = false;
  bool _transitioning = false;

  bool get _isHiragana => widget.kanaType == 'hiragana';
  String get _title {
    final typeName = _isHiragana ? '히라가나' : '가타카나';
    return widget.blindMode ? '$typeName 써보기 (발음만)' : '$typeName 써보기';
  }
  MaterialColor get _themeColor => _isHiragana ? Colors.teal : Colors.orange;

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
  }

  Future<void> _loadData() async {
    await _kanaService.loadKana();
    final allKana = _kanaService.getKanaByType(widget.kanaType);
    final seionRows = _isHiragana ? _seionHiragana : _seionKatakana;
    final seionKana =
        allKana.where((k) => seionRows.contains(k.row)).toList();

    if (widget.shuffle) {
      seionKana.shuffle();
    }

    setState(() {
      _kanaList = seionKana;
      _isLoading = false;
    });

    if (_kanaList.isNotEmpty) {
      _speakCurrent();
    }
  }

  void _speakCurrent() {
    final ttsService = context.read<KanaProvider>().ttsService;
    ttsService.speakJapanese(_kanaList[_currentIndex].japanese);
  }

  void _clearCanvas() {
    _strokesNotifier.value = [];
  }

  void _prevKana() {
    if (_currentIndex <= 0) return;
    setState(() {
      _currentIndex--;
      _revealed = false;
    });
    _clearCanvas();
    _speakCurrent();
  }

  Future<void> _nextKana() async {
    if (_transitioning) return;

    // 정답을 1초 보여주고 넘어감
    setState(() {
      _revealed = true;
      _transitioning = true;
    });

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    if (_currentIndex >= _kanaList.length - 1) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _currentIndex++;
      _revealed = false;
      _transitioning = false;
    });
    _clearCanvas();
    _speakCurrent();
  }

  @override
  void dispose() {
    _strokesNotifier.dispose();
    super.dispose();
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
                      if (widget.blindMode && !_revealed)
                        Text(
                          '?',
                          style: TextStyle(
                            fontSize: 80,
                            color: _themeColor.shade200,
                            fontWeight: FontWeight.w300,
                          ),
                        )
                      else
                        Text(
                          _kanaList[_currentIndex].japanese,
                          style: const TextStyle(
                            fontSize: 80,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      const SizedBox(height: 4),
                      // Korean + romanji
                      if (widget.blindMode && !_revealed)
                        Text(
                          _kanaList[_currentIndex].korean,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        )
                      else
                        Text(
                          '${_kanaList[_currentIndex].korean} (${_kanaList[_currentIndex].reading})',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                      const SizedBox(height: 16),
                      // Canvas
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: DrawingCanvas(
                              strokesNotifier: _strokesNotifier),
                        ),
                      ),
                      // Blind mode: 다시 듣기 + 정답 보기 버튼
                      if (widget.blindMode)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
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
                                      color: _themeColor.withValues(alpha: 0.5),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _revealed
                                      ? null
                                      : () => setState(() => _revealed = true),
                                  icon: Icon(
                                    _revealed ? Icons.visibility : Icons.visibility_off,
                                    size: 20,
                                  ),
                                  label: Text(_revealed ? '정답 표시중' : '정답 보기'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.amber.shade200,
                                    disabledForegroundColor: Colors.white38,
                                    side: BorderSide(
                                      color: _revealed
                                          ? Colors.white24
                                          : Colors.amber.withValues(alpha: 0.5),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Buttons: 이전 / 지우기 / 다음
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _currentIndex > 0 ? _prevKana : null,
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _clearCanvas,
                                icon: const Icon(Icons.refresh, size: 20),
                                label: const Text('지우기'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                  side: BorderSide(
                                    color:
                                        Colors.white.withValues(alpha: 0.3),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _transitioning ? null : _nextKana,
                                icon: _transitioning
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white70,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(
                                        _currentIndex >= _kanaList.length - 1
                                            ? Icons.check
                                            : Icons.arrow_forward,
                                        size: 20,
                                      ),
                                label: Text(
                                  _transitioning
                                      ? ''
                                      : _currentIndex >= _kanaList.length - 1
                                          ? '완료'
                                          : '다음',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _themeColor,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
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
