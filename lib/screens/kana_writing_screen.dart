import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/kana.dart';
import '../providers/kana_provider.dart';
import '../services/kana_service.dart';
import '../widgets/drawing_canvas.dart';

class KanaWritingScreen extends StatefulWidget {
  final String kanaType; // 'hiragana' or 'katakana'

  const KanaWritingScreen({super.key, required this.kanaType});

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

  bool get _isHiragana => widget.kanaType == 'hiragana';
  String get _title => _isHiragana ? '히라가나 써보기' : '가타카나 써보기';
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

  void _nextKana() {
    if (_currentIndex >= _kanaList.length - 1) {
      // Last character — go back
      Navigator.pop(context);
      return;
    }
    setState(() {
      _currentIndex++;
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
                      // Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        child: Row(
                          children: [
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
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
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
