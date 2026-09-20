import 'package:docxan/app/theme/colors.dart';
import 'package:docxan/core/constants/app_constants.dart';
import 'package:docxan/core/data/user_settings_repository.dart';
import 'package:docxan/core/session/session_controller.dart';
import 'package:docxan/core/widgets/docxan_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_boot);
  }

  Future<void> _boot() async {
    try {
      await ref
          .read(sessionProvider.notifier)
          .hydrate()
          .timeout(const Duration(milliseconds: 800));
    } catch (_) {}
    try {
      final settings = await ref.read(userSettingsRepositoryProvider).load();
      ref
          .read(sessionProvider.notifier)
          .setBackupEnabled(enabled: settings.backupEnabled);
    } catch (_) {}
    await Future<void>.delayed(AppConstants.splashDuration);
    if (!mounted) return;
    ref.read(sessionProvider.notifier).finishSplash();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: DocxanColors.paper,
      body: Center(child: DocxanLogo(size: 220)),
    );
  }
}
