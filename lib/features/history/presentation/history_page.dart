import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/database/database.dart';
import '../domain/history_provider.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() =>
      _HistoryPageState();
}

class _HistoryPageState
    extends ConsumerState<HistoryPage> {
  final _searchController = TextEditingController();
  String? _searchQuery;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync =
        ref.watch(historyProvider(_searchQuery));

    return Scaffold(
      appBar: AppBar(title: const Text('历史记录')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() =>
                    _searchQuery =
                        v.isEmpty ? null : v),
                decoration: InputDecoration(
                  hintText: '🔍 搜索情绪或日期...',
                  prefixIcon: const Icon(Icons.search,
                      color: Color(0xFFb8a99a)),
                ),
              ),
            ),
            Expanded(
              child: recordsAsync.when(
                data: (records) {
                  if (records.isEmpty) {
                    return const Center(
                      child: Text(
                        '还没有记录\n开始你的第一条吧',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFFb8a99a),
                            fontSize: 15),
                      ),
                    );
                  }

                  final grouped =
                      <String, List<MoodRecord>>{};
                  for (final r in records) {
                    final dateStr = DateFormat(
                            'yyyy-MM-dd')
                        .format(r.createdAt);
                    grouped
                        .putIfAbsent(dateStr, () => [])
                        .add(r);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets
                        .symmetric(horizontal: 20),
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final dateStr = grouped.keys
                          .elementAt(index);
                      final dayRecords =
                          grouped[dateStr]!;
                      return _TimelineDay(
                        dateStr: dateStr,
                        records: dayRecords,
                      );
                    },
                  );
                },
                loading: () => const Center(
                    child:
                        CircularProgressIndicator()),
                error: (e, _) => Center(
                    child: Text('加载失败: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineDay extends StatelessWidget {
  final String dateStr;
  final List<MoodRecord> records;

  const _TimelineDay(
      {required this.dateStr, required this.records});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('M 月 d 日')
        .format(DateTime.parse(dateStr));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              date,
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFa89888)),
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: records.map((record) {
              final moodColor = Color(
                  AppConstants.moodColors[
                          record.mainMood] ??
                      0xFF9e968e);
              final emoji = (AppConstants.emotions
                      .firstWhere((e) =>
                          e['key'] ==
                          record.mainMood))[
                  'emoji'] as String;

              return Padding(
                padding:
                    const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: moodColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(
                                    0xFFfaf8f5),
                                width: 2),
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 60,
                          color: const Color(
                              0xFFe8e0d8),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding:
                            const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(
                                  14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withAlpha(6),
                              blurRadius: 8,
                              offset: const Offset(
                                  0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(emoji,
                                style: const TextStyle(
                                    fontSize: 22)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    record.mainMood,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(
                                            0xFF5c4a3a)),
                                  ),
                                  Text(
                                    '强度 ${record.intensity}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(
                                            0xFFb8a99a)),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                                Icons.chevron_right,
                                color: Color(
                                    0xFFd0c8bc),
                                size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
