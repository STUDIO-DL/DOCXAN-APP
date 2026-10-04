import 'package:docxan/app/theme/palette.dart';
import 'package:flutter/material.dart';

class DocxanLogo extends StatelessWidget {
  const DocxanLogo({super.key, this.size = 160, this.showWordmark = true});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.12),
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: 0.68,
            child: Image.asset(
              'assets/images/logo_docxan.png',
              height: size,
              filterQuality: FilterQuality.high,
              semanticLabel: 'Docxan',
            ),
          ),
        ),
        if (showWordmark) ...[
          const SizedBox(height: 8),
          Text(
            'Docxan',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
              color: context.palette.ink,
            ),
          ),
        ],
      ],
    );
  }
}
