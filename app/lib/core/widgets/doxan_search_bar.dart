import 'package:docxan/app/theme/palette.dart';
import 'package:docxan/app/theme/spacing.dart';
import 'package:flutter/material.dart';

class DoxanSearchBar extends StatelessWidget {
  const DoxanSearchBar({
    super.key,
    required this.hint,
    required this.onTap,
  });

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.paper,
      borderRadius: BorderRadius.circular(DocxanSpacing.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DocxanSpacing.radius),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DocxanSpacing.radius),
            border: Border.all(color: palette.hairline),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: palette.inkMuted),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hint,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: palette.inkMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
