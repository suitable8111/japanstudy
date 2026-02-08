import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/history_provider.dart';

class QuizScreen extends StatefulWidget {
  final String quizType; // 'word' or 'sentence'

  const QuizScreen({super.key, required this.quizType});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().startQuiz(widget.quizType);
    });
  }

  @override
  Widget build(BuildContext context) {
    final typeLabel = widget.quizType == 'word' ? '단어' : '문장';

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: Text('$typeLabel 퀴즈'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          Consumer<QuizProvider>(
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
      body: Consumer<QuizProvider>(
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

  Widget _buildQuizCard(BuildContext context, QuizProvider provider) {
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
                const AlwaysStoppedAnimation<Color>(Color(0xFFe96743)),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 8),
          // Score
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Text(
                '${provider.correctCount}',
                style: const TextStyle(color: Colors.green, fontSize: 14),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.cancel, color: Colors.redAccent, size: 16),
              const SizedBox(width: 4),
              Text(
                '${provider.currentIndex - provider.correctCount + (question.isAnswered && !question.isCorrect ? 1 : 0)}',
                style:
                    const TextStyle(color: Colors.redAccent, fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          // Japanese text
          Text(
            question.japanese,
            style: TextStyle(
              fontSize: widget.quizType == 'word' ? 48 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Reading
          Text(
            question.reading,
            style: const TextStyle(fontSize: 18, color: Colors.white60),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Replay TTS
          IconButton(
            onPressed: () {
              provider.ttsService.speakJapanese(widget.quizType == 'word'
                  ? question.reading
                  : question.japanese);
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
                              fontWeight: question.isAnswered && isCorrectChoice
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
          // Next button (after answering)
          if (question.isAnswered)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFe96743),
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

  Widget _buildResultScreen(BuildContext context, QuizProvider provider) {
    final percentage =
        provider.totalCount > 0
            ? (provider.correctCount / provider.totalCount * 100).round()
            : 0;

    // 히스토리 저장
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final historyProvider = context.read<HistoryProvider>();
      final record = provider.buildRecord();
      // 중복 저장 방지: ID 기반 확인
      if (!historyProvider.records.any((r) => r.id == record.id)) {
        historyProvider.addRecord(record);
      }
    });

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              percentage >= 80
                  ? Icons.emoji_events
                  : percentage >= 50
                      ? Icons.thumb_up
                      : Icons.school,
              color: const Color(0xFFe96743),
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              '퀴즈 완료!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Score circle
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: percentage >= 80
                      ? Colors.green
                      : percentage >= 50
                          ? Colors.orange
                          : Colors.redAccent,
                  width: 4,
                ),
              ),
              child: Center(
                child: Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: percentage >= 80
                        ? Colors.green
                        : percentage >= 50
                            ? Colors.orange
                            : Colors.redAccent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${provider.correctCount} / ${provider.totalCount} 정답',
              style: const TextStyle(fontSize: 20, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              percentage >= 80
                  ? '훌륭합니다!'
                  : percentage >= 50
                      ? '잘하고 있어요!'
                      : '조금 더 연습해봐요!',
              style: const TextStyle(fontSize: 16, color: Colors.white54),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => provider.startQuiz(widget.quizType),
              icon: const Icon(Icons.refresh),
              label:
                  const Text('다시 도전하기', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFe96743),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
    );
  }
}
