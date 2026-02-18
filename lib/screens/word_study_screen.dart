import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';
import '../providers/history_provider.dart';

class WordStudyScreen extends StatefulWidget {
  final String? level;

  const WordStudyScreen({super.key, this.level});

  @override
  State<WordStudyScreen> createState() => _WordStudyScreenState();
}

class _WordStudyScreenState extends State<WordStudyScreen> {
  bool _historySaved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WordProvider>().startTest(level: widget.level);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: Text(widget.level != null
            ? '단어 외우기 (${widget.level})'
            : '단어 외우기'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          Consumer<WordProvider>(
            builder: (_, provider, _) {
              if (provider.isCompleted || provider.studyWords.isEmpty) {
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
      body: Consumer<WordProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (provider.isCompleted) {
            return _buildCompletionScreen(context, provider);
          }

          if (provider.currentWord == null) {
            return const Center(
              child: Text(
                '단어를 불러오는 중...',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return _buildStudyCard(context, provider);
        },
      ),
    );
  }

  Widget _buildStudyCard(BuildContext context, WordProvider provider) {
    final word = provider.currentWord!;

    return GestureDetector(
      onTap: () {
        if (!provider.showAnswer) {
          provider.revealAnswer();
        } else {
          provider.nextWord();
        }
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < -100) {
            provider.nextWord();
          } else if (details.primaryVelocity! > 100) {
            provider.previousWord();
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
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 8),
              // Word type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTypeColor(word.type),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getTypeLabel(word.type),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const Spacer(),
              // Japanese word
              Text(
                word.japanese,
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Reading (hiragana)
              Text(
                word.reading,
                style: const TextStyle(fontSize: 24, color: Colors.white60),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Category
              Text(
                word.category,
                style: const TextStyle(fontSize: 14, color: Colors.white38),
              ),
              const SizedBox(height: 40),
              // Answer section
              AnimatedOpacity(
                opacity: provider.showAnswer ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 2,
                      color: Colors.white24,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      provider.showAnswer ? word.korean : '',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF667eea),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Hint text
              Text(
                provider.showAnswer ? '터치하면 다음 단어' : '터치하면 정답 보기',
                style: const TextStyle(fontSize: 14, color: Colors.white30),
              ),
              const SizedBox(height: 16),
              // Bottom controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed:
                        provider.currentIndex > 0 ? provider.previousWord : null,
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
                    onPressed: provider.nextWord,
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

  Widget _buildCompletionScreen(BuildContext context, WordProvider provider) {
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
            const Icon(Icons.check_circle, color: Color(0xFF667eea), size: 80),
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
              '${provider.totalCount}개의 단어를 학습했습니다',
              style: const TextStyle(fontSize: 18, color: Colors.white60),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => provider.startTest(level: widget.level),
              icon: const Icon(Icons.refresh),
              label: const Text('다시 테스트하기', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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

  Color _getTypeColor(String type) {
    switch (type) {
      case 'hiragana':
        return Colors.teal;
      case 'katakana':
        return Colors.orange;
      case 'kanji':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'hiragana':
        return 'ひらがな';
      case 'katakana':
        return 'カタカナ';
      case 'kanji':
        return '漢字';
      default:
        return type;
    }
  }
}
