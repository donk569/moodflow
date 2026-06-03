import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../recommend/engine/recommend_engine.dart';
import '../domain/record_provider.dart';

class RecordPage extends ConsumerStatefulWidget {
  const RecordPage({super.key});

  @override
  ConsumerState<RecordPage> createState() =>
      _RecordPageState();
}

class _RecordPageState
    extends ConsumerState<RecordPage> {
  final _textController = TextEditingController();
  String? _imagePath;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(
        source: ImageSource.gallery);
    if (result != null) {
      setState(() => _imagePath = result.path);
    }
  }

  Future<void> _submit() async {
    final activity =
        GoRouterState.of(context).extra as Activity?;
    await ref
        .read(recordProvider.notifier)
        .submitRecord(
          textContent: _textController.text.isNotEmpty
              ? _textController.text
              : null,
          imagePath: _imagePath,
          activity: activity,
        );
    if (mounted &&
        ref.read(recordProvider).isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('打卡成功 ✨')),
      );
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final activity =
        GoRouterState.of(context).extra as Activity?;
    final state = ref.watch(recordProvider);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              if (activity != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFf0f8e8),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${activity.icon} 已完成：${activity.name}',
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7aaa6e)),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              const Text(
                '做得很好 ✨\n想记录一下现在的感受吗？',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF5c4a3a),
                  fontWeight: FontWeight.w300,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _RecordTile(
                icon: '📷',
                title: '添加照片',
                subtitle: '拍一张或从相册选',
                onTap: _pickImage,
                trailing: _imagePath != null
                    ? const Icon(Icons.check_circle,
                        color: Color(0xFF7aaa6e),
                        size: 20)
                    : null,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: '写几句……（可选）',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                        color: Color(0xFFb8a99a)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _RecordTile(
                icon: '🎤',
                title: '录制语音',
                subtitle: '说说今天的感受（最长 60 秒）',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isSubmitting
                      ? null
                      : _submit,
                  child: Text(state.isSubmitting
                      ? '记录中...'
                      : '✅ 完成记录'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: state.isSubmitting
                      ? null
                      : _submit,
                  child: const Text('跳过，直接打卡'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _RecordTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFfef0e0),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(icon,
                    style: const TextStyle(
                        fontSize: 20)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 15,
                        color:
                            Color(0xFF5c4a3a)),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 12,
                        color:
                            Color(0xFFb8a99a)),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
