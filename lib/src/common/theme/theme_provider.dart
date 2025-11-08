import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ThemeProvider manages the app's theme mode and persists user preference
class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _loadThemePreference();
  }
  static const String _themePreferenceKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // In system mode, we can't determine without context
      // Default to false for the getter
      return false;
    }
    return _themeMode == ThemeMode.dark;
  }

  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  /// Load saved theme preference from shared preferences
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt(_themePreferenceKey);
    final idx =
        (stored != null && stored >= 0 && stored < ThemeMode.values.length)
        ? stored
        : 0;
    _themeMode = ThemeMode.values[idx];
    notifyListeners();
  }

  /// Save theme preference to shared preferences
  Future<void> _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themePreferenceKey, _themeMode.index);
  }

  /// Set theme to light mode
  Future<void> setLightMode() async {
    _themeMode = ThemeMode.light;
    notifyListeners();
    await _saveThemePreference();
  }

  /// Set theme to dark mode
  Future<void> setDarkMode() async {
    _themeMode = ThemeMode.dark;
    notifyListeners();
    await _saveThemePreference();
  }

  /// Set theme to system mode (follows device settings)
  Future<void> setSystemMode() async {
    _themeMode = ThemeMode.system;
    notifyListeners();
    await _saveThemePreference();
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setDarkMode();
    } else {
      await setLightMode();
    }
  }

  /// Set theme mode directly
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _saveThemePreference();
  }
}
