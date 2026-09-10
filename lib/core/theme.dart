import 'package:flutter/material.dart';

class SpotFitColors {
  static const background = Color(0xFF0B0B0F);
  static const surface = Color(0xFF16161E);
  static const surfaceHigh = Color(0xFF1F1F2A);
  static const lime = Color(0xFFC8F542);
  static const coral = Color(0xFFFF6B4A);
  static const muted = Color(0xFF8B8B9A);
  static const text = Color(0xFFF5F5F7);
}

ThemeData buildSpotFitTheme() {
  const scheme = ColorScheme.dark(
    primary: SpotFitColors.lime,
    onPrimary: Color(0xFF111111),
    secondary: SpotFitColors.coral,
    surface: SpotFitColors.surface,
    onSurface: SpotFitColors.text,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: SpotFitColors.background,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: SpotFitColors.text,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SpotFitColors.surfaceHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: SpotFitColors.muted),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: SpotFitColors.lime,
        foregroundColor: const Color(0xFF111111),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: SpotFitColors.surface,
      indicatorColor: SpotFitColors.lime.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? SpotFitColors.lime : SpotFitColors.muted,
        );
      }),
    ),
  );
}
