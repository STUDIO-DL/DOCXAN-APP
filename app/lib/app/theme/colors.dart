import 'package:flutter/material.dart';

abstract final class DocxanColors {
  static const Color ink = Color(0xFF111827);
  static const Color inkMuted = Color(0xFF6B7280);
  static const Color paper = Color(0xFFFFFFFF);
  static const Color canvas = Color(0xFFF7F8FA);
  static const Color hairline = Color(0xFFE5E7EB);
  static const Color chip = Color(0xFFF3F4F6);
  static const Color accent = Color(0xFF16A34A);
  static const Color accentMuted = Color(0xFFD8F0E2);
  static const Color accentSoft = Color(0xFFDCFCE7);
  static const Color danger = Color(0xFFB42318);
  static const Color ok = Color(0xFF16A34A);
  static const Color pdf = Color(0xFFE11D48);
  static const Color docx = Color(0xFF2563EB);
  static const Color image = Color(0xFF16A34A);

  static Color forFormat(String format) {
    switch (format.toUpperCase()) {
      case 'PDF':
        return pdf;
      case 'DOCX':
      case 'DOC':
        return docx;
      case 'JPG':
      case 'JPEG':
      case 'PNG':
        return image;
      default:
        return inkMuted;
    }
  }

  static Color forFolder(String id) {
    switch (id) {
      case 'personal':
        return inkMuted;
      case 'universidad':
        return docx;
      case 'trabajo':
        return accent;
      case 'dni':
        return const Color(0xFF7C3AED);
      case 'finanzas':
        return const Color(0xFFD97706);
      case 'viajes':
        return const Color(0xFF0D9488);
      case 'salud':
        return pdf;
      default:
        const palette = <Color>[
          accent,
          docx,
          Color(0xFF7C3AED),
          Color(0xFFD97706),
          Color(0xFF0D9488),
          pdf,
        ];
        return palette[id.hashCode.abs() % palette.length];
    }
  }
}
