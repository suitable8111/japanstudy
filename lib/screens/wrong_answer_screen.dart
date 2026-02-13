import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/study_record.dart';
import '../providers/history_provider.dart';
import '../providers/quiz_provider.dart';
import 'quiz_screen.dart';

class WrongAnswerScreen extends StatelessWidget {
  const WrongAnswerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF1a1a2e),
        appBar: AppBar(
          title: const Text('오답 노트'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Color(0xFFe96743),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: '전체'),
              Tab(text: '단어'),
              Tab(text: '문장'),
            ],
          ),
        ),
        body: Consumer<HistoryProvider>(
          builder: (context, historyProvider, _) {
            final allItems = historyProvider.wrongAnswerItems;
            final wordItems = historyProvider.wrongAnswersByType('word');
            final sentenceItems = historyProvider.wrongAnswersByType('sentence');

            return TabBarView(
              children: [
                _WrongAnswerTab(items: allItems, type: null),
                _WrongAnswerTab(items: wordItems, type: 'word'),
                _WrongAnswerTab(items: sentenceItems, type: 'sentence'),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WrongAnswerTab extends StatelessWidget {
  final List<StudyItem> items;
  final String? type; // null = 전체

  const _WrongAnswerTab({required this.items, required this.type});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.white24),
            SizedBox(height: 16),
            Text(
              '오답이 없습니다!',
              style: TextStyle(fontSize: 18, color: Colors.white54),
            ),
            SizedBox(height: 8),
            Text(
              '퀴즈를 풀면 틀린 문제가 여기에 표시됩니다',
              style: TextStyle(fontSize: 14, color: Colors.white30),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Column(
          children: [
            // 상단 요약
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assignment_late,
                      color: Colors.orangeAccent, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '총 ${items.length}개의 오답',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                    ),
                  ),
                ],
              ),
            ),
            // 오답 리스트
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildWrongAnswerCard(context, item);
                },
              ),
            ),
          ],
        ),
        // FAB: 오답 재도전
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton.extended(
            onPressed: () => _startWrongAnswerQuiz(context),
            backgroundColor: const Color(0xFFe96743),
            icon: const Icon(Icons.refresh, color: Colors.white),
            label:
                const Text('오답 재도전', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildWrongAnswerCard(BuildContext context, StudyItem item) {
    return Card(
      color: Colors.white.withValues(alpha: 0.08),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.read<QuizProvider>().ttsService.speakJapanese(item.reading);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.japanese,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.reading,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.white60),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.korean,
                      style: const TextStyle(
                          fontSize: 15, color: Colors.orangeAccent),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.volume_up, color: Colors.white38, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _startWrongAnswerQuiz(BuildContext context) {
    if (items.isEmpty) return;

    // type이 null(전체)인 경우 word로 기본 설정
    final quizType = type ?? 'word';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          quizType: quizType,
          wrongItems: items,
        ),
      ),
    );
  }
}
