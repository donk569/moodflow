import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/emotion_provider.dart';

class EmotionGrid extends ConsumerWidget {
  const EmotionGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(emotionProvider);
    final role =
        ref.watch(userRoleProvider).valueOrNull ?? 'puppy';
    final genderConfig =
        AppConstants.genderConfig[
            role == 'puppy' ? 'male' : 'female']!;
    final bgColor = Color(genderConfig['bgColor'] as int);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemCount: AppConstants.emotions.length,
      itemBuilder: (context, index) {
        final emotion = AppConstants.emotions[index];
        final key = emotion['key'] as String;
        final isSelected = selection.mainEmotion?.key == key;
        final isSubSelected =
            selection.subEmotion?.key == key;

        return GestureDetector(
          onTap: () {
            if (selection.mainEmotion == null) {
              ref
                  .read(emotionProvider.notifier)
                  .selectMainEmotion(key);
            } else {
              ref
                  .read(emotionProvider.notifier)
                  .selectSubEmotion(key);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform: isSelected
                ? Matrix4.diagonal3Values(1.12, 1.12, 1.0)
                : Matrix4.identity(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: bgColor.withAlpha(180),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      emotion['emoji'] as String,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  emotion['label'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onSurface
                        : const Color(0xFF8a7968),
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
                if (isSubSelected)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFc8a080),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
