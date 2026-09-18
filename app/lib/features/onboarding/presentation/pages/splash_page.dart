import 'package:doxan/app/theme/colors.dart';
import 'package:doxan/core/constants/app_constants.dart';
import 'package:doxan/core/session/session_controller.dart';
import 'package:doxan/core/widgets/doxan_logo.dart';
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
    Future<void>.delayed(AppConstants.splashDuration, () {
      if (!mounted) return;
      ref.read(sessionProvider.notifier).finishSplash();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: DoxanColors.paper,
      body: Center(child: DoxanLogo(size: 220)),
    );
  }
}
