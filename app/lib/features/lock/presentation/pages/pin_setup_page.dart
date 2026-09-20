import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/app/router/routes.dart';
import 'package:docxan/app/theme/colors.dart';
import 'package:docxan/core/constants/app_constants.dart';
import 'package:docxan/core/security/pin_service.dart';
import 'package:docxan/core/session/session_controller.dart';
import 'package:docxan/core/widgets/doxan_pin_pad.dart';
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

class _PinSetupPageState extends ConsumerState<PinSetupPage> {
  late _PinPhase _phase;
  String _buffer = '';
  String _first = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _phase = widget.changing ? _PinPhase.current : _PinPhase.create;
  }

  Future<void> _append(String digit) async {
    if (_buffer.length >= AppConstants.pinLength) return;
    setState(() {
      _buffer += digit;
      _error = null;
    });
    if (_buffer.length != AppConstants.pinLength) return;

    switch (_phase) {
      case _PinPhase.current:
        final ok = await ref.read(pinServiceProvider).verify(_buffer);
        if (!mounted) return;
        if (!ok) {
          setState(() {
            _buffer = '';
            _error = AppLocalizations.of(context).pinWrong;
          });
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
      backgroundColor: DocxanColors.paper,
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
            const Icon(Icons.pin_outlined, size: 36, color: DocxanColors.ink),
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
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: DocxanColors.danger)),
            ],
            const Spacer(),
            DoxanPinPad(onDigit: _append, onBackspace: _backspace),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
