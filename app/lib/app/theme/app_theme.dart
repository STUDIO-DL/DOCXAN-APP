import 'package:doxan/app/theme/colors.dart';
import 'package:doxan/app/theme/typography.dart';
import 'package:flutter/material.dart';

abstract final class DoxanTheme {
  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: DoxanColors.ink,
      onPrimary: DoxanColors.paper,
      secondary: DoxanColors.inkMuted,
      surface: DoxanColors.paper,
      onSurface: DoxanColors.ink,
      error: DoxanColors.danger,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: DoxanColors.canvas,
      visualDensity: VisualDensity.standard,
    );

    return base.copyWith(
      textTheme: DoxanTypography.textTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: DoxanColors.canvas,
        foregroundColor: DoxanColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: DoxanColors.paper,
        indicatorColor: DoxanColors.chip,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? DoxanColors.ink : DoxanColors.inkMuted,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DoxanColors.paper,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DoxanColors.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DoxanColors.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DoxanColors.ink, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: DoxanColors.ink,
          foregroundColor: DoxanColors.paper,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DoxanColors.ink,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: DoxanColors.hairline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      dividerColor: DoxanColors.hairline,
    );
  }
}
