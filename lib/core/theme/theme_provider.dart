import 'package:flutter/material.dart';

class ThemeProvider extends InheritedWidget {
  final ThemeMode themeMode;
  final void Function(ThemeMode) onThemeChanged;

  const ThemeProvider({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
    required super.child,
  });

  static ThemeProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
  }

  bool get isDark => themeMode == ThemeMode.dark;

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return themeMode != oldWidget.themeMode;
  }
}
