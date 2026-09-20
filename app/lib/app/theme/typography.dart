import 'package:docxan/app/theme/colors.dart';
import 'package:flutter/material.dart';

abstract final class DocxanTypography {
  static TextTheme textTheme(TextTheme base) {
    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: DocxanColors.ink,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: DocxanColors.ink,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: DocxanColors.ink,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: DocxanColors.ink,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        height: 1.4,
        color: DocxanColors.ink,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        height: 1.45,
        color: DocxanColors.inkMuted,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
}
