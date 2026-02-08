import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../models/study_record.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('공부한 내역'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          Consumer<HistoryProvider>(
            builder: (context, provider, _) {
              if (provider.records.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: () => _showClearDialog(context, provider),
                icon: const Icon(Icons.delete_outline, color: Colors.white54),
              );
            },
          ),
        ],
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (provider.records.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, color: Colors.white24, size: 64),
                  SizedBox(height: 16),
                  Text(
                    '아직 공부한 내역이 없습니다',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '학습이나 퀴즈를 완료하면 여기에 기록됩니다',
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.records.length,
            itemBuilder: (context, index) {
              final record = provider.records[index];
              return _buildHistoryCard(context, record, provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(
      BuildContext context, StudyRecord record, HistoryProvider provider) {
    final dateStr =
        '${record.date.year}.${record.date.month.toString().padLeft(2, '0')}.${record.date.day.toString().padLeft(2, '0')} '
        '${record.date.hour.toString().padLeft(2, '0')}:${record.date.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HistoryDetailScreen(record: record),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 아이콘
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getTypeColor(record.type).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTypeIcon(record.type),
                    color: _getTypeColor(record.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.typeLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
                // 결과
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      record.resultText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getTypeColor(record.type),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Icon(Icons.arrow_forward_ios,
                        color: Colors.white24, size: 14),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'word':
        return const Color(0xFF667eea);
      case 'sentence':
        return const Color(0xFF764ba2);
      case 'quiz_word':
      case 'quiz_sentence':
        return const Color(0xFFe96743);
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'word':
        return Icons.text_fields;
      case 'sentence':
        return Icons.article;
      case 'quiz_word':
      case 'quiz_sentence':
        return Icons.quiz;
      default:
        return Icons.history;
    }
  }

  void _showClearDialog(BuildContext context, HistoryProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a4e),
        title: const Text('내역 삭제', style: TextStyle(color: Colors.white)),
        content: const Text(
          '모든 공부 내역을 삭제하시겠습니까?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(ctx);
            },
            child:
                const Text('삭제', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
