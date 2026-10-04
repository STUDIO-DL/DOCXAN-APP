import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/app/router/routes.dart';
import 'package:docxan/core/constants/app_constants.dart';
import 'package:docxan/core/security/biometric_service.dart';
import 'package:docxan/core/security/pin_service.dart';
import 'package:docxan/core/session/session_controller.dart';
import 'package:docxan/core/widgets/doxan_pin_pad.dart';
import 'package:docxan/core/widgets/pin_lockout_countdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LockPage extends ConsumerStatefulWidget {
  const LockPage({super.key});

  @override
  ConsumerState<LockPage> createState() => _LockPageState();
}

class _LockPageState extends ConsumerState<LockPage>
    with PinLockoutCountdown<LockPage> {
  String _pin = '';
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreLockout();
      _tryBiometrics();
    });
  }

  Future<void> _restoreLockout() async {
    final remaining = await ref.read(pinServiceProvider).remainingLockout();
    if (!mounted || remaining <= Duration.zero) return;
    startLockout(remaining);
  }

  Future<void> _tryBiometrics() async {
    final session = ref.read(sessionProvider);
    if (!session.biometricsEnabled) return;
    final ok = await ref
        .read(biometricServiceProvider)
        .authenticate(AppLocalizations.of(context).unlockWithBiometrics);
    if (!mounted || !ok) return;
    await ref.read(pinServiceProvider).resetAttempts();
    if (!mounted) return;
    ref.read(sessionProvider.notifier).unlock();
    context.go(AppRoutes.home);
  }

  Future<void> _append(String digit) async {
    if (_busy || lockedOut || _pin.length >= AppConstants.pinLength) return;
    setState(() {
      _pin += digit;
      _error = null;
    });
    if (_pin.length != AppConstants.pinLength) return;
    setState(() => _busy = true);
    final result = await ref.read(pinServiceProvider).check(_pin);
    if (!mounted) return;
    if (result.ok) {
      ref.read(sessionProvider.notifier).unlock();
      context.go(AppRoutes.home);
      return;
    }
    setState(() {
      _pin = '';
      _busy = false;
      _error = result.lockedOut ? null : AppLocalizations.of(context).pinWrong;
    });
    if (result.lockedOut) startLockout(result.lockout);
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Icon(
              Icons.lock_outline,
              size: 36,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(height: 16),
            Text(l10n.lockTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              l10n.lockSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            DoxanPinDots(length: _pin.length),
            if (lockedOut || _error != null) ...[
              const SizedBox(height: 16),
              Text(
                lockedOut ? l10n.pinTooManyAttempts(lockoutSeconds) : _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const Spacer(),
            if (biometrics)
              TextButton.icon(
                onPressed: _tryBiometrics,
                icon: const Icon(Icons.fingerprint),
                label: Text(l10n.unlockWithBiometrics),
              ),
            DoxanPinPad(
              onDigit: _append,
              onBackspace: _backspace,
              enabled: !lockedOut,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
