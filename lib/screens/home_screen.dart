import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/history_provider.dart';
import 'word_study_screen.dart';
import 'sentence_study_screen.dart';
import 'kana_study_screen.dart';
import 'quiz_screen.dart';
import 'radio_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'ranking_screen.dart';
import 'wrong_answer_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
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
                    icon: const Icon(Icons.menu, color: Colors.white70, size: 28),
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
                  icon: const Icon(Icons.settings, color: Colors.white70, size: 28),
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
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '일본어 학습',
                        style: TextStyle(fontSize: 20, color: Colors.white70),
                      ),
                      const SizedBox(height: 60),
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
                        subtitle: '테스트 시작! (20개 랜덤)',
                        color: const Color(0xFF667eea),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WordStudyScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildMenuButton(
                        context,
                        icon: Icons.article,
                        title: '2단계: 문장 해석하기',
                        subtitle: '테스트 시작! (20개 랜덤)',
                        color: const Color(0xFF764ba2),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SentenceStudyScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildMenuButton(
                        context,
                        icon: Icons.quiz,
                        title: '3단계: 퀴즈 풀기!',
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
        title: const Text(
          '음절 유형 선택',
          style: TextStyle(color: Colors.white),
        ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const KanaStudyScreen(kanaType: 'hiragana'),
                  ),
                );
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const KanaStudyScreen(kanaType: 'katakana'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQuizTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: const Text(
          '퀴즈 유형 선택',
          style: TextStyle(color: Colors.white),
        ),
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
                    builder: (_) => const QuizScreen(
                        quizType: 'kana_hiragana'),
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
                    builder: (_) => const QuizScreen(
                        quizType: 'kana_katakana'),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
    );
  }

  void _showRadioTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: const Text(
          '라디오 모드 선택',
          style: TextStyle(color: Colors.white),
        ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RadioScreen(mode: 'word'),
                  ),
                );
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RadioScreen(mode: 'sentence'),
                  ),
                );
              },
            ),
          ],
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
                          fontSize: 13, color: Colors.white54),
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
            // 프로필 헤더
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
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
                        ? const Icon(Icons.person, size: 36, color: Colors.white)
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
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ],
              ),
            ),
            // 학습 통계
            Consumer<HistoryProvider>(
              builder: (_, provider, _) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                          '총 학습', '${provider.totalStudySessions}회'),
                      _buildStatItem(
                          '단어', '${provider.wordStudyCount}회'),
                      _buildStatItem(
                          '문장', '${provider.sentenceStudyCount}회'),
                      _buildStatItem(
                          '퀴즈', '${provider.quizCount}회'),
                    ],
                  ),
                );
              },
            ),
            const Divider(color: Colors.white12),
            // 메뉴 목록
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white70),
              title: const Text('내 프로필',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.assignment_late, color: Colors.white70),
              title: const Text('오답 노트',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const WrongAnswerScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.leaderboard, color: Colors.white70),
              title: const Text('랭킹',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RankingScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.white70),
              title: const Text('공부한 내역 확인하기',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.replay, color: Colors.white70),
              title: const Text('공부한 내역 다시 공부하기',
                  style: TextStyle(color: Colors.white)),
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
              title:
                  const Text('설정', style: TextStyle(color: Colors.white)),
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
              title: const Text('로그아웃',
                  style: TextStyle(color: Colors.redAccent)),
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

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white54),
        ),
      ],
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
            child: const Text('로그아웃',
                style: TextStyle(color: Colors.redAccent)),
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
              const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
