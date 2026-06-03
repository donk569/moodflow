import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/providers/core_providers.dart';
import '../domain/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final streak =
        ref.watch(streakDaysProvider).valueOrNull ?? 0;
    final totalRecords =
        ref.watch(totalRecordsProvider).valueOrNull ?? 0;
    final frequentMood =
        ref.watch(frequentMoodProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 20),
          child: userAsync.when(
            data: (user) {
              if (user == null) return const SizedBox();

              final genderConfig = AppConstants.genderConfig[
                  user.gender == 'female'
                      ? 'female'
                      : 'male']!;
              final roleIcon =
                  genderConfig['roleIcon'] as String;
              final daysSince =
                  DateTime.now()
                          .difference(user.createdAt)
                          .inDays +
                      1;

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withAlpha(8),
                          blurRadius: 10,
                          offset:
                              const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Color(genderConfig[
                                    'bgColor']
                                as int),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(roleIcon,
                                style: const TextStyle(
                                    fontSize: 26)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              user.nickname,
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(
                                      0xFF5c4a3a),
                                  fontWeight:
                                      FontWeight.w500),
                            ),
                            Text(
                              '${user.role == 'puppy' ? '小狗' : '小猫'}模式 · 已陪伴 $daysSince 天',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(
                                      0xFFb8a99a)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _StatCard(
                          value: '$streak',
                          label: '连续天数'),
                      const SizedBox(width: 10),
                      _StatCard(
                          value: '$totalRecords',
                          label: '总记录'),
                      const SizedBox(width: 10),
                      _StatCard(
                          value: frequentMood ?? '--',
                          label: '常驻情绪'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildMenu(context),
                ],
              );
            },
            loading: () => const Center(
                child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text('加载失败: $e')),
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    final items = [
      ('📊', '数据统计', '周报 / 月报'),
      ('🔑', 'AI 设置', 'OpenAI API Key'),
      ('☁️', '云同步', '未连接'),
      ('🎨', '切换角色', '小狗 ↔ 小猫'),
      ('⚙️', '通用设置', ''),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children:
            items.asMap().entries.map((entry) {
          final i = entry.key;
          final (icon, title, subtitle) =
              entry.value;
          return InkWell(
            onTap: title == 'AI 设置' ||
                    title == '通用设置'
                ? () => context
                    .push('/profile/settings')
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: i < items.length - 1
                  ? const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Color(
                                  0xFFf5f0ea),
                              width: 1)),
                    )
                  : null,
              child: Row(
                children: [
                  Text(icon,
                      style: const TextStyle(
                          fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                          fontSize: 14,
                          color:
                              Color(0xFF5c4a3a)),
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(
                          fontSize: 12,
                          color:
                              Color(0xFFb8a99a)),
                    ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right,
                      color: Color(0xFFd0c8bc),
                      size: 20),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard(
      {required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                  fontSize: 22,
                  color: Color(0xFFc8a080),
                  fontWeight: FontWeight.w400),
            ),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFb8a99a)),
            ),
          ],
        ),
      ),
    );
  }
}
