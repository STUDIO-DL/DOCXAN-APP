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

  static ThemeData dark() {
    const ink = Color(0xFFF9FAFB);
    const muted = Color(0xFF9CA3AF);
    const surface = Color(0xFF111827);
    const canvas = Color(0xFF1F2937);
    const hairline = Color(0xFF374151);
    const scheme = ColorScheme.dark(
      primary: DocxanColors.accent,
      onPrimary: Color(0xFF052E16),
      secondary: muted,
      surface: surface,
      onSurface: ink,
      error: Color(0xFFF87171),
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: surface,
      visualDensity: VisualDensity.standard,
    );
    return base.copyWith(
      textTheme: DocxanTypography.textTheme(base.textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: hairline,
        elevation: 0,
      ),
      dividerColor: hairline,
      sliderTheme: const SliderThemeData(
        activeTrackColor: DocxanColors.accent,
        inactiveTrackColor: hairline,
        thumbColor: ink,
        overlayColor: Color(0x2216A34A),
        trackHeight: 4,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: DocxanColors.accent,
          foregroundColor: const Color(0xFF052E16),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
