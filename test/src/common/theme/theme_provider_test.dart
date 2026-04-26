import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeProvider defaults', () {
    test('starts in system mode with the matching getters', () {
      final provider = ThemeProvider();

      expect(provider.themeMode, ThemeMode.system);
      expect(provider.isSystemMode, isTrue);
      expect(provider.isLightMode, isFalse);
      expect(provider.isDarkMode, isFalse);
    });
  });

  group('ThemeProvider mode setters', () {
    test('setLightMode flips to light and notifies', () async {
      final provider = ThemeProvider();
      var notified = 0;
      provider.addListener(() => notified++);

      await provider.setLightMode();

      expect(provider.themeMode, ThemeMode.light);
      expect(provider.isLightMode, isTrue);
      expect(provider.isDarkMode, isFalse);
      expect(notified, greaterThanOrEqualTo(1));
    });

    test('setDarkMode flips to dark', () async {
      final provider = ThemeProvider();

      await provider.setDarkMode();

      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.isDarkMode, isTrue);
      expect(provider.isLightMode, isFalse);
    });

    test('setSystemMode flips to system', () async {
      final provider = ThemeProvider();
      await provider.setLightMode();

      await provider.setSystemMode();

      expect(provider.themeMode, ThemeMode.system);
      expect(provider.isSystemMode, isTrue);
    });

    test('setThemeMode accepts any ThemeMode', () async {
      final provider = ThemeProvider();

      await provider.setThemeMode(ThemeMode.dark);
      expect(provider.themeMode, ThemeMode.dark);

      await provider.setThemeMode(ThemeMode.light);
      expect(provider.themeMode, ThemeMode.light);
    });

    test('toggleTheme: light → dark', () async {
      final provider = ThemeProvider();
      await provider.setLightMode();

      await provider.toggleTheme();

      expect(provider.themeMode, ThemeMode.dark);
    });

    test('toggleTheme: dark → light', () async {
      final provider = ThemeProvider();
      await provider.setDarkMode();

      await provider.toggleTheme();

      expect(provider.themeMode, ThemeMode.light);
    });

    test(
      'toggleTheme: system → light (anything not light goes to light)',
      () async {
        final provider = ThemeProvider();

        await provider.toggleTheme();

        expect(provider.themeMode, ThemeMode.light);
      },
    );
  });

  group('ThemeProvider persistence', () {
    test('persists the chosen mode across instances', () async {
      final first = ThemeProvider();
      await first.setDarkMode();

      final second = ThemeProvider();
      // Allow the async _loadThemePreference to run.
      await Future<void>.delayed(Duration.zero);

      expect(second.themeMode, ThemeMode.dark);
    });

    test('falls back to default when stored index is out of range', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 99});

      final provider = ThemeProvider();
      await Future<void>.delayed(Duration.zero);

      expect(provider.themeMode, ThemeMode.system);
    });
  });
}
