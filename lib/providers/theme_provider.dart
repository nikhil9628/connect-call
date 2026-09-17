import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themePrefKey = 'is_dark_mode_enabled';

  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    loadThemeFromPrefs();
  }

  Future<void> loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_themePrefKey)) {
      _isDarkMode = prefs.getBool(_themePrefKey) ?? false;
      _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themePrefKey, isDark);
  }
}
