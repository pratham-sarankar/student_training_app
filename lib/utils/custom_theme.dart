import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class CustomThemes {
  static final navy = (
    light: FThemeData(
      debugLabel: 'Navy Light ThemeData',
      colors: const FColors(
        brightness: Brightness.light,
        barrier: Color(0x33000000),
        background: Color(0xFFFFFFFF),
        foreground: Color(0xFF020817),
        primary: Color(0xFF013F64),
        primaryForeground: Color(0xFFF8FAFC),
        secondary: Color(0xFFF1F5F9),
        secondaryForeground: Color(0xFF0F172A),
        muted: Color(0xFFF1F5F9),
        mutedForeground: Color(0xFF64748B),
        destructive: Color(0xFFEF4444),
        destructiveForeground: Color(0xFFF8FAFC),
        error: Color(0xFFEF4444),
        errorForeground: Color(0xFFF8FAFC),
        border: Color(0xFFE2E8F0),
      ),
    ),
    dark: FThemeData(
      debugLabel: 'Navy Dark ThemeData',
      colors: const FColors(
        brightness: Brightness.dark,
        barrier: Color(0x7A000000),
        background: Color(0xFF020817),
        foreground: Color(0xFFF8FAFC),
        primary: Color(0xFF013F64),
        primaryForeground: Color(0xFFF8FAFC),
        secondary: Color(0xFF1E293B),
        secondaryForeground: Color(0xFFF8FAFC),
        muted: Color(0xFF1E293B),
        mutedForeground: Color(0xFF94A3B8),
        destructive: Color(0xFF7F1D1D),
        destructiveForeground: Color(0xFFF8FAFC),
        error: Color(0xFF7F1D1D),
        errorForeground: Color(0xFFF8FAFC),
        border: Color(0xFF1E293B),
      ),
    ),
  );
}
