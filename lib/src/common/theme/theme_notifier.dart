/// Theme state management with Riverpod code generation.
///
/// Uses @riverpod annotations for automatic provider generation.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_notifier.g.dart';

/// Immutable state class for theme configuration.
@immutable
class ThemeState {
  const ThemeState({this.themeMode = ThemeMode.system});

  final ThemeMode themeMode;

  bool get isDarkMode => themeMode == ThemeMode.dark;
  bool get isLightMode => themeMode == ThemeMode.light;
  bool get isSystemMode => themeMode == ThemeMode.system;

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(themeMode: themeMode ?? this.themeMode);
  }
}

/// Theme mode notifier using Riverpod code generation.
/// Named ThemeModeNotifier to avoid conflict with Flutter's Theme and AppTheme.
@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  static const String _themePreferenceKey = 'theme_mode';

  @override
  ThemeState build() {
    // Schedule loading preferences after build
    Future.microtask(_loadThemePreference);
    return const ThemeState();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themePreferenceKey);

      if (savedTheme != null) {
        final themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.name == savedTheme,
          orElse: () => ThemeMode.system,
        );
        state = ThemeState(themeMode: themeMode);
      }
    } on Exception {
      // Keep default theme on error
    }
  }

  Future<void> _saveThemePreference(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themePreferenceKey, mode.name);
    } on Exception {
      // Ignore save errors
    }
  }

  Future<void> setDarkMode() async {
    state = state.copyWith(themeMode: ThemeMode.dark);
    await _saveThemePreference(ThemeMode.dark);
  }

  Future<void> setLightMode() async {
    state = state.copyWith(themeMode: ThemeMode.light);
    await _saveThemePreference(ThemeMode.light);
  }

  Future<void> setSystemMode() async {
    state = state.copyWith(themeMode: ThemeMode.system);
    await _saveThemePreference(ThemeMode.system);
  }

  Future<void> toggleTheme() async {
    if (state.isDarkMode) {
      await setLightMode();
    } else {
      await setDarkMode();
    }
  }
}
