import 'package:flutter/material.dart';
import '../models/study_record.dart';
import 'word_study_screen.dart';
import 'sentence_study_screen.dart';
import 'kana_study_screen.dart';
import 'quiz_screen.dart';

class HistoryDetailScreen extends StatelessWidget {
  final StudyRecord record;

  const HistoryDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${record.date.year}.${record.date.month.toString().padLeft(2, '0')}.${record.date.day.toString().padLeft(2, '0')} '
        '${record.date.hour.toString().padLeft(2, '0')}:${record.date.minute.toString().padLeft(2, '0')}';
    final isQuiz = record.type.startsWith('quiz');

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: Text(record.typeLabel),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 요약 헤더
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  record.resultText,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _getTypeColor(record.type),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: const TextStyle(fontSize: 14, color: Colors.white54),
                ),
                if (isQuiz && record.correctCount != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '정답률: ${(record.correctCount! / record.totalCount * 100).round()}%',
                    style:
                        const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ],
            ),
          ),
          // 아이템 목록 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  '학습 내용',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const Spacer(),
                Text(
                  '${record.items.length}개',
                  style: const TextStyle(fontSize: 14, color: Colors.white54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 아이템 리스트
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: record.items.length,
              itemBuilder: (context, index) {
                final item = record.items[index];
                return _buildItemCard(index, item, isQuiz);
              },
            ),
          ),
          // 다시 공부하기 버튼
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToRestudy(context),
                  icon: const Icon(Icons.replay),
                  label: const Text('다시 공부하기',
                      style: TextStyle(fontSize: 17)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getTypeColor(record.type),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToRestudy(BuildContext context) {
    Widget? screen;
    switch (record.type) {
      case 'word':
        screen = const WordStudyScreen();
        break;
      case 'sentence':
        screen = const SentenceStudyScreen();
        break;
      case 'kana_hiragana':
        screen = const KanaStudyScreen(kanaType: 'hiragana');
        break;
      case 'kana_katakana':
        screen = const KanaStudyScreen(kanaType: 'katakana');
        break;
      case 'quiz_word':
        screen = QuizScreen(
            quizType: 'word', difficulty: record.difficulty ?? 'N5');
        break;
      case 'quiz_sentence':
        screen = QuizScreen(
            quizType: 'sentence', difficulty: record.difficulty ?? 'N5');
        break;
      case 'quiz_kana_hiragana':
        screen = const QuizScreen(quizType: 'kana_hiragana');
        break;
      case 'quiz_kana_katakana':
        screen = const QuizScreen(quizType: 'kana_katakana');
        break;
    }
    if (screen != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => screen!),
      );
    }
  }

  Widget _buildItemCard(int index, StudyItem item, bool isQuiz) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: isQuiz && item.isCorrect != null
              ? Border.all(
                  color: item.isCorrect!
                      ? Colors.green.withValues(alpha: 0.4)
                      : Colors.red.withValues(alpha: 0.4),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          children: [
            // 번호
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isQuiz && item.isCorrect != null
                    ? (item.isCorrect!
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.red.withValues(alpha: 0.3))
                    : Colors.white.withValues(alpha: 0.1),
              ),
              child: Center(
                child: isQuiz && item.isCorrect != null
                    ? Icon(
                        item.isCorrect! ? Icons.check : Icons.close,
                        size: 14,
                        color: item.isCorrect! ? Colors.green : Colors.red,
                      )
                    : Text(
                        '${index + 1}',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // 일본어
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.japanese,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.reading,
                    style:
                        const TextStyle(fontSize: 13, color: Colors.white54),
                  ),
                ],
              ),
            ),
            // 한국어
            Flexible(
              child: Text(
                item.korean,
                style: const TextStyle(fontSize: 15, color: Colors.white70),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'word':
        return const Color(0xFF667eea);
      case 'sentence':
        return const Color(0xFF764ba2);
      case 'quiz_word':
      case 'quiz_sentence':
        return const Color(0xFFe96743);
      default:
        return Colors.grey;
    }
  }
}
