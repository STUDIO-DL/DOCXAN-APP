import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/app/router/routes.dart';
import 'package:docxan/core/constants/app_constants.dart';
import 'package:docxan/core/security/pin_service.dart';
import 'package:docxan/core/session/session_controller.dart';
import 'package:docxan/core/widgets/doxan_pin_pad.dart';
import 'package:docxan/core/widgets/pin_lockout_countdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _PinPhase { current, create, confirm }

class PinSetupPage extends ConsumerStatefulWidget {
  const PinSetupPage({super.key, this.changing = false});

  final bool changing;

  @override
  ConsumerState<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends ConsumerState<PinSetupPage>
    with PinLockoutCountdown<PinSetupPage> {
  late _PinPhase _phase;
  String _buffer = '';
  String _first = '';
  String? _error;
  bool _checking = false;

  bool get _currentLocked => _phase == _PinPhase.current && lockedOut;

  @override
  void initState() {
    super.initState();
    _phase = widget.changing ? _PinPhase.current : _PinPhase.create;
    if (widget.changing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _restoreLockout());
    }
  }

  Future<void> _restoreLockout() async {
    final remaining = await ref.read(pinServiceProvider).remainingLockout();
    if (!mounted || remaining <= Duration.zero) return;
    startLockout(remaining);
  }

  Future<void> _append(String digit) async {
    if (_checking || _currentLocked) return;
    if (_buffer.length >= AppConstants.pinLength) return;
    setState(() {
      _buffer += digit;
      _error = null;
    });
    if (_buffer.length != AppConstants.pinLength) return;

    switch (_phase) {
      case _PinPhase.current:
        _checking = true;
        final PinCheck result;
        try {
          result = await ref.read(pinServiceProvider).check(_buffer);
        } finally {
          _checking = false;
        }
        if (!mounted) return;
        if (!result.ok) {
          setState(() {
            _buffer = '';
            _error = result.lockedOut
                ? null
                : AppLocalizations.of(context).pinWrong;
          });
          if (result.lockedOut) startLockout(result.lockout);
          return;
        }
        setState(() {
          _buffer = '';
          _phase = _PinPhase.create;
        });
      case _PinPhase.create:
        setState(() {
          _first = _buffer;
          _buffer = '';
          _phase = _PinPhase.confirm;
        });
      case _PinPhase.confirm:
        if (_buffer != _first) {
          setState(() {
            _buffer = '';
            _first = '';
            _phase = _PinPhase.create;
            _error = AppLocalizations.of(context).pinMismatch;
          });
          return;
        }
        await ref.read(pinServiceProvider).setPin(_buffer);
        if (!mounted) return;
        ref.read(sessionProvider.notifier).setPinConfigured(enabled: true);
        if (widget.changing) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).pinChanged)),
          );
          context.go(AppRoutes.settings);
        } else {
          context.go(AppRoutes.home);
        }
    }
  }

  void _backspace() {
    if (_buffer.isEmpty) return;
    setState(() => _buffer = _buffer.substring(0, _buffer.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = switch (_phase) {
      _PinPhase.current => l10n.pinCurrentTitle,
      _PinPhase.create => l10n.pinSetupTitle,
      _PinPhase.confirm => l10n.pinConfirmTitle,
    };
    final subtitle = switch (_phase) {
      _PinPhase.current => l10n.lockSubtitle,
      _PinPhase.create => l10n.pinSetupSubtitle,
      _PinPhase.confirm => l10n.pinConfirmSubtitle,
    };

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: widget.changing
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.go(AppRoutes.settings),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Icon(
              Icons.pin_outlined,
              size: 36,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 28),
            DoxanPinDots(length: _buffer.length),
            if (_currentLocked || _error != null) ...[
              const SizedBox(height: 16),
              Text(
                _currentLocked
                    ? l10n.pinTooManyAttempts(lockoutSeconds)
                    : _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const Spacer(),
            DoxanPinPad(
              onDigit: _append,
              onBackspace: _backspace,
              enabled: !_currentLocked,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
