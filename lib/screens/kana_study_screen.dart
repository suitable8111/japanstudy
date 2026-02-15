import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kana_provider.dart';
import '../providers/history_provider.dart';

class KanaStudyScreen extends StatefulWidget {
  final String kanaType; // 'hiragana' or 'katakana'

  const KanaStudyScreen({super.key, required this.kanaType});

  @override
  State<KanaStudyScreen> createState() => _KanaStudyScreenState();
}

class _KanaStudyScreenState extends State<KanaStudyScreen> {
  bool _historySaved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KanaProvider>().startStudy(widget.kanaType);
    });
  }

  String get _title =>
      widget.kanaType == 'hiragana' ? '히라가나 공부' : '가타카나 공부';

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
          Consumer<KanaProvider>(
            builder: (_, provider, _) {
              if (provider.isCompleted || provider.studyKana.isEmpty) {
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
      body: Consumer<KanaProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (provider.isCompleted) {
            return _buildCompletionScreen(context, provider);
          }

          if (provider.currentKana == null) {
            return const Center(
              child: Text(
                '음절을 불러오는 중...',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return _buildStudyCard(context, provider);
        },
      ),
    );
  }

  Widget _buildStudyCard(BuildContext context, KanaProvider provider) {
    final kana = provider.currentKana!;

    return GestureDetector(
      onTap: () {
        if (!provider.showAnswer) {
          provider.revealAnswer();
        } else {
          provider.nextKana();
        }
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < -100) {
            provider.nextKana();
          } else if (details.primaryVelocity! > 100) {
            provider.previousKana();
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
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.kanaType == 'hiragana'
                      ? Colors.teal
                      : Colors.orange,
                ),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 8),
              // Row badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.kanaType == 'hiragana'
                      ? Colors.teal
                      : Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  kana.row,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const Spacer(),
              // Japanese character (large)
              Text(
                kana.japanese,
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
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
                    // Korean pronunciation
                    Text(
                      provider.showAnswer ? kana.korean : '',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        color: widget.kanaType == 'hiragana'
                            ? Colors.teal.shade300
                            : Colors.orange.shade300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // Romaji reading
                    Text(
                      provider.showAnswer ? kana.reading : '',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white60,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Hint text
              Text(
                provider.showAnswer ? '터치하면 다음 음절' : '터치하면 정답 보기',
                style: const TextStyle(fontSize: 14, color: Colors.white30),
              ),
              const SizedBox(height: 16),
              // Bottom controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: provider.currentIndex > 0
                        ? provider.previousKana
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
                    onPressed: provider.nextKana,
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

  Widget _buildCompletionScreen(BuildContext context, KanaProvider provider) {
    if (!_historySaved) {
      _historySaved = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<HistoryProvider>().addRecord(provider.buildRecord());
      });
    }

    final typeLabel = widget.kanaType == 'hiragana' ? '히라가나' : '가타카나';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: widget.kanaType == 'hiragana'
                  ? Colors.teal
                  : Colors.orange,
              size: 80,
            ),
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
              '$typeLabel ${provider.totalCount}개를 학습했습니다',
              style: const TextStyle(fontSize: 18, color: Colors.white60),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                _historySaved = false;
                provider.startStudy(widget.kanaType);
              },
              icon: const Icon(Icons.refresh),
              label:
                  const Text('다시 공부하기', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.kanaType == 'hiragana'
                    ? Colors.teal
                    : Colors.orange,
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
    );
  }
}
