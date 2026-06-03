import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/database/dao.dart';

class OnboardPage extends ConsumerStatefulWidget {
  const OnboardPage({super.key});

  @override
  ConsumerState<OnboardPage> createState() =>
      _OnboardPageState();
}

class _OnboardPageState
    extends ConsumerState<OnboardPage> {
  final _pageController = PageController();
  final _nicknameController = TextEditingController();
  String? _gender;
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    if (_nicknameController.text.isEmpty ||
        _gender == null) {
      return;
    }

    final db = ref.read(databaseProvider);
    final prefs = await ref
        .read(sharedPrefsFutureProvider.future);
    final role =
        _gender == 'male' ? 'puppy' : 'kitty';

    await db.createUser(
      nickname: _nicknameController.text,
      gender: _gender!,
      role: role,
    );

    await prefs.setBool('onboarding_complete', true);

    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfaf8f5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Container(
                    width:
                        i == _currentPage ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 4),
                    decoration: BoxDecoration(
                      color: i == _currentPage
                          ? const Color(0xFFc8a080)
                          : const Color(0xFFe8e0d8),
                      borderRadius:
                          BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) =>
                    setState(() => _currentPage = i),
                children: [
                  Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Text('🌈',
                          style: TextStyle(
                              fontSize: 48)),
                      const SizedBox(height: 16),
                      const Text(
                        '欢迎来到 MoodFlow',
                        style: TextStyle(
                          fontSize: 22,
                          color: Color(0xFF5c4a3a),
                          fontWeight:
                              FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '一个温柔的地方\n记录你的每一种心情',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFa89888),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () => _pageController
                            .nextPage(
                          duration: const Duration(
                              milliseconds: 300),
                          curve: Curves.easeOut,
                        ),
                        child: const Text('开始 →'),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Text('✏️',
                          style: TextStyle(
                              fontSize: 36)),
                      const SizedBox(height: 12),
                      const Text(
                        '怎么称呼你？',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF5c4a3a),
                          fontWeight:
                              FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 260,
                        child: TextField(
                          controller:
                              _nicknameController,
                          textAlign:
                              TextAlign.center,
                          decoration:
                              const InputDecoration(
                            hintText: '你的昵称',
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _nicknameController
                                .text.isEmpty
                            ? null
                            : () => _pageController
                                .nextPage(
                              duration: const Duration(
                                  milliseconds:
                                      300),
                              curve: Curves.easeOut,
                            ),
                        child: const Text('继续 →'),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Text('💫',
                          style: TextStyle(
                              fontSize: 36)),
                      const SizedBox(height: 12),
                      const Text(
                        '选择一个陪伴角色',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF5c4a3a),
                          fontWeight:
                              FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          _GenderCard(
                            icon: '🐶',
                            label: '男生',
                            sublabel: '小狗陪伴',
                            bgColor: const Color(
                                0xFFe8f4fd),
                            isSelected:
                                _gender == 'male',
                            onTap: () =>
                                setState(() =>
                                    _gender =
                                        'male'),
                          ),
                          const SizedBox(width: 16),
                          _GenderCard(
                            icon: '🐱',
                            label: '女生',
                            sublabel: '小猫陪伴',
                            bgColor: const Color(
                                0xFFffe8f0),
                            isSelected:
                                _gender == 'female',
                            onTap: () =>
                                setState(() =>
                                    _gender =
                                        'female'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _gender == null
                            ? null
                            : _complete,
                        child: const Text(
                            '🎉 开始我的情绪之旅'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String icon;
  final String label;
  final String sublabel;
  final Color bgColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.bgColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200),
        width: 120,
        padding:
            const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: bgColor.withAlpha(40),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFc8a080)
                : const Color(0xFFe0d8cc),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(icon,
                    style: const TextStyle(
                        fontSize: 30)),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF5c4a3a),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              sublabel,
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFb8a99a)),
            ),
          ],
        ),
      ),
    );
  }
}
