import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/core_providers.dart';
import 'features/onboard/presentation/onboard_page.dart';

class MoodFlowApp extends ConsumerWidget {
  const MoodFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final onboardAsync =
        ref.watch(onboardingCompleteProvider);

    return onboardAsync.when(
      data: (isComplete) {
        if (!isComplete) return const OnboardPage();
        return MaterialApp.router(
          title: 'MoodFlow',
          theme: AppTheme.lightTheme,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => MaterialApp.router(
        title: 'MoodFlow',
        theme: AppTheme.lightTheme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
