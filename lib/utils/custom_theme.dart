import 'package:flutter/material.dart';

class CustomThemes {
  static final navy = (
    light: ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF013F64),
        onPrimary: Color(0xFFF8FAFC),
        secondary: Color(0xFFF1F5F9),
        onSecondary: Color(0xFF0F172A),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF020817),
        error: Color(0xFFEF4444),
        onError: Color(0xFFF8FAFC),
        outline: Color(0xFFE2E8F0),
        surfaceContainerHighest: Color(0xFFF1F5F9),
      ),
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
    ),
    dark: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF013F64),
        onPrimary: Color(0xFFF8FAFC),
        secondary: Color(0xFF1E293B),
        onSecondary: Color(0xFFF8FAFC),
        surface: Color(0xFF020817),
        onSurface: Color(0xFFF8FAFC),
        error: Color(0xFF7F1D1D),
        onError: Color(0xFFF8FAFC),
        outline: Color(0xFF1E293B),
        surfaceContainerHighest: Color(0xFF1E293B),
      ),
      scaffoldBackgroundColor: const Color(0xFF020817),
    ),
  );
}
