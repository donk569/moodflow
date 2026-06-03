import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../emotion/domain/emotion_provider.dart';
import '../domain/recommend_provider.dart';
import 'widgets/activity_card.dart';

class RecommendPage extends ConsumerStatefulWidget {
  const RecommendPage({super.key});

  @override
  ConsumerState<RecommendPage> createState() =>
      _RecommendPageState();
}

class _RecommendPageState
    extends ConsumerState<RecommendPage> {
  @override
  void initState() {
    super.initState();
    final emotion =
        ref.read(emotionProvider).mainEmotion;
    if (emotion != null) {
      ref
          .read(recommendProvider.notifier)
          .initialize(emotion.key);
    }
  }

  @override
  Widget build(BuildContext context) {
    final emotion =
        ref.watch(emotionProvider).mainEmotion;
    final recommend = ref.watch(recommendProvider);

    if (emotion == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('请先选择情绪')),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFfff0e8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${emotion.emoji} ${emotion.label} · 强度 ${ref.watch(emotionProvider).intensity}',
                  style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8a6a58)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16),
                child: Text(
                  _getPrompt(emotion.key),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF5c4a3a),
                    fontWeight: FontWeight.w300,
                    height: 1.4,
                  ),
                ),
              ),
              if (recommend.currentActivity != null)
                ActivityCard(
                  activity: recommend.currentActivity!,
                  isFavorite: recommend.favorites.contains(
                      recommend.currentActivity!.name),
                  onNext: () => ref
                      .read(recommendProvider.notifier)
                      .nextActivity(),
                  onStart: () {
                    context.push('/record',
                        extra: recommend.currentActivity!);
                  },
                  onFavorite: () => ref
                      .read(recommendProvider.notifier)
                      .toggleFavorite(),
                  onHide: () => ref
                      .read(recommendProvider.notifier)
                      .hideActivity(),
                  onMinimal: () => ref
                      .read(recommendProvider.notifier)
                      .enableMinimalMode(),
                ),
              if (recommend.currentActivity == null)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    '暂时没有更多推荐了',
                    style: TextStyle(
                        color: Color(0xFFb8a99a)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPrompt(String moodKey) {
    const prompts = {
      'happy': '真为你开心 ✨\n想把这份快乐记录下来吗？',
      'anxious': '试着做些小事\n让情绪慢慢降落',
      'sad': '没关系\n难过也是需要被看见的',
      'tired': '你辛苦了\n做些小事情照顾自己吧',
      'irritated': '烦躁的时候\n慢下来也许有帮助',
      'empty': '有时候什么都不想做\n也是可以的',
      'calm': '平静是很珍贵的状态\n享受这一刻',
      'bored': '找一件小事\n让此刻变得有意思',
      'excited': '充满能量的时候\n做什么都闪闪发光',
    };
    return prompts[moodKey] ?? '试着做些小事';
  }
}
