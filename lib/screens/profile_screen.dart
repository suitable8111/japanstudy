import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../providers/auth_provider.dart';
import '../providers/history_provider.dart';
import '../providers/theme_provider.dart';

// ─────────────────────────────────────────────
// 배지 정의
// ─────────────────────────────────────────────

class _BadgeDef {
  final String emoji;
  final String name;
  final String desc;
  final Color color;
  final bool Function(HistoryProvider) check;

  _BadgeDef({
    required this.emoji,
    required this.name,
    required this.desc,
    required this.color,
    required this.check,
  });
}

List<_BadgeDef> _getBadgeList(AppStrings s) {
  final names = s.profileBadgeNames;
  final descs = s.profileBadgeDescs;
  return [
    // streak
    _BadgeDef(emoji: '🔥', name: names[0],  desc: descs[0],  color: Colors.deepOrange,          check: (hp) => hp.currentStreak >= 1),
    _BadgeDef(emoji: '🔥', name: names[1],  desc: descs[1],  color: Colors.orange,               check: (hp) => hp.currentStreak >= 3),
    _BadgeDef(emoji: '🔥', name: names[2],  desc: descs[2],  color: Colors.red,                  check: (hp) => hp.currentStreak >= 7),
    _BadgeDef(emoji: '💜', name: names[3],  desc: descs[3],  color: Colors.purple,               check: (hp) => hp.currentStreak >= 30),
    // study
    _BadgeDef(emoji: '📖', name: names[4],  desc: descs[4],  color: Colors.blue,                 check: (hp) => hp.totalStudySessions >= 1),
    _BadgeDef(emoji: '📚', name: names[5],  desc: descs[5],  color: const Color(0xFF667eea),     check: (hp) => hp.wordStudyCount >= 10),
    _BadgeDef(emoji: '📝', name: names[6],  desc: descs[6],  color: const Color(0xFF764ba2),     check: (hp) => hp.sentenceStudyCount >= 10),
    _BadgeDef(emoji: '🎓', name: names[7],  desc: descs[7],  color: Colors.indigo,               check: (hp) => hp.totalStudySessions >= 50),
    // quiz
    _BadgeDef(emoji: '🎯', name: names[8],  desc: descs[8],  color: const Color(0xFFe96743),     check: (hp) => hp.coreQuizCount >= 1),
    _BadgeDef(emoji: '🎯', name: names[9],  desc: descs[9],  color: Colors.redAccent,            check: (hp) => hp.coreQuizCount >= 20),
    _BadgeDef(emoji: '✨', name: names[10], desc: descs[10], color: const Color(0xFFf5a623),     check: (hp) => hp.overallQuizAccuracy >= 80 && hp.coreQuizCount >= 5),
    _BadgeDef(emoji: '🏆', name: names[11], desc: descs[11], color: const Color(0xFF43a047),     check: (hp) => hp.overallQuizAccuracy >= 90 && hp.coreQuizCount >= 10),
    // sessions
    _BadgeDef(emoji: '⭐', name: names[12], desc: descs[12], color: Colors.amber,                check: (hp) => hp.totalStudySessions >= 10),
    _BadgeDef(emoji: '🌟', name: names[13], desc: descs[13], color: Colors.orange,               check: (hp) => hp.totalStudySessions >= 50),
    _BadgeDef(emoji: '👑', name: names[14], desc: descs[14], color: Colors.yellow,               check: (hp) => hp.totalStudySessions >= 100),
    _BadgeDef(emoji: '💎', name: names[15], desc: descs[15], color: Colors.cyan,                 check: (hp) => hp.totalStudySessions >= 200),
  ];
}

// ─────────────────────────────────────────────
// ProfileScreen
// ─────────────────────────────────────────────

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final authProvider = context.watch<AuthProvider>();
    final historyProvider = context.watch<HistoryProvider>();
    final themeGradient = context.watch<ThemeProvider>().gradient;
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: Text(s.profileTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildUserHeader(s, user, themeGradient),
            const SizedBox(height: 24),
            _buildStudySummary(context, s, historyProvider),
            const SizedBox(height: 24),
            _buildBadgesSection(s, historyProvider),
            const SizedBox(height: 24),
            _buildCalendarSection(s, historyProvider),
            const SizedBox(height: 24),
            _buildQuizStatsSection(s, historyProvider),
          ],
        ),
      ),
    );
  }

  // ── 유저 헤더 ──────────────────────────────

  Widget _buildUserHeader(AppStrings s, dynamic user, LinearGradient gradient) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
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
                  user?.displayName ?? s.profileLearner,
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

  // ── 학습 요약 ──────────────────────────────

  Widget _buildStudySummary(BuildContext context, AppStrings s, HistoryProvider provider) {
    final t = s.profileTimesUnit;
    final d = s.profileDaysUnit;
    final i = s.profileItemsUnit;
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
          Text(
            s.profileSummary,
            style: const TextStyle(
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
                  label: s.profileTodayStudy,
                  value: '${provider.todayStudyCount}$t',
                  color: const Color(0xFF667eea),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryTile(
                  icon: Icons.library_books,
                  label: s.profileTotalStudy,
                  value: '${provider.coreStudyCount}$t',
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
                  label: s.profileTodayQuiz,
                  value: '${provider.todayQuizCount}$t',
                  color: const Color(0xFFe96743),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryTile(
                  icon: Icons.assignment,
                  label: s.profileTotalQuiz,
                  value: '${provider.coreQuizCount}$t',
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
                  label: s.profileAccuracy,
                  value: '${provider.overallQuizAccuracy.toStringAsFixed(1)}%',
                  color: const Color(0xFF43a047),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryTile(
                  icon: Icons.local_fire_department,
                  label: s.profileStreak,
                  value: '${provider.currentStreak}$d',
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
                  label: s.profileWrongNote,
                  value: '${provider.wrongAnswerCount}$i',
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryTile(
                  icon: Icons.auto_stories,
                  label: s.profileTotalSessions,
                  value: '${provider.totalStudySessions}$t',
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

  // ── 배지 섹션 ──────────────────────────────

  Widget _buildBadgesSection(AppStrings s, HistoryProvider hp) {
    final badges = _getBadgeList(s);
    final earnedCount = badges.where((b) => b.check(hp)).length;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.profileBadges,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '$earnedCount / ${badges.length}',
                style: const TextStyle(fontSize: 14, color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.82,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: badges.map((badge) {
              final earned = badge.check(hp);
              return _buildBadgeItem(badge, earned);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(_BadgeDef badge, bool earned) {
    return Tooltip(
      message: badge.desc,
      child: Container(
        decoration: BoxDecoration(
          color: earned
              ? badge.color.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: earned
                ? badge.color.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: earned ? 1.0 : 0.18,
                    child: Text(
                      badge.emoji,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      badge.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 9,
                        height: 1.2,
                        color: earned ? Colors.white70 : Colors.white24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!earned)
              const Positioned(
                top: 5,
                right: 5,
                child: Icon(Icons.lock_outline, size: 11, color: Colors.white24),
              ),
          ],
        ),
      ),
    );
  }

  // ── 학습 활동 캘린더 ────────────────────────

  Widget _buildCalendarSection(AppStrings s, HistoryProvider provider) {
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
          Text(
            s.profileActivityChart,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildLegend(Colors.blue, s.profileWord),
              const SizedBox(width: 16),
              _buildLegend(Colors.purple, s.profileSentence),
              const SizedBox(width: 16),
              _buildLegend(Colors.orange, s.profileQuiz),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: List.generate(41, (index) {
              final date = now.subtract(Duration(days: 30 - index));
              final dateKey =
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              final types = activity[dateKey] ?? [];

              final hasWord = types.any((t) => t == 'word');
              final hasSentence = types.any((t) => t == 'sentence');
              final hasQuiz = types.any((t) => t.startsWith('quiz'));

              final isToday = date.day == now.day &&
                  date.month == now.month &&
                  date.year == now.year;
              final isFuture = date.isAfter(now);

              return Tooltip(
                message: isFuture
                    ? '${date.month}/${date.day}'
                    : '${date.month}/${date.day} — ${types.isEmpty ? s.profileNoActivity : "${types.length}${s.profileItemsUnit}"}',
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.white54)),
      ],
    );
  }

  // ── 난이도별 퀴즈 통계 ──────────────────────

  Widget _buildQuizStatsSection(AppStrings s, HistoryProvider provider) {
    final stats = provider.quizStatsByDifficulty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.profileQuizStats,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard(s, s.n1Label, stats['N1']!, const Color(0xFF9c27b0))),
            const SizedBox(width: 8),
            Expanded(child: _buildStatCard(s, s.n2Label, stats['N2']!, const Color(0xFF5c6bc0))),
            const SizedBox(width: 8),
            Expanded(child: _buildStatCard(s, s.n3Label, stats['N3']!, const Color(0xFFe96743))),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildStatCard(s, s.n4Label, stats['N4']!, const Color(0xFFf5a623))),
            const SizedBox(width: 8),
            Expanded(child: _buildStatCard(s, s.n5Label, stats['N5']!, const Color(0xFF43a047))),
            const SizedBox(width: 8),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(AppStrings s, String label, Map<String, dynamic> data, Color color) {
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
            '$quizCount${s.profileTimesUnit}',
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
            s.profileAvgAccuracy,
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
