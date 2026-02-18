import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/level_test_provider.dart';

class LevelTestScreen extends StatefulWidget {
  const LevelTestScreen({super.key});

  @override
  State<LevelTestScreen> createState() => _LevelTestScreenState();
}

class _LevelTestScreenState extends State<LevelTestScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LevelTestProvider>().startLevelTest();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('레벨 테스트'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          Consumer<LevelTestProvider>(
            builder: (_, provider, _) {
              if (provider.isCompleted || provider.questions.isEmpty) {
                return const SizedBox.shrink();
              }
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    provider.progressText,
                    style:
                        const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<LevelTestProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (provider.isCompleted) {
            return _buildResultScreen(context, provider);
          }

          if (provider.currentQuestion == null) {
            return const Center(
              child: Text('문제를 준비하는 중...',
                  style: TextStyle(color: Colors.white70)),
            );
          }

          return _buildQuizCard(context, provider);
        },
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context, LevelTestProvider provider) {
    final question = provider.currentQuestion!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (provider.currentIndex + 1) / provider.totalCount,
            backgroundColor: Colors.white12,
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFFab47bc)),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 8),
          // Current level badge + score
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getLevelColor(provider.currentLevel),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '현재 레벨: ${provider.currentLevel}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Text(
                '${provider.correctCount}',
                style: const TextStyle(color: Colors.green, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Question level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: _getLevelColor(question.level).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              question.level,
              style: TextStyle(
                  color: _getLevelColor(question.level), fontSize: 12),
            ),
          ),
          const Spacer(),
          // Japanese word
          Text(
            question.japanese,
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Reading
          Text(
            question.reading,
            style: const TextStyle(fontSize: 24, color: Colors.white60),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          IconButton(
            onPressed: () {
              provider.ttsService.speakJapanese(question.reading);
            },
            icon: const Icon(Icons.volume_up, size: 28),
            color: Colors.white54,
          ),
          const Spacer(),
          // 4 choices
          ...List.generate(4, (index) {
            final isSelected = question.selectedIndex == index;
            final isCorrectChoice =
                question.choices[index] == question.correctAnswer;

            Color bgColor = Colors.white.withValues(alpha: 0.1);
            Color borderColor = Colors.white24;
            Color textColor = Colors.white;

            if (question.isAnswered) {
              if (isCorrectChoice) {
                bgColor = Colors.green.withValues(alpha: 0.3);
                borderColor = Colors.green;
                textColor = Colors.green.shade200;
              } else if (isSelected && !isCorrectChoice) {
                bgColor = Colors.red.withValues(alpha: 0.3);
                borderColor = Colors.redAccent;
                textColor = Colors.red.shade200;
              } else {
                bgColor = Colors.white.withValues(alpha: 0.05);
                textColor = Colors.white38;
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: question.isAnswered
                      ? null
                      : () => provider.selectAnswer(index),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: question.isAnswered && isCorrectChoice
                                ? Colors.green
                                : question.isAnswered &&
                                        isSelected &&
                                        !isCorrectChoice
                                    ? Colors.redAccent
                                    : Colors.white.withValues(alpha: 0.15),
                          ),
                          child: Center(
                            child: question.isAnswered && isCorrectChoice
                                ? const Icon(Icons.check,
                                    size: 16, color: Colors.white)
                                : question.isAnswered &&
                                        isSelected &&
                                        !isCorrectChoice
                                    ? const Icon(Icons.close,
                                        size: 16, color: Colors.white)
                                    : Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                            color: textColor, fontSize: 14),
                                      ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            question.choices[index],
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor,
                              fontWeight:
                                  question.isAnswered && isCorrectChoice
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          // Next button
          if (question.isAnswered)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFab47bc),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  provider.currentIndex < provider.totalCount - 1
                      ? '다음 문제'
                      : '결과 보기',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildResultScreen(BuildContext context, LevelTestProvider provider) {
    final stats = provider.levelStats;
    final recommended = provider.recommendedLevel;
    final percentage = provider.totalCount > 0
        ? (provider.correctCount / provider.totalCount * 100).round()
        : 0;

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school, color: Color(0xFFab47bc), size: 80),
              const SizedBox(height: 24),
              const Text(
                '레벨 테스트 완료!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              // Recommended level
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getLevelColor(recommended).withValues(alpha: 0.4),
                      _getLevelColor(recommended).withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: _getLevelColor(recommended), width: 2),
                ),
                child: Column(
                  children: [
                    const Text(
                      '추천 레벨',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recommended,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: _getLevelColor(recommended),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Overall score
              Text(
                '총 정답률: $percentage% (${provider.correctCount}/${provider.totalCount})',
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 24),
              // Level-by-level breakdown
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '레벨별 정답률',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...['N5', 'N4', 'N3', 'N2', 'N1'].map((level) {
                      final total = stats[level]!['total']!;
                      final correct = stats[level]!['correct']!;
                      final rate =
                          total > 0 ? (correct / total * 100).round() : 0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getLevelColor(level),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                level,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: total > 0
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: correct / total,
                                        backgroundColor: Colors.white12,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                _getLevelColor(level)),
                                        minHeight: 8,
                                      ),
                                    )
                                  : Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.white12,
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 70,
                              child: Text(
                                total > 0 ? '$correct/$total ($rate%)' : '-',
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 12),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => provider.startLevelTest(),
                icon: const Icon(Icons.refresh),
                label: const Text('다시 테스트하기',
                    style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFab47bc),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '홈으로 돌아가기',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'N5':
        return const Color(0xFF43a047);
      case 'N4':
        return const Color(0xFFf5a623);
      case 'N3':
        return const Color(0xFFe96743);
      case 'N2':
        return const Color(0xFF5c6bc0);
      case 'N1':
        return const Color(0xFF9c27b0);
      default:
        return Colors.grey;
    }
  }
}
