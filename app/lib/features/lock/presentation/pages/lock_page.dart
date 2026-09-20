import 'package:docxan/app/l10n/app_localizations.dart';
import 'package:docxan/app/router/routes.dart';
import 'package:docxan/app/theme/colors.dart';
import 'package:docxan/core/constants/app_constants.dart';
import 'package:docxan/core/session/session_controller.dart';
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

  void _append(String digit) {
    if (_pin.length >= AppConstants.pinLength) return;
    setState(() => _pin += digit);
    if (_pin.length == AppConstants.pinLength) {
      ref.read(sessionProvider.notifier).unlock();
      context.go(AppRoutes.home);
    }
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
            Text(l10n.lockSubtitle, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(AppConstants.pinLength, (index) {
                final filled = index < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? DocxanColors.ink : DocxanColors.hairline,
                  ),
                );
              }),
            ),
            const Spacer(),
            _Pad(onDigit: _append, onBackspace: _backspace),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Pad extends StatelessWidget {
  const _Pad({required this.onDigit, required this.onBackspace});

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', 'âŒ«'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final key in keys)
            if (key.isEmpty)
              const SizedBox.shrink()
            else
              TextButton(
                onPressed: () => key == 'âŒ«' ? onBackspace() : onDigit(key),
                child: Text(
                  key,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
        ],
      ),
    );
  }
}
