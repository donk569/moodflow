import 'package:flutter/material.dart';
import '../../engine/recommend_engine.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final bool isFavorite;
  final VoidCallback onNext;
  final VoidCallback onStart;
  final VoidCallback onFavorite;
  final VoidCallback onHide;
  final VoidCallback onMinimal;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.isFavorite,
    required this.onNext,
    required this.onStart,
    required this.onFavorite,
    required this.onHide,
    required this.onMinimal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.3, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut)),
              child: FadeTransition(
                  opacity: animation, child: child),
            );
          },
          child: Container(
            key: ValueKey(activity.name),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFf0f8e8),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(activity.icon,
                        style: const TextStyle(
                            fontSize: 32)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  activity.name,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Color(0xFF3c2a1a),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFa89888)),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: onNext,
                      child:
                          const Text('换个试试 →'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: onStart,
                      child: const Text('开始行动 ✓'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActionChip(
              label: isFavorite ? '❤️ 已收藏' : '🤍 收藏',
              onTap: onFavorite,
            ),
            _ActionChip(
              label: '👎 不感兴趣',
              onTap: onHide,
            ),
            _ActionChip(
              label: '⚡ 最低行动',
              backgroundColor: const Color(0xFF8a7968),
              foregroundColor: Colors.white,
              onTap: onMinimal,
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const _ActionChip({
    required this.label,
    this.onTap,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: backgroundColor != null
                    ? Colors.transparent
                    : const Color(0xFFe8e0d8)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: foregroundColor ??
                  const Color(0xFF8a7968),
            ),
          ),
        ),
      ),
    );
  }
}
