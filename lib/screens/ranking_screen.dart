import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/ranking_provider.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    {'label': '최상 (N1)', 'difficulty': 'N1'},
    {'label': '상상 (N2)', 'difficulty': 'N2'},
    {'label': '상 (N3)', 'difficulty': 'N3'},
    {'label': '중 (N4)', 'difficulty': 'N4'},
    {'label': '하 (N5)', 'difficulty': 'N5'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RankingProvider>().loadRankings(difficulty: 'N1');
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final difficulty = _tabs[_tabController.index]['difficulty']!;
    context.read<RankingProvider>().changeDifficulty(difficulty);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('랭킹'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFFe96743),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: _tabs.map((t) => Tab(text: t['label'])).toList(),
        ),
      ),
      body: Consumer<RankingProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (provider.rankings.isEmpty) {
            return const Center(
              child: Text(
                '아직 퀴즈 기록이 없습니다.',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            );
          }

          return _buildRankingList(context, provider);
        },
      ),
    );
  }

  Widget _buildRankingList(BuildContext context, RankingProvider provider) {
    final currentUid = context.read<AuthProvider>().user?.uid;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.rankings.length,
      itemBuilder: (context, index) {
        final item = provider.rankings[index];
        final rank = index + 1;
        final uid = item['uid'] as String;
        final displayName = item['displayName'] as String;
        final quizCount = item['quizCount'] as int;
        final bestRate = item['bestRate'] as double;
        final isCurrentUser = uid == currentUid;

        Color rankColor;
        IconData? rankIcon;
        switch (rank) {
          case 1:
            rankColor = const Color(0xFFFFD700); // gold
            rankIcon = Icons.emoji_events;
            break;
          case 2:
            rankColor = const Color(0xFFC0C0C0); // silver
            rankIcon = Icons.emoji_events;
            break;
          case 3:
            rankColor = const Color(0xFFCD7F32); // bronze
            rankIcon = Icons.emoji_events;
            break;
          default:
            rankColor = Colors.white54;
            rankIcon = null;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? const Color(0xFF667eea).withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: isCurrentUser
                ? Border.all(
                    color: const Color(0xFF667eea).withValues(alpha: 0.5),
                    width: 1.5)
                : null,
          ),
          child: Row(
            children: [
              // 순위
              SizedBox(
                width: 40,
                child: rankIcon != null
                    ? Icon(rankIcon, color: rankColor, size: 28)
                    : Center(
                        child: Text(
                          '$rank',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: rankColor,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              // 이름
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isCurrentUser
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667eea),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ME',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '퀴즈 $quizCount회',
                      style:
                          const TextStyle(fontSize: 13, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              // 최고 점수
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${bestRate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: bestRate >= 80
                          ? Colors.green
                          : bestRate >= 50
                              ? Colors.orange
                              : Colors.redAccent,
                    ),
                  ),
                  const Text(
                    '최고점수',
                    style: TextStyle(fontSize: 11, color: Colors.white38),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
