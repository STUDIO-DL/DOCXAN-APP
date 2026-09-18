import 'package:doxan/app/theme/colors.dart';
import 'package:flutter/material.dart';

class DoxanEmptyState extends StatelessWidget {
  const DoxanEmptyState({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.folder_outlined,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: DoxanColors.inkMuted),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
