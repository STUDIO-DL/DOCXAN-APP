import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/app/router/routes.dart';
import 'package:docxan/app/theme/colors.dart';
import 'package:docxan/core/constants/app_constants.dart';
import 'package:docxan/core/security/biometric_service.dart';
import 'package:docxan/core/security/pin_service.dart';
import 'package:docxan/core/session/session_controller.dart';
import 'package:docxan/core/widgets/doxan_pin_pad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LockPage extends ConsumerStatefulWidget {
  const LockPage({super.key});

  @override
  ConsumerState<LockPage> createState() => _LockPageState();
}

class _LockPageState extends ConsumerState<LockPage> {
  String _pin = '';
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryBiometrics();
    });
  }

  Future<void> _tryBiometrics() async {
    final session = ref.read(sessionProvider);
    if (!session.biometricsEnabled) return;
    final ok = await ref
        .read(biometricServiceProvider)
        .authenticate(AppLocalizations.of(context).unlockWithBiometrics);
    if (!mounted || !ok) return;
    ref.read(sessionProvider.notifier).unlock();
    context.go(AppRoutes.home);
  }

  Future<void> _append(String digit) async {
    if (_busy || _pin.length >= AppConstants.pinLength) return;
    setState(() {
      _pin += digit;
      _error = null;
    });
    if (_pin.length != AppConstants.pinLength) return;
    setState(() => _busy = true);
    final ok = await ref.read(pinServiceProvider).verify(_pin);
    if (!mounted) return;
    if (ok) {
      ref.read(sessionProvider.notifier).unlock();
      context.go(AppRoutes.home);
      return;
    }
    setState(() {
      _pin = '';
      _busy = false;
      _error = AppLocalizations.of(context).pinWrong;
    });
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final biometrics = ref.watch(sessionProvider).biometricsEnabled;
    return Scaffold(
      backgroundColor: DocxanColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const Icon(Icons.lock_outline, size: 36, color: DocxanColors.ink),
            const SizedBox(height: 16),
            Text(l10n.lockTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              l10n.lockSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            DoxanPinDots(length: _pin.length),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: DocxanColors.danger)),
            ],
            const Spacer(),
            if (biometrics)
              TextButton.icon(
                onPressed: _tryBiometrics,
                icon: const Icon(Icons.fingerprint),
                label: Text(l10n.unlockWithBiometrics),
              ),
            DoxanPinPad(onDigit: _append, onBackspace: _backspace),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
