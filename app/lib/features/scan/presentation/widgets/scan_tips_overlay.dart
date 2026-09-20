import 'package:doxan/app/l10n/app_localizations.dart';
import 'package:doxan/app/theme/colors.dart';
import 'package:flutter/material.dart';

class ScanTipsOverlay extends StatelessWidget {
  const ScanTipsOverlay({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 280),
        child: DecoratedBox(
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.28)),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  _TipCard(icon: Icons.wb_sunny_outlined, label: l10n.scanTipLighting),
                  _TipCard(icon: Icons.crop_free, label: l10n.scanTipFrame),
                  _TipCard(icon: Icons.blur_off_outlined, label: l10n.scanTipShadows),
                  _TipCard(icon: Icons.stay_current_portrait, label: l10n.scanTipParallel),
                  _TipCard(icon: Icons.layers_clear_outlined, label: l10n.scanTipBackground),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 168),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xB2FFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x66FFFFFF)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: DoxanColors.ink, size: 22),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: DoxanColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
