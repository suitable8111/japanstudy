import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/radio_provider.dart';

class RadioScreen extends StatefulWidget {
  final String mode; // 'word' or 'sentence'
  final String? level;

  const RadioScreen({super.key, required this.mode, this.level});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RadioProvider>().startRadio(widget.mode, level: widget.level);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modeLabel = widget.mode == 'word' ? '단어' : '문장';
    final titleSuffix = widget.level != null ? ' (${widget.level})' : '';

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          context.read<RadioProvider>().stop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1a1a2e),
        appBar: AppBar(
          title: Text('라디오 듣기 - $modeLabel$titleSuffix'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        body: Consumer<RadioProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (provider.isCompleted) {
              return _buildCompletedScreen(context, provider);
            }

            if (provider.currentItem == null) {
              return const Center(
                child: Text('준비 중...', style: TextStyle(color: Colors.white70)),
              );
            }

            return _buildPlayingScreen(context, provider);
          },
        ),
      ),
    );
  }

  Widget _buildPlayingScreen(BuildContext context, RadioProvider provider) {
    final item = provider.currentItem!;
    final stepLabels = ['JP', 'KR', 'JP', 'JP'];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 진행 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                provider.progressText,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              Text(
                widget.mode == 'word' ? '단어 모드' : '문장 모드',
                style: const TextStyle(fontSize: 14, color: Colors.white38),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 프로그레스 바
          LinearProgressIndicator(
            value: (provider.currentIndex + 1) / provider.totalCount,
            backgroundColor: Colors.white12,
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          const Spacer(),
          // 일본어 텍스트
          Text(
            item['japanese']!,
            style: TextStyle(
              fontSize: widget.mode == 'word' ? 56 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.mode == 'word' &&
              item['japanese'] != item['reading']) ...[
            const SizedBox(height: 8),
            Text(
              item['reading']!,
              style: const TextStyle(fontSize: 22, color: Colors.white60),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          // 한국어 텍스트
          Text(
            item['korean']!,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.white70,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          // 단계 인디케이터
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final isActive = provider.currentStep == index;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF667eea)
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF667eea)
                        : Colors.white24,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  stepLabels[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? Colors.white : Colors.white38,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          // 컨트롤 버튼들
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 정지 버튼
              _buildControlButton(
                icon: Icons.stop_rounded,
                size: 48,
                color: Colors.redAccent,
                onTap: () {
                  provider.stop();
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 24),
              // 재생/일시정지 버튼
              _buildControlButton(
                icon: provider.isPaused
                    ? Icons.play_arrow_rounded
                    : Icons.pause_rounded,
                size: 64,
                color: const Color(0xFF667eea),
                onTap: provider.togglePause,
              ),
              const SizedBox(width: 24),
              // 다음 스킵 버튼
              _buildControlButton(
                icon: Icons.skip_next_rounded,
                size: 48,
                color: Colors.white54,
                onTap: provider.currentIndex < provider.totalCount - 1
                    ? provider.skipNext
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required double size,
    required Color color,
    VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDisabled
              ? Colors.white.withValues(alpha: 0.05)
              : color.withValues(alpha: 0.2),
          border: Border.all(
            color: isDisabled ? Colors.white12 : color,
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          size: size * 0.5,
          color: isDisabled ? Colors.white12 : color,
        ),
      ),
    );
  }

  Widget _buildCompletedScreen(BuildContext context, RadioProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.headphones,
              color: Color(0xFF667eea),
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              '라디오 듣기 완료!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${provider.totalCount}개 ${widget.mode == 'word' ? '단어' : '문장'}를 들었습니다',
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => provider.startRadio(widget.mode, level: widget.level),
              icon: const Icon(Icons.refresh),
              label: const Text('다시 듣기', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
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
              onPressed: () {
                provider.stop();
                Navigator.pop(context);
              },
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
