import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';
import '../providers/auth_provider.dart';
import '../providers/tts_settings_provider.dart';
import '../providers/history_provider.dart';
import '../providers/theme_provider.dart';
import '../services/sentence_service.dart';
import '../widgets/rolling_ticker.dart';
import 'word_study_screen.dart';
import 'word_writing_screen.dart';
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
    final s = AppStrings.get(
      context.read<TtsSettingsProvider>().displayLanguage,
    );

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
            Text(
              s.streakCongrats,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.streakAchieved(streak),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _getStreakColor(streak),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              s.streakMessages[streak] ?? '대단해요! 계속 화이팅!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.streakConfirm, style: const TextStyle(fontSize: 16)),
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
    final s = AppStrings.of(context);
    final text = streak == 0 ? s.streakStart : s.streakDays(streak);

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
              LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(32, 56, 32, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                      const Text(
                        'JLPT STUDY',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.of(context).appSubtitle,
                        style: const TextStyle(fontSize: 16, color: Colors.white70),
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
                          final s = AppStrings.of(context);
                          final items = [
                            '${s.tickerTodayStudy}: ${history.todayStudyCount}',
                            '${s.tickerTotalStudy}: ${history.coreStudyCount}',
                            '${s.tickerTodayQuiz}: ${history.todayQuizCount}',
                            '${s.tickerTotalQuiz}: ${history.coreQuizCount}',
                            '${s.tickerAccuracy}: ${history.overallQuizAccuracy.toStringAsFixed(1)}%',
                            '${s.tickerWrongNote}: ${history.wrongAnswerCount}',
                          ];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: RollingTicker(items: items),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Builder(builder: (context) {
                        final s = AppStrings.of(context);
                        return Column(
                          children: [
                            _buildMenuButton(
                              context,
                              icon: Icons.abc,
                              title: s.menu0Title,
                              subtitle: s.menu0Subtitle,
                              color: Colors.teal,
                              onTap: () => _showKanaTypeDialog(context),
                            ),
                            const SizedBox(height: 16),
                            _buildMenuButton(
                              context,
                              icon: Icons.text_fields,
                              title: s.menu1Title,
                              subtitle: s.menu1Subtitle,
                              color: const Color(0xFF667eea),
                              onTap: () => _showWordModeDialog(context),
                            ),
                            const SizedBox(height: 16),
                            _buildMenuButton(
                              context,
                              icon: Icons.article,
                              title: s.menu2Title,
                              subtitle: s.menu2Subtitle,
                              color: const Color(0xFF764ba2),
                              onTap: () => _showSentenceCategoryDialog(context),
                            ),
                            const SizedBox(height: 16),
                            _buildMenuButton(
                              context,
                              icon: Icons.quiz,
                              title: s.menu3Title,
                              subtitle: s.menu3Subtitle,
                              color: const Color(0xFFe96743),
                              onTap: () => _showQuizTypeDialog(context),
                            ),
                            const SizedBox(height: 16),
                            _buildMenuButton(
                              context,
                              icon: Icons.radio,
                              title: s.menu4Title,
                              subtitle: s.menu4Subtitle,
                              color: const Color(0xFF43a047),
                              onTap: () => _showRadioTypeDialog(context),
                            ),
                          ],
                        );
                      }),
                        ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // 메뉴 버튼 (왼쪽) — ScrollView 위에 렌더링
              Positioned(
                top: 8,
                left: 8,
                child: Builder(
                  builder: (ctx) => IconButton(
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                    icon: const Icon(Icons.menu, color: Colors.white70, size: 28),
                  ),
                ),
              ),
              // 설정 버튼 (오른쪽)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                  icon: const Icon(Icons.settings, color: Colors.white70, size: 28),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showKanaTypeDialog(BuildContext context) {
    final s = AppStrings.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: Text(s.kanaSelectType, style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuizTypeOption(
              ctx,
              icon: Icons.abc,
              label: s.kanaHiragana,
              description: s.kanaHiraganaDesc,
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
              label: s.kanaKatakana,
              description: s.kanaKatakanaDesc,
              color: Colors.orange,
              onTap: () {
                Navigator.pop(ctx);
                _showKanaModeDialog(context, 'katakana');
              },
            ),
            const SizedBox(height: 12),
            _buildQuizTypeOption(
              ctx,
              icon: Icons.auto_awesome,
              label: s.kanaBoth,
              description: s.kanaBothDesc,
              color: Colors.deepPurple,
              onTap: () {
                Navigator.pop(ctx);
                _showKanaBothModeDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showKanaBothModeDialog(BuildContext context) {
    const color = Colors.deepPurple;
    final s = AppStrings.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: Text(
          'Hiragana + Katakana ${s.kanaModeTitle}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuizTypeOption(
              ctx,
              icon: Icons.edit,
              label: s.kanaModeWrite,
              description: '${s.kanaBothDesc} (46)',
              color: color,
              onTap: () {
                Navigator.pop(ctx);
                _showWritingOrderDialog(context, 'both');
              },
            ),
            const SizedBox(height: 12),
            _buildQuizTypeOption(
              ctx,
              icon: Icons.hearing,
              label: s.kanaModeWriteBlind,
              description: s.kanaModeWriteBlindDesc,
              color: color,
              onTap: () {
                Navigator.pop(ctx);
                _showWritingOrderDialog(context, 'both', blindMode: true);
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
    final s = AppStrings.of(context);
    final typeName = isHiragana ? s.kanaHiragana : s.kanaKatakana;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: Text(
          '$typeName ${s.kanaModeTitle}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuizTypeOption(
              ctx,
              icon: Icons.grid_view,
              label: s.kanaModeStudy,
              description: s.kanaModeStudyDesc,
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
              label: s.kanaModeWrite,
              description: s.kanaModeWriteDesc,
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
              label: s.kanaModeWriteBlind,
              description: s.kanaModeWriteBlindDesc,
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

  void _showWritingOrderDialog(
    BuildContext context,
    String kanaType, {
    bool blindMode = false,
  }) {
    final isBoth = kanaType == 'both';
    final isHiragana = kanaType == 'hiragana';
    final color = isBoth
        ? Colors.deepPurple
        : (isHiragana ? Colors.teal : Colors.orange);
    final s = AppStrings.of(context);
    final typeName = isBoth
        ? 'Hiragana + Katakana'
        : (isHiragana ? s.kanaHiragana : s.kanaKatakana);
    final countLabel = isBoth ? s.kanaBothCountLabel : s.kanaCountLabel;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: Text(
          blindMode ? '$typeName ${s.kanaModeWriteBlind}' : '$typeName ${s.kanaModeWrite}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuizTypeOption(
              ctx,
              icon: Icons.format_list_numbered,
              label: s.kanaOrderSequential,
              description: countLabel,
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
              label: s.kanaOrderRandom,
              description: countLabel,
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

  void _showWordModeDialog(BuildContext context) {
    final s = AppStrings.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: Text(s.wordModeTitle, style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuizTypeOption(
              ctx,
              icon: Icons.menu_book,
              label: s.wordModeStudy,
              description: s.wordModeStudyDesc,
              color: const Color(0xFF667eea),
              onTap: () {
                Navigator.pop(ctx);
                _showWordLevelDialog(context, mode: 'study');
              },
            ),
            const SizedBox(height: 12),
            _buildQuizTypeOption(
              ctx,
              icon: Icons.draw,
              label: s.wordModeWrite,
              description: s.wordModeWriteDesc,
              color: const Color(0xFF43a047),
              onTap: () {
                Navigator.pop(ctx);
                _showWordLevelDialog(context, mode: 'write');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showWordLevelDialog(BuildContext context, {String mode = 'study'}) {
    final s = AppStrings.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: Text(s.wordLevelTitle, style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuizTypeOption(
                ctx,
                icon: Icons.shuffle,
                label: s.levelRandom,
                description: s.levelRandomDesc,
                color: Colors.blueGrey,
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => mode == 'write'
                          ? const WordWritingScreen()
                          : const WordStudyScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_one,
                label: s.n5Label,
                description: s.levelDesc('N5', s.n5Label),
                color: const Color(0xFF43a047),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => mode == 'write'
                          ? const WordWritingScreen(level: 'N5')
                          : const WordStudyScreen(level: 'N5'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_two,
                label: s.n4Label,
                description: s.levelDesc('N4', s.n4Label),
                color: const Color(0xFFf5a623),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => mode == 'write'
                          ? const WordWritingScreen(level: 'N4')
                          : const WordStudyScreen(level: 'N4'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_3,
                label: s.n3Label,
                description: s.levelDesc('N3', s.n3Label),
                color: const Color(0xFFe96743),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => mode == 'write'
                          ? const WordWritingScreen(level: 'N3')
                          : const WordStudyScreen(level: 'N3'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_4,
                label: s.n2Label,
                description: s.levelDesc('N2', s.n2Label),
                color: const Color(0xFF5c6bc0),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => mode == 'write'
                          ? const WordWritingScreen(level: 'N2')
                          : const WordStudyScreen(level: 'N2'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_5,
                label: s.n1Label,
                description: s.levelDesc('N1', s.n1Label),
                color: const Color(0xFF9c27b0),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => mode == 'write'
                          ? const WordWritingScreen(level: 'N1')
                          : const WordStudyScreen(level: 'N1'),
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
    final s = AppStrings.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: Text(s.sentenceLevelTitle, style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuizTypeOption(
                ctx,
                icon: Icons.shuffle,
                label: s.levelRandom,
                description: '${s.levelRandomDesc} (${s.sentenceLevelTitle})',
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
                label: s.n5Label,
                description: s.levelDesc('N5', s.n5Label),
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
                label: s.n4Label,
                description: s.levelDesc('N4', s.n4Label),
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
                label: s.n3Label,
                description: s.levelDesc('N3', s.n3Label),
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
                label: s.n2Label,
                description: s.levelDesc('N2', s.n2Label),
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
                label: s.n1Label,
                description: s.levelDesc('N1', s.n1Label),
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
    final s = AppStrings.of(context);
    final sentenceService = SentenceService();
    sentenceService.loadSentences().then((_) {
      final categories = sentenceService.getCategories();
      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF2a2a4e),
          title: Text(
            '$level — ${s.sentenceCategoryAll}',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildQuizTypeOption(
                  ctx,
                  icon: Icons.shuffle,
                  label: s.sentenceCategoryAll,
                  description: s.sentenceCategoryAllDesc(level),
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
                      description: s.sentenceCategoryDesc(level, cat),
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
    final s = AppStrings.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: Text(s.quizSelectType, style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuizTypeOption(
                ctx,
                icon: Icons.abc,
                label: s.quizHiragana,
                description: s.quizHiraganaDesc,
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
                label: s.quizKatakana,
                description: s.quizKatakanaDesc,
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
                label: s.quizWord,
                description: s.quizWordDesc,
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
                label: s.quizSentence,
                description: s.quizSentenceDesc,
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
    final s = AppStrings.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: Text(
          s.quizDifficultyTitle(quizType),
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuizTypeOption(
                ctx,
                icon: Icons.looks_5,
                label: s.n1Label,
                description: 'N1 — 80%',
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
                label: s.n2Label,
                description: 'N2 — 80%',
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
                label: s.n3Label,
                description: 'N3 — 80%',
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
                label: s.n4Label,
                description: 'N4 — 80%',
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
                label: s.n5Label,
                description: 'N5 — 80%',
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
    final s = AppStrings.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: Text(s.radioSelectMode, style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuizTypeOption(
              ctx,
              icon: Icons.text_fields,
              label: s.radioWord,
              description: s.radioWordDesc,
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
              label: s.radioSentence,
              description: s.radioSentenceDesc,
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
    final s = AppStrings.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: Text(
          s.radioLevelTitle(radioMode),
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuizTypeOption(
                ctx,
                icon: Icons.shuffle,
                label: s.levelRandom,
                description: s.levelRandomDesc,
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
                label: s.n5Label,
                description: s.levelDesc('N5', s.n5Label),
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
                label: s.n4Label,
                description: s.levelDesc('N4', s.n4Label),
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
                label: s.n3Label,
                description: s.levelDesc('N3', s.n3Label),
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
                label: s.n2Label,
                description: s.levelDesc('N2', s.n2Label),
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
                label: s.n1Label,
                description: s.levelDesc('N1', s.n1Label),
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
    final s = AppStrings.of(context);
    final displayName = user?.displayName ?? (s.appSubtitle == 'Japanese Learning' ? 'Learner' : '학습자');
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
              title: Text(s.drawerLevelTest, style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                s.drawerLevelTestSub,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
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
              title: Text(s.drawerProfile, style: const TextStyle(color: Colors.white)),
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
              title: Text(s.drawerStats, style: const TextStyle(color: Colors.white)),
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
              title: Text(s.drawerRanking, style: const TextStyle(color: Colors.white)),
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
              title: Text(s.drawerWrongNote, style: const TextStyle(color: Colors.white)),
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
              title: Text(s.drawerHistory, style: const TextStyle(color: Colors.white)),
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
              title: Text(s.drawerSettings, style: const TextStyle(color: Colors.white)),
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
              title: Text(s.drawerLogout, style: const TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context);
              },
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'JLPT STUDY v1.0',
                style: TextStyle(color: Colors.white24, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final s = AppStrings.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: Text(s.logoutTitle, style: const TextStyle(color: Colors.white)),
        content: Text(s.logoutContent, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.logoutCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().signOut();
            },
            child: Text(s.logoutConfirm, style: const TextStyle(color: Colors.redAccent)),
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
