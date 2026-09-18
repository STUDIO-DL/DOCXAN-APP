import 'package:doxan/app/l10n/app_localizations.dart';
import 'package:doxan/app/theme/colors.dart';
import 'package:flutter/material.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: DoxanColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.scan,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: DoxanColors.paper,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: CustomPaint(
                  painter: const _ViewfinderPainter(),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
              child: Column(
                children: [
                  Text(
                    l10n.scanPlaceholderTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: DoxanColors.paper,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.scanPlaceholderBody,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFBDBDBD),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: DoxanColors.paper, width: 4),
                    ),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        color: DoxanColors.paper,
                        shape: BoxShape.circle,
                      ),
                    ),
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

class _ViewfinderPainter extends CustomPainter {
  const _ViewfinderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DoxanColors.paper
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const arm = 36.0;
    final rect = Offset.zero & size;
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(arm, 0), paint);
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(0, arm), paint);
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(-arm, 0), paint);
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(0, arm), paint);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(arm, 0), paint);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(0, -arm), paint);
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + const Offset(-arm, 0),
      paint,
    );
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + const Offset(0, -arm),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
