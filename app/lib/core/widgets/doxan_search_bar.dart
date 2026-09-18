import 'package:doxan/app/theme/colors.dart';
import 'package:doxan/app/theme/spacing.dart';
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
    return Material(
      color: DoxanColors.paper,
      borderRadius: BorderRadius.circular(DoxanSpacing.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DoxanSpacing.radius),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DoxanSpacing.radius),
            border: Border.all(color: DoxanColors.hairline),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: DoxanColors.inkMuted),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hint,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: DoxanColors.inkMuted,
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
