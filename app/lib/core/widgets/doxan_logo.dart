import 'package:doxan/app/theme/colors.dart';
import 'package:flutter/material.dart';

class DoxanLogo extends StatelessWidget {
  const DoxanLogo({super.key, this.size = 160, this.showWordmark = false});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: size,
          filterQuality: FilterQuality.high,
          semanticLabel: 'Docxan',
        ),
        if (showWordmark) ...[
          const SizedBox(height: 8),
          Text(
            'Docxan',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
              color: DoxanColors.ink,
            ),
          ),
        ],
      ],
    );
  }
}
