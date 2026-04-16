import 'package:flutter/material.dart';

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF416FDF),
  onPrimary: Color(0xFFFFFFFF),
  secondary: Color(0xFF6EAEE7),
  onSecondary: Color(0xFFFFFFFF),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  surface: Color(0xFFFCFDF6),
  onSurface: Color(0xFF1A1C18),
  shadow: Color(0xFF000000),
  outlineVariant: Color(0xFFC2C8BC),
);

const darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF416FDF),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF6EAEE7),
    onSecondary: Color(0xFFFFFFFF),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A1C18),
    shadow: Color(0xFF000000),
    outlineVariant: Color(0xFFC2C8BC)
);

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: lightColorScheme,
);