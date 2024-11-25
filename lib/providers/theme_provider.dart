import 'package:flutter/material.dart';
import '../data/services/preferences_service.dart';

class ThemeProvider extends ChangeNotifier {
  late ThemeData _currentTheme;
  late bool _isDarkMode;
  final PreferencesService _preferencesService = PreferencesService();

  ThemeProvider() {
    _isDarkMode = false;
    _currentTheme = lightTheme;
    _initializeTheme();
  }

  ThemeData get currentTheme => _currentTheme;
  bool get isDarkMode => _isDarkMode;

  static final ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: Colors.blue,
    colorScheme: ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
    ),
    scaffoldBackgroundColor: Colors.white,
  );

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: Colors.teal,
    colorScheme: ColorScheme.dark(
      primary: Colors.teal,
      secondary: Colors.tealAccent,
    ),
    scaffoldBackgroundColor: Colors.grey[900],
  );

  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    _currentTheme = isDark ? darkTheme : lightTheme;
    await _preferencesService.setDarkMode(isDark);
    notifyListeners();
  }

  Future<void> _initializeTheme() async {
    await _preferencesService.initialize();
    _isDarkMode = _preferencesService.getDarkMode();
    _currentTheme = _isDarkMode ? darkTheme : lightTheme;
    notifyListeners();
  }
}
