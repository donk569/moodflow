import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/emotion_provider.dart';

class IntensitySlider extends ConsumerWidget {
  const IntensitySlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intensity =
        ref.watch(emotionProvider).intensity;

    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('轻微',
                style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFb8a99a))),
            Text('中等',
                style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFb8a99a))),
            Text('强烈',
                style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFb8a99a))),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 20),
            activeTrackColor: const Color(0xFFc8a080),
            inactiveTrackColor: const Color(0xFFe8e0d8),
            thumbColor: Colors.white,
            overlayColor:
                const Color(0xFFc8a080).withAlpha(40),
          ),
          child: Slider(
            value: intensity.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (v) => ref
                .read(emotionProvider.notifier)
                .setIntensity(v.round()),
          ),
        ),
        Text(
          '强度：$intensity',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF5c4a3a),
          ),
        ),
      ],
    );
  }
}
