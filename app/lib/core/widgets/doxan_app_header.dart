import 'package:docxan/app/theme/palette.dart';
import 'package:flutter/material.dart';

class DoxanAppHeader extends StatelessWidget {
  const DoxanAppHeader({super.key, required this.onProfile});

  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              'assets/images/logo_docxan.png',
              height: 28,
              filterQuality: FilterQuality.high,
              semanticLabel: 'Docxan',
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Docxan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onProfile,
            icon: const Icon(Icons.account_circle_outlined),
            color: context.palette.ink,
          ),
        ],
      ),
    );
  }
}
