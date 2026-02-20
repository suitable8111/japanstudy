import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/history_provider.dart';
import '../providers/theme_provider.dart';
import '../services/sentence_service.dart';
import '../widgets/rolling_ticker.dart';
import 'word_study_screen.dart';
import 'sentence_study_screen.dart';
import 'kana_study_screen.dart';
import 'kana_writing_screen.dart';
import 'quiz_screen.dart';
import 'radio_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'ranking_screen.dart';
import 'wrong_answer_screen.dart';
import 'settings_screen.dart';
import 'level_test_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _milestoneChecked = false;

  static const List<int> _milestones = [3, 7, 14, 30, 50, 100];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _checkStreakMilestone(int streak) {
    if (_milestoneChecked) return;
    _milestoneChecked = true;
    if (!_milestones.contains(streak)) return;

    SharedPreferences.getInstance().then((prefs) {
      final lastMilestone = prefs.getInt('last_streak_milestone') ?? 0;
      if (streak > lastMilestone) {
        prefs.setInt('last_streak_milestone', streak);
        if (mounted) {
          _showStreakMilestoneDialog(streak);
        }
      }
    });
  }

  void _showStreakMilestoneDialog(int streak) {
    final messages = {
      3: '좋은 시작이에요! 꾸준히 해봐요!',
      7: '일주일 연속! 대단해요!',
      14: '2주 연속 학습! 습관이 되어가고 있어요!',
      30: '한 달 연속! 정말 대단합니다!',
      50: '50일 돌파! 일본어 마스터에 가까워지고 있어요!',
      100: '100일 달성! 당신은 진정한 학습왕입니다!',
    };

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Icon(
              Icons.local_fire_department,
              color: _getStreakColor(streak),
              size: 72,
            ),
            const SizedBox(height: 16),
            const Text(
              '축하합니다!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$streak일 연속 학습 달성!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _getStreakColor(streak),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              messages[streak] ?? '대단해요! 계속 화이팅!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('확인', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStreakColor(int streak) {
    if (streak >= 30) return const Color(0xFF9C27B0);
    if (streak >= 7) return Colors.red;
    if (streak >= 1) return Colors.deepOrange;
    return Colors.grey;
  }

  Widget _buildStreakWidget(int streak) {
    final color = _getStreakColor(streak);
    final text = streak == 0 ? '오늘 첫 학습을 시작해보세요!' : '$streak일 연속 학습!';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: streak > 0
              ? _pulseAnimation
              : const AlwaysStoppedAnimation(1.0),
          child: Icon(Icons.local_fire_department, color: color, size: 28),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: context.watch<ThemeProvider>().gradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 메뉴 버튼 (왼쪽)
              Positioned(
                top: 8,
                left: 8,
                child: Builder(
                  builder: (ctx) => IconButton(
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.white70,
                      size: 28,
                    ),
                  ),
                ),
              ),
              // 설정 버튼 (오른쪽)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white70,
                    size: 28,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'JLPT 일기장',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '일본어 학습',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      Consumer<HistoryProvider>(
                        builder: (context, history, _) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _checkStreakMilestone(history.currentStreak);
                          });
                          return _buildStreakWidget(history.currentStreak);
                        },
                      ),
                      const SizedBox(height: 8),
                      Consumer<HistoryProvider>(
                        builder: (context, history, _) {
                          final items = [
                            '오늘 학습: ${history.todayStudyCount}회',
                            '누적 학습: ${history.coreStudyCount}회',
                            '오늘 퀴즈: ${history.todayQuizCount}회',
                            '누적 퀴즈: ${history.coreQuizCount}회',
                            '퀴즈 정답률: ${history.overallQuizAccuracy.toStringAsFixed(1)}%',
                            '오답 노트: ${history.wrongAnswerCount}개',
                          ];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: RollingTicker(items: items),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildMenuButton(
                        context,
                        icon: Icons.abc,
                        title: '0단계: 음절 공부하기',
                        subtitle: '히라가나 / 가타카나 학습',
                        color: Colors.teal,
                        onTap: () => _showKanaTypeDialog(context),
                      ),
                      const SizedBox(height: 16),
                      _buildMenuButton(
                        context,
                        icon: Icons.text_fields,
                        title: '1단계: 단어 외우기',
                        subtitle: '레벨별 단어 학습 (20개)',
                        color: const Color(0xFF667eea),
                        onTap: () => _showWordLevelDialog(context),
                      ),
                      const SizedBox(height: 16),
                      _buildMenuButton(
                        context,
                        icon: Icons.article,
                        title: '2단계: 문장 외우기',
                        subtitle: '레벨/카테고리별 문장 학습 (20개)',
                        color: const Color(0xFF764ba2),
                        onTap: () => _showSentenceCategoryDialog(context),
                      ),
                      const SizedBox(height: 16),
                      _buildMenuButton(
                        context,
                        icon: Icons.quiz,
                        title: '3단계: 단어/문장 퀴즈',
                        subtitle: '4지선다 (단어/문장)',
                        color: const Color(0xFFe96743),
                        onTap: () => _showQuizTypeDialog(context),
                      ),
                      const SizedBox(height: 16),
                      _buildMenuButton(
                        context,
                        icon: Icons.radio,
                        title: '4단계: 라디오 듣기',
                        subtitle: '자동 반복 재생 (단어/문장)',
                        color: const Color(0xFF43a047),
                        onTap: () => _showRadioTypeDialog(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showKanaTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: const Text('음절 유형 선택', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuizTypeOption(
              ctx,
              icon: Icons.abc,
              label: '히라가나 (ひらがな)',
              description: '기본 일본어 음절 46자 + 탁음/반탁음',
              color: Colors.teal,
              onTap: () {
                Navigator.pop(ctx);
                _showKanaModeDialog(context, 'hiragana');
              },
            ),
            const SizedBox(height: 12),
            _buildQuizTypeOption(
              ctx,
              icon: Icons.abc,
              label: '가타카나 (カタカナ)',
              description: '외래어 표기 음절 46자 + 탁음/반탁음',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(ctx);
                _showKanaModeDialog(context, 'katakana');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showKanaModeDialog(BuildContext context, String kanaType) {
    final isHiragana = kanaType == 'hiragana';
    final color = isHiragana ? Colors.teal : Colors.orange;
    final typeName = isHiragana ? '히라가나' : '가타카나';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: Text(
          '$typeName 학습 모드',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuizTypeOption(
              ctx,
              icon: Icons.grid_view,
              label: '공부하기',
              description: '음절표를 보면서 발음 익히기',
              color: color,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KanaStudyScreen(kanaType: kanaType),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildQuizTypeOption(
              ctx,
              icon: Icons.edit,
              label: '써보기',
              description: '청음 46자를 손가락으로 따라 써보기',
              color: color,
              onTap: () {
                Navigator.pop(ctx);
                _showWritingOrderDialog(context, kanaType);
              },
            ),
            const SizedBox(height: 12),
            _buildQuizTypeOption(
              ctx,
              icon: Icons.hearing,
              label: '써보기 (발음만)',
              description: '글자를 가리고 소리만 듣고 써보기',
              color: color,
              onTap: () {
                Navigator.pop(ctx);
                _showWritingOrderDialog(context, kanaType, blindMode: true);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showWritingOrderDialog(BuildContext context, String kanaType, {bool blindMode = false}) {
    final isHiragana = kanaType == 'hiragana';
    final color = isHiragana ? Colors.teal : Colors.orange;
    final typeName = isHiragana ? '히라가나' : '가타카나';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: Text(
          blindMode ? '$typeName 써보기 (발음만)' : '$typeName 써보기',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuizTypeOption(
              ctx,
              icon: Icons.format_list_numbered,
              label: '순서대로 써보기',
              description: '행 순서대로 청음 46자 연습',
              color: color,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KanaWritingScreen(
                      kanaType: kanaType,
                      blindMode: blindMode,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildQuizTypeOption(
              ctx,
              icon: Icons.shuffle,
              label: '랜덤으로 써보기',
              description: '랜덤 순서로 청음 46자 연습',
              color: color,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KanaWritingScreen(
                      kanaType: kanaType,
                      shuffle: true,
                      blindMode: blindMode,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showWordLevelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: const Text('단어 레벨 선택', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuizTypeOption(
                ctx,
                icon: Icons.shuffle,
                label: '전체 랜덤',
                description: '모든 레벨에서 랜덤 20개',
                color: Colors.blueGrey,
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WordStudyScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_one,
                label: 'N5 (초급)',
                description: 'N5 레벨 단어 20개',
                color: const Color(0xFF43a047),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WordStudyScreen(level: 'N5'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_two,
                label: 'N4 (중급)',
                description: 'N4 레벨 단어 20개',
                color: const Color(0xFFf5a623),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WordStudyScreen(level: 'N4'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_3,
                label: 'N3 (상급)',
                description: 'N3 레벨 단어 20개',
                color: const Color(0xFFe96743),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WordStudyScreen(level: 'N3'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_4,
                label: 'N2 (상상급)',
                description: 'N2 레벨 단어 20개',
                color: const Color(0xFF5c6bc0),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WordStudyScreen(level: 'N2'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_5,
                label: 'N1 (최상급)',
                description: 'N1 레벨 단어 20개',
                color: const Color(0xFF9c27b0),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WordStudyScreen(level: 'N1'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSentenceCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: const Text('문장 레벨 선택', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuizTypeOption(
                ctx,
                icon: Icons.shuffle,
                label: '전체 랜덤',
                description: '모든 레벨/카테고리에서 랜덤 20개',
                color: Colors.blueGrey,
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SentenceStudyScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_one,
                label: 'N5 (초급)',
                description: 'N5 레벨 문장 20개',
                color: const Color(0xFF43a047),
                onTap: () {
                  Navigator.pop(ctx);
                  _showSentenceSubCategoryDialog(context, 'N5');
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_two,
                label: 'N4 (중급)',
                description: 'N4 레벨 문장 20개',
                color: const Color(0xFFf5a623),
                onTap: () {
                  Navigator.pop(ctx);
                  _showSentenceSubCategoryDialog(context, 'N4');
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_3,
                label: 'N3 (상급)',
                description: 'N3 레벨 문장 20개',
                color: const Color(0xFFe96743),
                onTap: () {
                  Navigator.pop(ctx);
                  _showSentenceSubCategoryDialog(context, 'N3');
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_4,
                label: 'N2 (상상급)',
                description: 'N2 레벨 문장 20개',
                color: const Color(0xFF5c6bc0),
                onTap: () {
                  Navigator.pop(ctx);
                  _showSentenceSubCategoryDialog(context, 'N2');
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_5,
                label: 'N1 (최상급)',
                description: 'N1 레벨 문장 20개',
                color: const Color(0xFF9c27b0),
                onTap: () {
                  Navigator.pop(ctx);
                  _showSentenceSubCategoryDialog(context, 'N1');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSentenceSubCategoryDialog(BuildContext context, String level) {
    final sentenceService = SentenceService();
    sentenceService.loadSentences().then((_) {
      final categories = sentenceService.getCategories();
      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF2a2a4e),
          title: Text(
            '$level 문장 — 카테고리 선택',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildQuizTypeOption(
                  ctx,
                  icon: Icons.shuffle,
                  label: '전체 카테고리',
                  description: '$level 레벨 전체에서 랜덤 20개',
                  color: Colors.blueGrey,
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SentenceStudyScreen(level: level),
                      ),
                    );
                  },
                ),
                ...categories.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _buildQuizTypeOption(
                      ctx,
                      icon: Icons.category,
                      label: cat,
                      description: '$level / $cat 문장 학습',
                      color: const Color(0xFF764ba2),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SentenceStudyScreen(
                              level: level,
                              category: cat,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showQuizTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: const Text('퀴즈 유형 선택', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuizTypeOption(
                ctx,
                icon: Icons.abc,
                label: '히라가나 퀴즈',
                description: '히라가나 → 한글 발음 맞추기',
                color: Colors.teal,
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const QuizScreen(quizType: 'kana_hiragana'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.abc,
                label: '가타카나 퀴즈',
                description: '가타카나 → 한글 발음 맞추기',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const QuizScreen(quizType: 'kana_katakana'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.text_fields,
                label: '단어 퀴즈',
                description: '일본어 단어 → 한국어 뜻 맞추기',
                color: const Color(0xFF667eea),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDifficultyDialog(context, 'word');
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.article,
                label: '문장 퀴즈',
                description: '일본어 문장 → 한국어 해석 맞추기',
                color: const Color(0xFF764ba2),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDifficultyDialog(context, 'sentence');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context, String quizType) {
    final typeLabel = quizType == 'word' ? '단어' : '문장';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: Text(
          '$typeLabel 퀴즈 — 난이도 선택',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_5,
                label: '최상 (N1)',
                description: '최상급 단계 — N1 레벨 80%',
                color: const Color(0xFF9c27b0),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          QuizScreen(quizType: quizType, difficulty: 'N1'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_4,
                label: '상상 (N2)',
                description: '상상급 단계 — N2 레벨 80%',
                color: const Color(0xFF5c6bc0),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          QuizScreen(quizType: quizType, difficulty: 'N2'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_3,
                label: '상 (N3)',
                description: '고급 단계 — N3 레벨 80%',
                color: const Color(0xFFe96743),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          QuizScreen(quizType: quizType, difficulty: 'N3'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_two,
                label: '중 (N4)',
                description: '중급 단계 — N4 레벨 80%',
                color: const Color(0xFFf5a623),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          QuizScreen(quizType: quizType, difficulty: 'N4'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_one,
                label: '하 (N5)',
                description: '초급 단계 — N5 레벨 80%',
                color: const Color(0xFF43a047),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          QuizScreen(quizType: quizType, difficulty: 'N5'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRadioTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: const Text('라디오 모드 선택', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuizTypeOption(
              ctx,
              icon: Icons.text_fields,
              label: '단어 라디오',
              description: '단어를 자동으로 반복 재생',
              color: const Color(0xFF43a047),
              onTap: () {
                Navigator.pop(ctx);
                _showRadioLevelDialog(context, 'word');
              },
            ),
            const SizedBox(height: 12),
            _buildQuizTypeOption(
              ctx,
              icon: Icons.article,
              label: '문장 라디오',
              description: '문장을 자동으로 반복 재생',
              color: const Color(0xFF43a047),
              onTap: () {
                Navigator.pop(ctx);
                _showRadioLevelDialog(context, 'sentence');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRadioLevelDialog(BuildContext context, String radioMode) {
    final modeLabel = radioMode == 'word' ? '단어' : '문장';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: Text(
          '$modeLabel 라디오 — 레벨 선택',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuizTypeOption(
                ctx,
                icon: Icons.shuffle,
                label: '전체 랜덤',
                description: '모든 레벨에서 랜덤 20개',
                color: Colors.blueGrey,
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RadioScreen(mode: radioMode),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_one,
                label: 'N5 (초급)',
                description: 'N5 레벨 $modeLabel 20개',
                color: const Color(0xFF43a047),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RadioScreen(mode: radioMode, level: 'N5'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_two,
                label: 'N4 (중급)',
                description: 'N4 레벨 $modeLabel 20개',
                color: const Color(0xFFf5a623),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RadioScreen(mode: radioMode, level: 'N4'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_3,
                label: 'N3 (상급)',
                description: 'N3 레벨 $modeLabel 20개',
                color: const Color(0xFFe96743),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RadioScreen(mode: radioMode, level: 'N3'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_4,
                label: 'N2 (상상급)',
                description: 'N2 레벨 $modeLabel 20개',
                color: const Color(0xFF5c6bc0),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RadioScreen(mode: radioMode, level: 'N2'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_5,
                label: 'N1 (최상급)',
                description: 'N1 레벨 $modeLabel 20개',
                color: const Color(0xFF9c27b0),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RadioScreen(mode: radioMode, level: 'N1'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizTypeOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final displayName = user?.displayName ?? '학습자';
    final email = user?.email ?? '';

    return Drawer(
      backgroundColor: const Color(0xFF1a1a2e),
      child: SafeArea(
        child: Column(
          children: [
            // 프로필 헤더 (탭하면 내 프로필로 이동)
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: context.read<ThemeProvider>().gradient,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white24,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? const Icon(
                              Icons.person,
                              size: 36,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            // 메뉴 목록
            ListTile(
              leading: const Icon(Icons.assessment, color: Colors.purpleAccent),
              title: const Text(
                '레벨 테스트',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                '내 JLPT 레벨 측정하기',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LevelTestScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white70),
              title: const Text('내 프로필', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.white70),
              title: const Text('학습 통계', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StatsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.leaderboard, color: Colors.white70),
              title: const Text('랭킹', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RankingScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_late, color: Colors.white70),
              title: const Text('오답 노트', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WrongAnswerScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.white70),
              title: const Text(
                '공부한 내역 확인하기',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
            ),
            const Divider(color: Colors.white12),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white70),
              title: const Text('설정', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            const Spacer(),
            const Divider(color: Colors.white12),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                '로그아웃',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context);
              },
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'JLPT 일기장 v1.0',
                style: TextStyle(color: Colors.white24, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: const Text('로그아웃', style: TextStyle(color: Colors.white)),
        content: const Text(
          '로그아웃 하시겠습니까?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().signOut();
            },
            child: const Text(
              '로그아웃',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
