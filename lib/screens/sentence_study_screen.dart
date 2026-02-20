import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sentence_provider.dart';
import '../providers/history_provider.dart';

class SentenceStudyScreen extends StatefulWidget {
  final String? level;
  final String? category;

  const SentenceStudyScreen({super.key, this.level, this.category});

  @override
  State<SentenceStudyScreen> createState() => _SentenceStudyScreenState();
}

class _SentenceStudyScreenState extends State<SentenceStudyScreen> {
  bool _historySaved = false;

  String _buildTitle() {
    final parts = <String>['문장 외우기'];
    if (widget.level != null || widget.category != null) {
      final filters = <String>[];
      if (widget.level != null) filters.add(widget.level!);
      if (widget.category != null) filters.add(widget.category!);
      parts.add('(${filters.join(' / ')})');
    }
    return parts.join(' ');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SentenceProvider>().startTest(
        level: widget.level,
        category: widget.category,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: Text(_buildTitle()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          Consumer<SentenceProvider>(
            builder: (_, provider, _) {
              if (provider.isCompleted || provider.studySentences.isEmpty) {
                return const SizedBox.shrink();
              }
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    provider.progressText,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<SentenceProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (provider.isCompleted) {
            return _buildCompletionScreen(context, provider);
          }

          if (provider.currentSentence == null) {
            return const Center(
              child: Text(
                '문장을 불러오는 중...',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return _buildStudyCard(context, provider);
        },
      ),
    );
  }

  Widget _buildStudyCard(BuildContext context, SentenceProvider provider) {
    final sentence = provider.currentSentence!;

    return GestureDetector(
      onTap: () {
        if (!provider.showAnswer) {
          provider.revealAnswer();
        } else {
          provider.nextSentence();
        }
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < -100) {
            provider.nextSentence();
          } else if (details.primaryVelocity! > 100) {
            provider.previousSentence();
          }
        }
      },
      child: Container(
        color: Colors.transparent,
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: (provider.currentIndex + 1) / provider.totalCount,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF764ba2),
                ),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 8),
              // Level & category badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getLevelColor(sentence.level),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      sentence.level,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      sentence.category,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Japanese sentence
              Text(
                sentence.japanese,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Reading (hiragana)
              Text(
                sentence.reading,
                style: const TextStyle(fontSize: 18, color: Colors.white60),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Answer section
              AnimatedOpacity(
                opacity: provider.showAnswer ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Column(
                  children: [
                    Container(width: 60, height: 2, color: Colors.white24),
                    const SizedBox(height: 20),
                    Text(
                      provider.showAnswer ? sentence.korean : '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF764ba2),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Hint text
              Text(
                provider.showAnswer ? '터치하면 다음 문장' : '터치하면 해석 보기',
                style: const TextStyle(fontSize: 14, color: Colors.white30),
              ),
              const SizedBox(height: 16),
              // Bottom controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: provider.currentIndex > 0
                        ? provider.previousSentence
                        : null,
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Colors.white54,
                    disabledColor: Colors.white12,
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    onPressed: provider.replayTts,
                    icon: const Icon(Icons.volume_up, size: 32),
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    onPressed: provider.nextSentence,
                    icon: const Icon(Icons.arrow_forward_ios),
                    color: Colors.white54,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionScreen(
    BuildContext context,
    SentenceProvider provider,
  ) {
    if (!_historySaved) {
      _historySaved = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<HistoryProvider>().addRecord(provider.buildRecord());
      });
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF764ba2), size: 80),
            const SizedBox(height: 24),
            const Text(
              '학습 완료!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${provider.totalCount}개의 문장을 학습했습니다',
              style: const TextStyle(fontSize: 18, color: Colors.white60),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => provider.startTest(
                level: widget.level,
                category: widget.category,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('다시 테스트하기', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF764ba2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
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

  Color _getLevelColor(String level) {
    switch (level) {
      case 'N5':
        return Colors.green;
      case 'N4':
        return Colors.teal;
      case 'N3':
        return Colors.orange;
      case 'N2':
        return Colors.deepOrange;
      case 'N1':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
