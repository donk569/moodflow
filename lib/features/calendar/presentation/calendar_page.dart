import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_constants.dart';
import '../domain/calendar_provider.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() =>
      _CalendarPageState();
}

class _CalendarPageState
    extends ConsumerState<CalendarPage> {
  late DateTime _currentMonth;
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final calendarAsync =
        ref.watch(calendarProvider(_currentMonth));

    return Scaffold(
      appBar: AppBar(title: const Text('日历')),
      body: SafeArea(
        child: calendarAsync.when(
          data: (data) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                          Icons.chevron_left),
                      onPressed: () => setState(() {
                        _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month - 1);
                      }),
                    ),
                    Text(
                      '${_currentMonth.year}.${_currentMonth.month.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF5c4a3a),
                          fontWeight:
                              FontWeight.w400),
                    ),
                    IconButton(
                      icon: const Icon(
                          Icons.chevron_right),
                      onPressed: () => setState(() {
                        _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month + 1);
                      }),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20),
                child: Row(
                  children: const [
                    '日',
                    '一',
                    '二',
                    '三',
                    '四',
                    '五',
                    '六'
                  ]
                      .map((d) => Expanded(
                            child: Center(
                              child: Text(d,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Color(
                                          0xFFb8a99a))),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20),
                  child:
                      _buildCalendarGrid(data),
                ),
              ),
              if (_selectedDate != null &&
                  data.records[_selectedDate] != null)
                _buildDateDetail(data),
            ],
          ),
          loading: () => const Center(
              child: CircularProgressIndicator()),
          error: (e, _) =>
              Center(child: Text('加载失败: $e')),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(CalendarData data) {
    final firstDay = DateTime(_currentMonth.year,
        _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year,
        _currentMonth.month + 1, 0);
    final startOffset = firstDay.weekday % 7;

    final cells = <Widget>[];
    for (int i = 0; i < startOffset; i++) {
      cells.add(const SizedBox());
    }

    for (int day = 1; day <= lastDay.day; day++) {
      final dateStr =
          '${_currentMonth.year}-${_currentMonth.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      final record = data.records[dateStr];
      final isSelected = _selectedDate == dateStr;

      Color? bgColor;
      if (record != null) {
        final moodColor = AppConstants
            .moodColors[record.mainMood];
        if (moodColor != null) {
          bgColor = Color(moodColor).withAlpha(40);
        }
      }

      cells.add(
        GestureDetector(
          onTap: () => setState(
              () => _selectedDate = dateStr),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius:
                  BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(
                      color:
                          const Color(0xFFc8a080),
                      width: 2)
                  : null,
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 14,
                    color: bgColor != null
                        ? const Color(0xFF5c4a3a)
                        : const Color(0xFFb8a99a),
                  ),
                ),
                if (record != null)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Color(AppConstants.moodColors[
                              record.mainMood] ??
                          0xFF9e968e),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      childAspectRatio: 0.9,
      children: cells,
    );
  }

  Widget _buildDateDetail(CalendarData data) {
    final record =
        data.records[_selectedDate!]!;
    final moodColor = Color(
        AppConstants.moodColors[record.mainMood] ??
            0xFF9e968e);

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: moodColor.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getEmojiForMood(record.mainMood),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '强度 ${record.intensity}',
            style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF5c4a3a)),
          ),
        ],
      ),
    );
  }

  String _getEmojiForMood(String key) {
    final emotion = AppConstants.emotions
        .firstWhere((e) => e['key'] == key);
    return emotion['emoji'] as String;
  }
}
