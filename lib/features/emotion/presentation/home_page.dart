import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/core_providers.dart';
import '../domain/emotion_provider.dart';
import 'widgets/emotion_grid.dart';
import 'widgets/intensity_slider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(emotionProvider);
    final streak =
        ref.watch(streakDaysProvider).valueOrNull ?? 0;
    final today = DateFormat('yyyy.MM.dd · EEEE', 'zh_CN')
        .format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('MoodFlow'),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: Color(0xFF5c4a3a),
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Text(
                today,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFb8a99a),
                  letterSpacing: 1,
                ),
              ),
              if (streak > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '已连续记录 $streak 天',
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFc8a080)),
                  ),
                ),
              const SizedBox(height: 24),
              const Text(
                '你现在感觉如何？',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF5c4a3a),
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 28),
              const EmotionGrid(),
              if (selection.mainEmotion != null) ...[
                const SizedBox(height: 28),
                const IntensitySlider(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.push('/recommend'),
                    child: const Text('看看可以做什么 →'),
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
