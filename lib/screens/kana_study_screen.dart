import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/kana.dart';
import '../providers/kana_provider.dart';
import '../providers/history_provider.dart';

class KanaStudyScreen extends StatefulWidget {
  final String kanaType; // 'hiragana' or 'katakana'

  const KanaStudyScreen({super.key, required this.kanaType});

  @override
  State<KanaStudyScreen> createState() => _KanaStudyScreenState();
}

class _KanaStudyScreenState extends State<KanaStudyScreen> {
  String? _activeTappedId;
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KanaProvider>().loadKanaData(widget.kanaType);
    });
  }

  bool get _isHiragana => widget.kanaType == 'hiragana';
  String get _title => _isHiragana ? '히라가나 공부' : '가타카나 공부';
  MaterialColor get _themeColor => _isHiragana ? Colors.teal : Colors.orange;

  // 청음 rows (basic)
  static const _seionHiragana = {
    'あ행', 'か행', 'さ행', 'た행', 'な행', 'は행', 'ま행', 'や행', 'ら행', 'わ행'
  };
  static const _seionKatakana = {
    'ア행', 'カ행', 'サ행', 'タ행', 'ナ행', 'ハ행', 'マ행', 'ヤ행', 'ラ행', 'ワ행'
  };
  // 탁음 rows (dakuten)
  static const _dakuonHiragana = {'が행', 'ざ행', 'だ행', 'ば행'};
  static const _dakuonKatakana = {'ガ행', 'ザ행', 'ダ행', 'バ행'};
  // 반탁음 rows (handakuten)
  static const _handakuonHiragana = {'ぱ행'};
  static const _handakuonKatakana = {'パ행'};

  Set<String> get _seionRows => _isHiragana ? _seionHiragana : _seionKatakana;
  Set<String> get _dakuonRows =>
      _isHiragana ? _dakuonHiragana : _dakuonKatakana;
  Set<String> get _handakuonRows =>
      _isHiragana ? _handakuonHiragana : _handakuonKatakana;

  Map<String, List<Kana>> _groupByRow(List<Kana> kanaList) {
    final map = <String, List<Kana>>{};
    for (final k in kanaList) {
      map.putIfAbsent(k.row, () => []).add(k);
    }
    return map;
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
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showAll = !_showAll;
                if (!_showAll) _activeTappedId = null;
              });
            },
            icon: Icon(
              _showAll ? Icons.visibility_off : Icons.visibility,
              size: 18,
              color: _themeColor.shade200,
            ),
            label: Text(
              _showAll ? '숨기기' : '전체 보기',
              style: TextStyle(color: _themeColor.shade200, fontSize: 13),
            ),
          ),
        ],
      ),
      body: Consumer<KanaProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (provider.studyKana.isEmpty) {
            return const Center(
              child: Text(
                '음절을 불러오는 중...',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final grouped = _groupByRow(provider.studyKana);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    _buildSection('청음 (기본)', grouped, _seionRows),
                    _buildSection('탁음', grouped, _dakuonRows),
                    _buildSection('반탁음', grouped, _handakuonRows),
                  ],
                ),
              ),
              _buildCompleteButton(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(
    String label,
    Map<String, List<Kana>> grouped,
    Set<String> rowKeys,
  ) {
    final rows = rowKeys.where((r) => grouped.containsKey(r)).toList();
    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Divider(color: _themeColor.withValues(alpha: 0.4))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _themeColor.withValues(alpha: 0.8),
                ),
              ),
            ),
            Expanded(child: Divider(color: _themeColor.withValues(alpha: 0.4))),
          ],
        ),
        const SizedBox(height: 12),
        ...rows.map((row) => _buildRow(row, grouped[row]!)),
      ],
    );
  }

  // や행/ヤ행: ya=0, yu=2, yo=4 (5열 그리드 기준)
  static const _yaPositionMap = {'ya': 0, 'yu': 2, 'yo': 4};

  // わ행/ワ행: wa=0, wo=4 (ん은 별도 6번째 칸)
  static const _waPositionMap = {'wa': 0, 'wo': 4};

  bool _isYaRow(String rowLabel) =>
      rowLabel == 'や행' || rowLabel == 'ヤ행';
  bool _isWaRow(String rowLabel) =>
      rowLabel == 'わ행' || rowLabel == 'ワ행';

  Widget _buildRow(String rowLabel, List<Kana> kanaList) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final labelWidth = 48.0;
          final availableWidth = constraints.maxWidth - labelWidth;
          // 5열 기준 타일 크기 계산 (간격 포함)
          final spacing = 6.0;
          final tileWidth = (availableWidth - spacing * 4) / 5;
          final tileHeight = tileWidth * 1.14; // 비율 유지

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: labelWidth,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    rowLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: _themeColor.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _isYaRow(rowLabel) || _isWaRow(rowLabel)
                    ? _buildGridRow(kanaList, rowLabel, tileWidth, tileHeight, spacing)
                    : Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: kanaList
                            .map((kana) => _buildKanaTile(kana, tileWidth, tileHeight))
                            .toList(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGridRow(List<Kana> kanaList, String rowLabel,
      double tileWidth, double tileHeight, double spacing) {
    final isYa = _isYaRow(rowLabel);
    final posMap = isYa ? _yaPositionMap : _waPositionMap;

    // 5열 그리드 생성
    List<Widget> cells = [];
    // ん은 わ행에서 별도 처리
    Kana? nKana;

    // reading → position 매핑
    Map<int, Kana> positioned = {};
    for (final kana in kanaList) {
      if (_isWaRow(rowLabel) && kana.reading == 'n') {
        nKana = kana;
      } else if (posMap.containsKey(kana.reading)) {
        positioned[posMap[kana.reading]!] = kana;
      }
    }

    for (int i = 0; i < 5; i++) {
      if (i > 0) cells.add(SizedBox(width: spacing));
      if (positioned.containsKey(i)) {
        cells.add(_buildKanaTile(positioned[i]!, tileWidth, tileHeight));
      } else {
        cells.add(SizedBox(width: tileWidth, height: tileHeight));
      }
    }

    // ん은 5번째 칸 뒤에 추가
    if (nKana != null) {
      cells.add(SizedBox(width: spacing));
      cells.add(_buildKanaTile(nKana, tileWidth, tileHeight));
    }

    return Row(children: cells);
  }

  Widget _buildKanaTile(Kana kana, double width, double height) {
    final isTapped = _showAll || _activeTappedId == kana.id;
    final japaneseSize = (width * 0.42).clamp(18.0, 36.0);
    final readingSize = (width * 0.17).clamp(8.0, 13.0);
    final koreanSize = (width * 0.2).clamp(9.0, 15.0);

    return GestureDetector(
      onTap: () {
        setState(() => _activeTappedId = _activeTappedId == kana.id ? null : kana.id);
        context.read<KanaProvider>().ttsService.speakJapanese(kana.japanese);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isTapped
              ? _themeColor.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isTapped
                ? _themeColor.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              kana.japanese,
              style: TextStyle(
                fontSize: japaneseSize,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isTapped) ...[
              Text(
                kana.korean,
                style: TextStyle(
                  fontSize: koreanSize,
                  fontWeight: FontWeight.w600,
                  color: _themeColor.shade200,
                ),
              ),
              Text(
                kana.reading,
                style: TextStyle(
                  fontSize: readingSize,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ] else
              Text(
                kana.reading,
                style: TextStyle(
                  fontSize: readingSize,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteButton(KanaProvider provider) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              context
                  .read<HistoryProvider>()
                  .addRecord(provider.buildRecord());
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check_circle_outline),
            label:
                const Text('학습 완료', style: TextStyle(fontSize: 17)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _themeColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
