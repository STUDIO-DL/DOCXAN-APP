import 'package:docxan/app/theme/colors.dart';
import 'package:docxan/app/theme/typography.dart';
import 'package:flutter/material.dart';

abstract final class DocxanTheme {
  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: DocxanColors.accent,
      onPrimary: DocxanColors.paper,
      secondary: DocxanColors.inkMuted,
      surface: DocxanColors.paper,
      onSurface: DocxanColors.ink,
      error: DocxanColors.danger,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: DocxanColors.paper,
      visualDensity: VisualDensity.standard,
    );

    return base.copyWith(
      textTheme: DocxanTypography.textTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: DocxanColors.canvas,
        foregroundColor: DocxanColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: DocxanColors.paper,
        indicatorColor: DocxanColors.chip,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? DocxanColors.ink : DocxanColors.inkMuted,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DocxanColors.paper,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DocxanColors.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DocxanColors.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DocxanColors.ink, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: DocxanColors.accent,
          foregroundColor: DocxanColors.paper,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DocxanColors.ink,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: DocxanColors.hairline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      dividerColor: DocxanColors.hairline,
      sliderTheme: const SliderThemeData(
        activeTrackColor: DocxanColors.accent,
        inactiveTrackColor: DocxanColors.hairline,
        thumbColor: DocxanColors.paper,
        overlayColor: Color(0x2216A34A),
        trackHeight: 4,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
      ),
    );
  }
}
