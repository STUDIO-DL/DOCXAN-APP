import 'package:docxan/app/theme/palette.dart';
import 'package:flutter/material.dart';

abstract final class DocxanTypography {
  static TextTheme textTheme(
    TextTheme base, {
    DocxanPalette palette = DocxanPalette.light,
  }) {
    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: palette.ink,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: palette.ink,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: palette.ink,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: palette.ink,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        height: 1.4,
        color: palette.ink,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        height: 1.45,
        color: palette.inkMuted,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
}
