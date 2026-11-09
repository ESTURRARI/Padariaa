import 'package:flutter/material.dart';

// Paleta: tons de café + amora
const espresso = Color(0xFF3E2723);
const cafe = Color(0xFF6D4C41);
const caramelo = Color(0xFFC08A5B);
const creme = Color(0xFFFAF3EA);
const amora = Color(0xFF6A1B5D);

ThemeData temaAmora() {
  final cs = ColorScheme.fromSeed(seedColor: cafe).copyWith(primary: cafe, secondary: amora, tertiary: caramelo);
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    scaffoldBackgroundColor: creme,
    appBarTheme: const AppBarTheme(backgroundColor: espresso, foregroundColor: creme),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: amora, foregroundColor: Colors.white),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(backgroundColor: amora, foregroundColor: Colors.white)),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(foregroundColor: cafe)),
  );
}
