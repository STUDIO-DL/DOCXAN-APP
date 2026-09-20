import 'package:docxan/app/theme/colors.dart';
import 'package:flutter/material.dart';

class DocxanSearchBar extends StatelessWidget {
  const DocxanSearchBar({
    super.key,
    required this.hint,
    this.onTap,
    this.controller,
    this.onChanged,
    this.autofocus = false,
  });

  final String hint;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final field = Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: DocxanColors.chip,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: DocxanColors.inkMuted, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: onTap != null
                ? Text(
                    hint,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: DocxanColors.inkMuted,
                    ),
                  )
                : TextField(
                    controller: controller,
                    autofocus: autofocus,
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      hintText: hint,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
          ),
        ],
      ),
    );

    if (onTap == null) return field;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: field,
      ),
    );
  }
}
