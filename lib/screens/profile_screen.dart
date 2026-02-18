import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/history_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final historyProvider = context.watch<HistoryProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('내 프로필'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 유저 정보 헤더
            _buildUserHeader(user),
            const SizedBox(height: 24),
            // 학습 요약
            _buildStudySummary(historyProvider),
            const SizedBox(height: 24),
            // 최근 30일 학습 캘린더
            _buildCalendarSection(historyProvider),
            const SizedBox(height: 24),
            // 난이도별 퀴즈 통계
            _buildQuizStatsSection(historyProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white24,
            backgroundImage: user?.photoURL != null
                ? NetworkImage(user!.photoURL!)
                : null,
            child: user?.photoURL == null
                ? const Icon(Icons.person, size: 40, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? '학습자',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (user?.email != null && user!.email!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    user.email!,
                    style:
                        const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudySummary(HistoryProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '학습 요약',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryTile(
                  icon: Icons.today,
                  label: '오늘 학습',
                  value: '${provider.todayStudyCount}회',
                  color: const Color(0xFF667eea),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryTile(
                  icon: Icons.library_books,
                  label: '누적 학습',
                  value: '${provider.coreStudyCount}회',
                  color: const Color(0xFF764ba2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryTile(
                  icon: Icons.quiz,
                  label: '오늘 퀴즈',
                  value: '${provider.todayQuizCount}회',
                  color: const Color(0xFFe96743),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryTile(
                  icon: Icons.assignment,
                  label: '누적 퀴즈',
                  value: '${provider.coreQuizCount}회',
                  color: const Color(0xFFf5a623),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryTile(
                  icon: Icons.percent,
                  label: '퀴즈 정답률',
                  value: '${provider.overallQuizAccuracy.toStringAsFixed(1)}%',
                  color: const Color(0xFF43a047),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryTile(
                  icon: Icons.local_fire_department,
                  label: '연속 학습',
                  value: '${provider.currentStreak}일',
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryTile(
                  icon: Icons.assignment_late,
                  label: '오답 노트',
                  value: '${provider.wrongAnswerCount}개',
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryTile(
                  icon: Icons.auto_stories,
                  label: '총 세션',
                  value: '${provider.totalStudySessions}회',
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection(HistoryProvider provider) {
    final activity = provider.studyActivityByDate;
    final now = DateTime.now();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '학습 활동 (30일 전 ~ 10일 후)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // 범례
          Row(
            children: [
              _buildLegend(Colors.blue, '단어'),
              const SizedBox(width: 16),
              _buildLegend(Colors.purple, '문장'),
              const SizedBox(width: 16),
              _buildLegend(Colors.orange, '퀴즈'),
            ],
          ),
          const SizedBox(height: 16),
          // 달력 그리드 (30일 전 ~ 10일 후 = 41일)
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: List.generate(41, (index) {
              final date = now.subtract(Duration(days: 30 - index));
              final dateKey =
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              final types = activity[dateKey] ?? [];

              final hasWord =
                  types.any((t) => t == 'word');
              final hasSentence =
                  types.any((t) => t == 'sentence');
              final hasQuiz =
                  types.any((t) => t.startsWith('quiz'));

              final isToday = date.day == now.day &&
                  date.month == now.month &&
                  date.year == now.year;
              final isFuture = date.isAfter(now);

              return Tooltip(
                message: isFuture
                    ? '${date.month}/${date.day}'
                    : '${date.month}/${date.day} — ${types.isEmpty ? "활동 없음" : "${types.length}건"}',
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: types.isNotEmpty
                        ? Colors.white.withValues(alpha: 0.1)
                        : isFuture
                            ? Colors.white.withValues(alpha: 0.02)
                            : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                    border: isToday
                        ? Border.all(color: Colors.white38, width: 1.5)
                        : null,
                  ),
                  child: types.isEmpty
                      ? Center(
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                                fontSize: 10,
                                color: isFuture
                                    ? Colors.white12
                                    : Colors.white24),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${date.day}',
                              style: const TextStyle(
                                  fontSize: 9, color: Colors.white54),
                            ),
                            const SizedBox(height: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (hasWord)
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                if (hasSentence) ...[
                                  const SizedBox(width: 2),
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      color: Colors.purple,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                                if (hasQuiz) ...[
                                  const SizedBox(width: 2),
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
      ],
    );
  }

  Widget _buildQuizStatsSection(HistoryProvider provider) {
    final stats = provider.quizStatsByDifficulty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '난이도별 퀴즈 통계',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'N1 (최상)',
                stats['N1']!,
                const Color(0xFF9c27b0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'N2 (상상)',
                stats['N2']!,
                const Color(0xFF5c6bc0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'N3 (상)',
                stats['N3']!,
                const Color(0xFFe96743),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'N4 (중)',
                stats['N4']!,
                const Color(0xFFf5a623),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'N5 (하)',
                stats['N5']!,
                const Color(0xFF43a047),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, Map<String, dynamic> data, Color color) {
    final quizCount = data['quizCount'] as int;
    final avgRate = data['avgRate'] as double;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$quizCount회',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            quizCount > 0 ? '${avgRate.toStringAsFixed(1)}%' : '-',
            style: TextStyle(
              fontSize: 14,
              color: quizCount > 0 ? Colors.white70 : Colors.white30,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '평균 정답률',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
