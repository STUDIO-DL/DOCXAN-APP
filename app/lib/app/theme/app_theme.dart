import 'package:docxan/app/theme/colors.dart';
import 'package:docxan/app/theme/palette.dart';
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
    return _build(
      palette: DocxanPalette.light,
      scheme: scheme,
      brightness: Brightness.light,
    );
  }

  static ThemeData dark() {
    const p = DocxanPalette.dark;
    final scheme = ColorScheme.dark(
      primary: p.accent,
      onPrimary: p.onAccent,
      primaryContainer: p.accentSoft,
      onPrimaryContainer: p.ink,
      secondary: p.inkMuted,
      onSecondary: p.paper,
      surface: p.paper,
      onSurface: p.ink,
      onSurfaceVariant: p.inkMuted,
      surfaceContainerLowest: p.paper,
      surfaceContainerLow: p.surface,
      surfaceContainer: p.surface,
      surfaceContainerHigh: p.surface,
      surfaceContainerHighest: p.chip,
      outline: const Color(0xFF4B5563),
      outlineVariant: p.hairline,
      error: p.danger,
      onError: const Color(0xFF450A0A),
      inverseSurface: p.ink,
      onInverseSurface: p.paper,
      inversePrimary: DocxanColors.accent,
    );
    return _build(palette: p, scheme: scheme, brightness: Brightness.dark);
  }

  static ThemeData _build({
    required DocxanPalette palette,
    required ColorScheme scheme,
    required Brightness brightness,
  }) {
    final p = palette;
    final isDark = brightness == Brightness.dark;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.paper,
      visualDensity: VisualDensity.standard,
      extensions: <ThemeExtension<dynamic>>[p],
    );

    final themed = base.copyWith(
      textTheme: DocxanTypography.textTheme(base.textTheme, palette: p),
      appBarTheme: AppBarTheme(
        backgroundColor: p.canvas,
        foregroundColor: p.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.paper,
        indicatorColor: p.chip,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? p.ink : p.inkMuted,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.paper,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.ink, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: p.onAccent,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.ink,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: p.hairline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      dividerColor: p.hairline,
      sliderTheme: SliderThemeData(
        activeTrackColor: p.accent,
        inactiveTrackColor: p.hairline,
        thumbColor: isDark ? p.ink : p.paper,
        overlayColor: const Color(0x2216A34A),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      ),
    );

    if (!isDark) return themed;

    // Light relies on Material 3 defaults (which already resolve to white
    // surfaces); dark pins every elevated surface so nothing falls back to
    // light-only colors.
    return themed.copyWith(
      canvasColor: p.paper,
      cardColor: p.surface,
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: themed.textTheme.titleLarge,
        contentTextStyle: themed.textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        modalBackgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: p.hairline,
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.chip,
        selectedColor: p.accentSoft,
        side: BorderSide(color: p.hairline),
        labelStyle: themed.textTheme.labelLarge?.copyWith(color: p.ink),
        secondaryLabelStyle:
            themed.textTheme.labelLarge?.copyWith(color: p.ink),
      ),
      dividerTheme: DividerThemeData(color: p.hairline),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.accent),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? p.onAccent
              : p.inkMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? p.accent : p.chip,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : p.hairline,
        ),
      ),
    );
  }
}
