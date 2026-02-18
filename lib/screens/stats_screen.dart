import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _isWeekly = true;

  int get _days => _isWeekly ? 7 : 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a2e),
        foregroundColor: Colors.white,
        title: const Text('학습 통계'),
        centerTitle: true,
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, provider, _) {
          final studyData = provider.studyCountByDate(_days);
          final quizTrend = provider.quizAccuracyTrend(_days);
          final quizByDifficulty = provider.quizStatsByDifficulty;

          return Column(
            children: [
              // 주간/월간 토글
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildToggleButton('주간', _isWeekly, () {
                      setState(() => _isWeekly = true);
                    }),
                    const SizedBox(width: 12),
                    _buildToggleButton('월간', !_isWeekly, () {
                      setState(() => _isWeekly = false);
                    }),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildDailyStudyChart(studyData),
                      const SizedBox(height: 24),
                      _buildQuizAccuracyChart(quizTrend),
                      const SizedBox(height: 24),
                      _buildDifficultyChart(quizByDifficulty),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildToggleButton(
      String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF667eea)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ─── 1. 일별 학습량 (Stacked BarChart) ───

  Widget _buildDailyStudyChart(Map<String, Map<String, int>> data) {
    final entries = data.entries.toList();
    final hasData = entries.any((e) =>
        e.value['word']! > 0 ||
        e.value['sentence']! > 0 ||
        e.value['quiz']! > 0);

    return _chartCard(
      title: '일별 학습량',
      child: hasData
          ? SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _calcMaxY(entries),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipRoundedRadius: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final entry = entries[group.x.toInt()];
                        final date = entry.key.substring(5); // MM-DD
                        final w = entry.value['word']!;
                        final s = entry.value['sentence']!;
                        final q = entry.value['quiz']!;
                        return BarTooltipItem(
                          '$date\n단어: $w  문장: $s  퀴즈: $q',
                          const TextStyle(
                              color: Colors.white, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          if (value == meta.max) return const SizedBox.shrink();
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= entries.length) {
                            return const SizedBox.shrink();
                          }
                          final label = _bottomLabel(entries[idx].key);
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              label,
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 9),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.white.withValues(alpha: 0.05),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(entries.length, (i) {
                    final e = entries[i].value;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: (e['word']! + e['sentence']! + e['quiz']!)
                              .toDouble(),
                          width: _isWeekly ? 18 : 6,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                          rodStackItems: [
                            BarChartRodStackItem(
                                0,
                                e['word']!.toDouble(),
                                const Color(0xFF667eea)),
                            BarChartRodStackItem(
                                e['word']!.toDouble(),
                                (e['word']! + e['sentence']!).toDouble(),
                                const Color(0xFF764ba2)),
                            BarChartRodStackItem(
                                (e['word']! + e['sentence']!).toDouble(),
                                (e['word']! + e['sentence']! + e['quiz']!)
                                    .toDouble(),
                                const Color(0xFFe96743)),
                          ],
                        ),
                      ],
                    );
                  }),
                ),
              ),
            )
          : _emptyState('학습 기록이 없습니다'),
      legend: const [
        _LegendItem(color: Color(0xFF667eea), label: '단어'),
        _LegendItem(color: Color(0xFF764ba2), label: '문장'),
        _LegendItem(color: Color(0xFFe96743), label: '퀴즈'),
      ],
    );
  }

  double _calcMaxY(List<MapEntry<String, Map<String, int>>> entries) {
    double max = 0;
    for (final e in entries) {
      final sum =
          (e.value['word']! + e.value['sentence']! + e.value['quiz']!)
              .toDouble();
      if (sum > max) max = sum;
    }
    return max < 1 ? 5 : (max * 1.2).ceilToDouble();
  }

  String _bottomLabel(String dateStr) {
    if (_isWeekly) {
      final date = DateTime.parse(dateStr);
      const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
      return weekdays[date.weekday - 1];
    } else {
      return dateStr.substring(8); // DD
    }
  }

  // ─── 2. 퀴즈 정답률 추이 (LineChart) ───

  Widget _buildQuizAccuracyChart(List<Map<String, dynamic>> trend) {
    return _chartCard(
      title: '퀴즈 정답률 추이',
      child: trend.isEmpty
          ? _emptyState('퀴즈 기록이 없습니다')
          : SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipRoundedRadius: 8,
                      getTooltipItems: (spots) {
                        return spots.map((spot) {
                          final date =
                              trend[spot.spotIndex]['date'] as String;
                          return LineTooltipItem(
                            '${date.substring(5)}\n${spot.y.toStringAsFixed(1)}%',
                            const TextStyle(
                                color: Colors.white, fontSize: 12),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: 25,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: trend.length > 7
                            ? (trend.length / 5).ceilToDouble()
                            : 1,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= trend.length) {
                            return const SizedBox.shrink();
                          }
                          final date = trend[idx]['date'] as String;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              date.substring(5),
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 9),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.white.withValues(alpha: 0.05),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        trend.length,
                        (i) => FlSpot(
                            i.toDouble(), (trend[i]['rate'] as double)),
                      ),
                      isCurved: true,
                      preventCurveOverShooting: true,
                      color: const Color(0xFF43a047),
                      barWidth: 3,
                      dotData: FlDotData(
                        show: trend.length <= 14,
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color:
                            const Color(0xFF43a047).withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ─── 3. 난이도별 퀴즈 성적 (BarChart) ───

  Widget _buildDifficultyChart(
      Map<String, Map<String, dynamic>> quizStats) {
    final levels = ['N5', 'N4', 'N3', 'N2', 'N1'];
    final hasData =
        levels.any((l) => (quizStats[l]!['quizCount'] as int) > 0);

    final colors = [
      const Color(0xFF43a047),
      const Color(0xFFf5a623),
      const Color(0xFFe96743),
      const Color(0xFF5c6bc0),
      const Color(0xFF9c27b0),
    ];

    return _chartCard(
      title: '난이도별 퀴즈 성적',
      child: hasData
          ? SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipRoundedRadius: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final level = levels[group.x.toInt()];
                        final count =
                            quizStats[level]!['quizCount'] as int;
                        return BarTooltipItem(
                          '$level\n${rod.toY.toStringAsFixed(1)}% ($count회)',
                          const TextStyle(
                              color: Colors.white, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: 25,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= levels.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              levels[idx],
                              style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.white.withValues(alpha: 0.05),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(levels.length, (i) {
                    final rate =
                        (quizStats[levels[i]]!['avgRate'] as double);
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: rate,
                          width: 28,
                          color: colors[i],
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6)),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            )
          : _emptyState('퀴즈 기록이 없습니다'),
    );
  }

  // ─── Shared Widgets ───

  Widget _chartCard({
    required String title,
    required Widget child,
    List<_LegendItem>? legend,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (legend != null)
                Row(
                  children: legend
                      .map((l) => Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: l.color,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l.label,
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 11),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
    return SizedBox(
      height: 160,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart, color: Colors.white24, size: 48),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});
}
