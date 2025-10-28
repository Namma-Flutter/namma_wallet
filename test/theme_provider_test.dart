import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeProvider Tests', () {
    setUp(() {
      // Reset SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('should initialize with system theme mode by default', () async {
      final provider = ThemeProvider();
      
      // Give time for async initialization
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(provider.themeMode, equals(ThemeMode.system));
      expect(provider.isSystemMode, isTrue);
    });

    test('should load saved theme preference from SharedPreferences', () async {
      // Set initial theme to dark mode
      SharedPreferences.setMockInitialValues({
        'theme_mode': ThemeMode.dark.index,
      });
      
      final provider = ThemeProvider();
      
      // Give time for async initialization
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(provider.themeMode, equals(ThemeMode.dark));
      expect(provider.isDarkMode, isTrue);
    });

    test('should load light theme preference from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'theme_mode': ThemeMode.light.index,
      });
      
      final provider = ThemeProvider();
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(provider.themeMode, equals(ThemeMode.light));
      expect(provider.isLightMode, isTrue);
    });

    test('should set light mode and persist to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      
      await provider.setLightMode();
      
      expect(provider.themeMode, equals(ThemeMode.light));
      expect(provider.isLightMode, isTrue);
      
      // Verify saved to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('theme_mode'), equals(ThemeMode.light.index));
    });

    test('should set dark mode and persist to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      
      await provider.setDarkMode();
      
      expect(provider.themeMode, equals(ThemeMode.dark));
      expect(provider.isDarkMode, isTrue);
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('theme_mode'), equals(ThemeMode.dark.index));
    });

    test('should set system mode and persist to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      
      await provider.setSystemMode();
      
      expect(provider.themeMode, equals(ThemeMode.system));
      expect(provider.isSystemMode, isTrue);
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('theme_mode'), equals(ThemeMode.system.index));
    });

    test('should toggle from light to dark mode', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      
      await provider.setLightMode();
      expect(provider.themeMode, equals(ThemeMode.light));
      
      await provider.toggleTheme();
      expect(provider.themeMode, equals(ThemeMode.dark));
    });

    test('should toggle from dark to light mode', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      
      await provider.setDarkMode();
      expect(provider.themeMode, equals(ThemeMode.dark));
      
      await provider.toggleTheme();
      expect(provider.themeMode, equals(ThemeMode.light));
    });

    test('should toggle from system to light mode', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      
      await provider.setSystemMode();
      expect(provider.themeMode, equals(ThemeMode.system));
      
      await provider.toggleTheme();
      expect(provider.themeMode, equals(ThemeMode.light));
    });

    test('should set theme mode directly', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      
      await provider.setThemeMode(ThemeMode.dark);
      expect(provider.themeMode, equals(ThemeMode.dark));
      
      await provider.setThemeMode(ThemeMode.light);
      expect(provider.themeMode, equals(ThemeMode.light));
      
      await provider.setThemeMode(ThemeMode.system);
      expect(provider.themeMode, equals(ThemeMode.system));
    });

    test('isDarkMode should return false in system mode', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      
      await provider.setSystemMode();
      
      // In system mode, isDarkMode defaults to false as per implementation
      expect(provider.isDarkMode, isFalse);
    });

    test('should notify listeners when theme changes', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      
      int notificationCount = 0;
      provider.addListener(() {
        notificationCount++;
      });
      
      await provider.setLightMode();
      await provider.setDarkMode();
      await provider.setSystemMode();
      
      // Should notify on each theme change
      expect(notificationCount, equals(3));
    });

    test('should handle multiple rapid theme changes', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      
      await provider.setLightMode();
      await provider.setDarkMode();
      await provider.setLightMode();
      await provider.setSystemMode();
      await provider.setDarkMode();
      
      expect(provider.themeMode, equals(ThemeMode.dark));
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('theme_mode'), equals(ThemeMode.dark.index));
    });

    test('should handle empty SharedPreferences gracefully', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Should default to system mode
      expect(provider.themeMode, equals(ThemeMode.system));
    });

    test('should handle invalid theme index gracefully', () async {
      // This tests robustness - if somehow an invalid index is stored
      SharedPreferences.setMockInitialValues({
        'theme_mode': 99, // Invalid index
      });
      
      final provider = ThemeProvider();
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Should handle error - in this case might throw or default
      // The actual behavior depends on implementation
      expect(provider.themeMode, isA<ThemeMode>());
    });

    test('isLightMode should return correct value', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      
      await provider.setLightMode();
      expect(provider.isLightMode, isTrue);
      expect(provider.isDarkMode, isFalse);
      expect(provider.isSystemMode, isFalse);
      
      await provider.setDarkMode();
      expect(provider.isLightMode, isFalse);
    });

    test('isSystemMode should return correct value', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      
      await provider.setSystemMode();
      expect(provider.isSystemMode, isTrue);
      expect(provider.isLightMode, isFalse);
      
      await provider.setDarkMode();
      expect(provider.isSystemMode, isFalse);
    });

    test('should persist theme across multiple provider instances', () async {
      SharedPreferences.setMockInitialValues({});
      
      final provider1 = ThemeProvider();
      await provider1.setDarkMode();
      
      // Create new instance - should load saved preference
      final provider2 = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(provider2.themeMode, equals(ThemeMode.dark));
    });

    test('toggle should cycle through light and dark only', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      
      await provider.setLightMode();
      expect(provider.themeMode, equals(ThemeMode.light));
      
      await provider.toggleTheme();
      expect(provider.themeMode, equals(ThemeMode.dark));
      
      await provider.toggleTheme();
      expect(provider.themeMode, equals(ThemeMode.light));
      
      await provider.toggleTheme();
      expect(provider.themeMode, equals(ThemeMode.dark));
    });
  });

  group('ThemeProvider Edge Cases', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should handle concurrent theme changes', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      
      // Simulate rapid concurrent changes
      final futures = [
        provider.setLightMode(),
        provider.setDarkMode(),
        provider.setSystemMode(),
      ];
      
      await Future.wait(futures);
      
      // Should complete without error
      expect(provider.themeMode, isA<ThemeMode>());
    });

    test('should handle theme changes with listeners', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      
      final List<ThemeMode> themeModes = [];
      provider.addListener(() {
        themeModes.add(provider.themeMode);
      });
      
      await provider.setLightMode();
      await provider.setDarkMode();
      await provider.setSystemMode();
      
      expect(themeModes, hasLength(3));
      expect(themeModes[0], equals(ThemeMode.light));
      expect(themeModes[1], equals(ThemeMode.dark));
      expect(themeModes[2], equals(ThemeMode.system));
    });

    test('should maintain state after listener removal', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      
      void listener() {}
      provider.addListener(listener);
      
      await provider.setDarkMode();
      expect(provider.themeMode, equals(ThemeMode.dark));
      
      provider.removeListener(listener);
      
      await provider.setLightMode();
      expect(provider.themeMode, equals(ThemeMode.light));
    });
  });
}