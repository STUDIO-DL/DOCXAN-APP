import 'package:doxan/app/theme/colors.dart';
import 'package:flutter/material.dart';

abstract final class DoxanTypography {
  static TextTheme textTheme(TextTheme base) {
    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: DoxanColors.ink,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: DoxanColors.ink,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: DoxanColors.ink,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: DoxanColors.ink,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        height: 1.4,
        color: DoxanColors.ink,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        height: 1.45,
        color: DoxanColors.inkMuted,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
}
