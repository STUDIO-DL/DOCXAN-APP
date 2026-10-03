import 'package:docxan/app/theme/colors.dart';
import 'package:flutter/material.dart';

@immutable
class DocxanPalette extends ThemeExtension<DocxanPalette> {
  const DocxanPalette({
    required this.paper,
    required this.surface,
    required this.canvas,
    required this.chip,
    required this.hairline,
    required this.ink,
    required this.inkMuted,
    required this.accent,
    required this.accentSoft,
    required this.onAccent,
    required this.danger,
  });

  /// Main page background (scaffolds, nav bar, inputs).
  final Color paper;

  /// Elevated surfaces (dialogs, bottom sheets, menus, cards).
  final Color surface;

  /// Slightly offset surface (app bars, panels, thumbnails backdrop).
  final Color canvas;

  /// Filled chips, search fields, nav indicators.
  final Color chip;

  /// Borders and dividers.
  final Color hairline;

  /// Primary text and icons.
  final Color ink;

  /// Secondary text and icons.
  final Color inkMuted;

  final Color accent;

  /// Tinted accent background (highlighted rows, selected chips).
  final Color accentSoft;

  /// Text/icons drawn on top of [accent].
  final Color onAccent;

  final Color danger;

  static const DocxanPalette light = DocxanPalette(
    paper: DocxanColors.paper,
    surface: DocxanColors.paper,
    canvas: DocxanColors.canvas,
    chip: DocxanColors.chip,
    hairline: DocxanColors.hairline,
    ink: DocxanColors.ink,
    inkMuted: DocxanColors.inkMuted,
    accent: DocxanColors.accent,
    accentSoft: DocxanColors.accentSoft,
    onAccent: DocxanColors.paper,
    danger: DocxanColors.danger,
  );

  static const DocxanPalette dark = DocxanPalette(
    paper: Color(0xFF0F1419),
    surface: Color(0xFF1F2731),
    canvas: Color(0xFF181F27),
    chip: Color(0xFF27303B),
    hairline: Color(0xFF333E4B),
    ink: Color(0xFFF3F4F6),
    inkMuted: Color(0xFF9CA3AF),
    accent: Color(0xFF22C55E),
    accentSoft: Color(0xFF14331F),
    onAccent: Color(0xFF052E16),
    danger: Color(0xFFF87171),
  );

  @override
  DocxanPalette copyWith({
    Color? paper,
    Color? surface,
    Color? canvas,
    Color? chip,
    Color? hairline,
    Color? ink,
    Color? inkMuted,
    Color? accent,
    Color? accentSoft,
    Color? onAccent,
    Color? danger,
  }) {
    return DocxanPalette(
      paper: paper ?? this.paper,
      surface: surface ?? this.surface,
      canvas: canvas ?? this.canvas,
      chip: chip ?? this.chip,
      hairline: hairline ?? this.hairline,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      onAccent: onAccent ?? this.onAccent,
      danger: danger ?? this.danger,
    );
  }

  @override
  DocxanPalette lerp(ThemeExtension<DocxanPalette>? other, double t) {
    if (other is! DocxanPalette) return this;
    return DocxanPalette(
      paper: Color.lerp(paper, other.paper, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      chip: Color.lerp(chip, other.chip, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

extension DocxanPaletteContext on BuildContext {
  /// Theme-aware Docxan colors. Falls back to the light palette if the
  /// extension is missing (e.g. widgets pumped without [DocxanTheme]).
  DocxanPalette get palette =>
      Theme.of(this).extension<DocxanPalette>() ?? DocxanPalette.light;
}
