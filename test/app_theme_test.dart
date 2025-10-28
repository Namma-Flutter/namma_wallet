import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/theme/app_theme.dart';

void main() {
  group('AppTheme Light Theme Tests', () {
    test('should provide valid light theme configuration', () {
      final lightTheme = AppTheme.lightTheme;
      
      expect(lightTheme, isNotNull);
      expect(lightTheme.brightness, equals(Brightness.light));
      expect(lightTheme.useMaterial3, isTrue);
    });

    test('light theme should have correct primary color', () {
      final lightTheme = AppTheme.lightTheme;
      
      expect(lightTheme.colorScheme.primary, equals(const Color(0xffE7FC57)));
      expect(lightTheme.colorScheme.onPrimary, equals(Colors.black));
    });

    test('light theme should have correct secondary color', () {
      final lightTheme = AppTheme.lightTheme;
      
      expect(lightTheme.colorScheme.secondary, equals(const Color(0xff4CAF50)));
      expect(lightTheme.colorScheme.onSecondary, equals(Colors.white));
    });

    test('light theme should have correct error color', () {
      final lightTheme = AppTheme.lightTheme;
      
      expect(lightTheme.colorScheme.error, equals(const Color(0xffF44336)));
    });

    test('light theme should have white scaffold background', () {
      final lightTheme = AppTheme.lightTheme;
      
      expect(lightTheme.scaffoldBackgroundColor, equals(Colors.white));
    });

    test('light theme AppBar should have correct styling', () {
      final lightTheme = AppTheme.lightTheme;
      final appBarTheme = lightTheme.appBarTheme;
      
      expect(appBarTheme.backgroundColor, equals(Colors.white));
      expect(appBarTheme.foregroundColor, equals(Colors.black));
      expect(appBarTheme.elevation, equals(0));
      expect(appBarTheme.centerTitle, isFalse);
      expect(appBarTheme.surfaceTintColor, equals(Colors.transparent));
    });

    test('light theme AppBar title should use Inter font', () {
      final lightTheme = AppTheme.lightTheme;
      final titleStyle = lightTheme.appBarTheme.titleTextStyle;
      
      expect(titleStyle, isNotNull);
      expect(titleStyle!.fontSize, equals(20));
      expect(titleStyle.fontWeight, equals(FontWeight.w600));
      expect(titleStyle.color, equals(Colors.black));
    });

    test('light theme cards should have rounded corners', () {
      final lightTheme = AppTheme.lightTheme;
      final cardTheme = lightTheme.cardTheme;
      
      expect(cardTheme.color, equals(Colors.white));
      expect(cardTheme.elevation, equals(2));
      expect(cardTheme.shape, isA<RoundedRectangleBorder>());
      
      final shape = cardTheme.shape as RoundedRectangleBorder;
      final borderRadius = shape.borderRadius as BorderRadius;
      expect(borderRadius.topLeft.x, equals(16));
    });

    test('light theme elevated buttons should have correct styling', () {
      final lightTheme = AppTheme.lightTheme;
      final buttonStyle = lightTheme.elevatedButtonTheme.style;
      
      expect(buttonStyle, isNotNull);
      
      final backgroundColor = buttonStyle!.backgroundColor?.resolve({});
      final foregroundColor = buttonStyle.foregroundColor?.resolve({});
      final elevation = buttonStyle.elevation?.resolve({});
      
      expect(backgroundColor, equals(const Color(0xffE7FC57)));
      expect(foregroundColor, equals(Colors.black));
      expect(elevation, equals(0));
    });

    test('light theme input fields should have correct styling', () {
      final lightTheme = AppTheme.lightTheme;
      final inputTheme = lightTheme.inputDecorationTheme;
      
      expect(inputTheme.filled, isTrue);
      expect(inputTheme.fillColor, isNotNull);
    });

    test('light theme input focus border should use primary color', () {
      final lightTheme = AppTheme.lightTheme;
      final focusedBorder = lightTheme.inputDecorationTheme.focusedBorder;
      
      expect(focusedBorder, isA<OutlineInputBorder>());
      final border = focusedBorder as OutlineInputBorder;
      expect(border.borderSide.color, equals(const Color(0xffE7FC57)));
      expect(border.borderSide.width, equals(2));
    });

    test('light theme bottom navigation should have correct colors', () {
      final lightTheme = AppTheme.lightTheme;
      final bottomNavTheme = lightTheme.bottomNavigationBarTheme;
      
      expect(bottomNavTheme.backgroundColor, equals(Colors.white));
      expect(bottomNavTheme.selectedItemColor, equals(Colors.white));
      expect(bottomNavTheme.unselectedItemColor, equals(Colors.grey));
      expect(bottomNavTheme.elevation, equals(8));
      expect(bottomNavTheme.type, equals(BottomNavigationBarType.fixed));
    });

    test('light theme dialog should have rounded corners', () {
      final lightTheme = AppTheme.lightTheme;
      final dialogTheme = lightTheme.dialogTheme;
      
      expect(dialogTheme.backgroundColor, equals(Colors.white));
      expect(dialogTheme.shape, isA<RoundedRectangleBorder>());
      
      final shape = dialogTheme.shape as RoundedRectangleBorder;
      final borderRadius = shape.borderRadius as BorderRadius;
      expect(borderRadius.topLeft.x, equals(16));
    });

    test('light theme FAB should use primary color', () {
      final lightTheme = AppTheme.lightTheme;
      final fabTheme = lightTheme.floatingActionButtonTheme;
      
      expect(fabTheme.backgroundColor, equals(const Color(0xffE7FC57)));
      expect(fabTheme.foregroundColor, equals(Colors.black));
    });

    test('light theme progress indicator should use primary color', () {
      final lightTheme = AppTheme.lightTheme;
      
      expect(lightTheme.progressIndicatorTheme.color, 
             equals(const Color(0xffE7FC57)));
    });

    test('light theme divider should have correct styling', () {
      final lightTheme = AppTheme.lightTheme;
      final dividerTheme = lightTheme.dividerTheme;
      
      expect(dividerTheme.color, isNotNull);
      expect(dividerTheme.thickness, equals(1));
    });
  });

  group('AppTheme Dark Theme Tests', () {
    test('should provide valid dark theme configuration', () {
      final darkTheme = AppTheme.darkTheme;
      
      expect(darkTheme, isNotNull);
      expect(darkTheme.brightness, equals(Brightness.dark));
      expect(darkTheme.useMaterial3, isTrue);
    });

    test('dark theme should have correct primary color', () {
      final darkTheme = AppTheme.darkTheme;
      
      expect(darkTheme.colorScheme.primary, equals(const Color(0xffE0FB25)));
      expect(darkTheme.colorScheme.onPrimary, equals(Colors.black));
    });

    test('dark theme should have correct secondary color', () {
      final darkTheme = AppTheme.darkTheme;
      
      expect(darkTheme.colorScheme.secondary, equals(const Color(0xff66BB6A)));
    });

    test('dark theme should have correct background colors', () {
      final darkTheme = AppTheme.darkTheme;
      
      expect(darkTheme.scaffoldBackgroundColor, equals(const Color(0xff121212)));
      expect(darkTheme.colorScheme.surface, equals(const Color(0xff1E1E1E)));
    });

    test('dark theme should have correct error color', () {
      final darkTheme = AppTheme.darkTheme;
      
      expect(darkTheme.colorScheme.error, equals(const Color(0xffEF5350)));
    });

    test('dark theme AppBar should have correct styling', () {
      final darkTheme = AppTheme.darkTheme;
      final appBarTheme = darkTheme.appBarTheme;
      
      expect(appBarTheme.backgroundColor, equals(const Color(0xff1E1E1E)));
      expect(appBarTheme.foregroundColor, equals(Colors.white));
      expect(appBarTheme.elevation, equals(0));
      expect(appBarTheme.centerTitle, isFalse);
    });

    test('dark theme cards should have dark surface color', () {
      final darkTheme = AppTheme.darkTheme;
      final cardTheme = darkTheme.cardTheme;
      
      expect(cardTheme.color, equals(const Color(0xff1E1E1E)));
      expect(cardTheme.elevation, equals(4));
    });

    test('dark theme elevated buttons should have correct styling', () {
      final darkTheme = AppTheme.darkTheme;
      final buttonStyle = darkTheme.elevatedButtonTheme.style;
      
      final backgroundColor = buttonStyle!.backgroundColor?.resolve({});
      final foregroundColor = buttonStyle.foregroundColor?.resolve({});
      
      expect(backgroundColor, equals(const Color(0xffE0FB25)));
      expect(foregroundColor, equals(Colors.black));
    });

    test('dark theme input fields should have dark fill color', () {
      final darkTheme = AppTheme.darkTheme;
      final inputTheme = darkTheme.inputDecorationTheme;
      
      expect(inputTheme.filled, isTrue);
      expect(inputTheme.fillColor, isNotNull);
    });

    test('dark theme bottom navigation should have dark colors', () {
      final darkTheme = AppTheme.darkTheme;
      final bottomNavTheme = darkTheme.bottomNavigationBarTheme;
      
      expect(bottomNavTheme.backgroundColor, equals(const Color(0xff1E1E1E)));
      expect(bottomNavTheme.selectedItemColor, equals(Colors.white));
    });

    test('dark theme FAB should use primary color', () {
      final darkTheme = AppTheme.darkTheme;
      final fabTheme = darkTheme.floatingActionButtonTheme;
      
      expect(fabTheme.backgroundColor, equals(const Color(0xffE0FB25)));
      expect(fabTheme.foregroundColor, equals(Colors.black));
    });
  });

  group('AppTheme Helper Methods', () {
    testWidgets('getTextColor should return black for light theme', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              final textColor = AppTheme.getTextColor(context);
              expect(textColor, equals(Colors.black));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('getTextColor should return white for dark theme', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              final textColor = AppTheme.getTextColor(context);
              expect(textColor, equals(Colors.white));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('getSurfaceColor should return white for light theme', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              final surfaceColor = AppTheme.getSurfaceColor(context);
              expect(surfaceColor, equals(Colors.white));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('getSurfaceColor should return dark surface for dark theme', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              final surfaceColor = AppTheme.getSurfaceColor(context);
              expect(surfaceColor, equals(const Color(0xff1E1E1E)));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('getPrimaryColor should return light primary for light theme', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              final primaryColor = AppTheme.getPrimaryColor(context);
              expect(primaryColor, equals(const Color(0xffE7FC57)));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('getPrimaryColor should return dark primary for dark theme', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              final primaryColor = AppTheme.getPrimaryColor(context);
              expect(primaryColor, equals(const Color(0xffE0FB25)));
              return Container();
            },
          ),
        ),
      );
    });
  });

  group('AppTheme Consistency Tests', () {
    test('light and dark themes should both use Material3', () {
      expect(AppTheme.lightTheme.useMaterial3, isTrue);
      expect(AppTheme.darkTheme.useMaterial3, isTrue);
    });

    test('both themes should have zero AppBar elevation', () {
      expect(AppTheme.lightTheme.appBarTheme.elevation, equals(0));
      expect(AppTheme.darkTheme.appBarTheme.elevation, equals(0));
    });

    test('both themes should have same border radius for cards', () {
      final lightCardShape = AppTheme.lightTheme.cardTheme.shape 
          as RoundedRectangleBorder;
      final darkCardShape = AppTheme.darkTheme.cardTheme.shape 
          as RoundedRectangleBorder;
      
      final lightRadius = lightCardShape.borderRadius as BorderRadius;
      final darkRadius = darkCardShape.borderRadius as BorderRadius;
      
      expect(lightRadius.topLeft.x, equals(darkRadius.topLeft.x));
    });

    test('both themes should have same input decoration border radius', () {
      final lightFocusBorder = 
          AppTheme.lightTheme.inputDecorationTheme.focusedBorder 
              as OutlineInputBorder;
      final darkFocusBorder = 
          AppTheme.darkTheme.inputDecorationTheme.focusedBorder 
              as OutlineInputBorder;
      
      final lightRadius = lightFocusBorder.borderRadius as BorderRadius;
      final darkRadius = darkFocusBorder.borderRadius as BorderRadius;
      
      expect(lightRadius.topLeft.x, equals(darkRadius.topLeft.x));
    });

    test('both themes should have same dialog border radius', () {
      final lightDialogShape = AppTheme.lightTheme.dialogTheme.shape 
          as RoundedRectangleBorder;
      final darkDialogShape = AppTheme.darkTheme.dialogTheme.shape 
          as RoundedRectangleBorder;
      
      final lightRadius = lightDialogShape.borderRadius as BorderRadius;
      final darkRadius = darkDialogShape.borderRadius as BorderRadius;
      
      expect(lightRadius.topLeft.x, equals(darkRadius.topLeft.x));
    });

    test('both themes should have same button text style', () {
      final lightButtonStyle = AppTheme.lightTheme.elevatedButtonTheme.style;
      final darkButtonStyle = AppTheme.darkTheme.elevatedButtonTheme.style;
      
      final lightTextStyle = lightButtonStyle!.textStyle?.resolve({});
      final darkTextStyle = darkButtonStyle!.textStyle?.resolve({});
      
      expect(lightTextStyle?.fontSize, equals(darkTextStyle?.fontSize));
      expect(lightTextStyle?.fontWeight, equals(darkTextStyle?.fontWeight));
    });

    test('both themes should have onPrimary as black', () {
      expect(AppTheme.lightTheme.colorScheme.onPrimary, equals(Colors.black));
      expect(AppTheme.darkTheme.colorScheme.onPrimary, equals(Colors.black));
    });

    test('both themes should have fixed bottom navigation type', () {
      expect(AppTheme.lightTheme.bottomNavigationBarTheme.type, 
             equals(BottomNavigationBarType.fixed));
      expect(AppTheme.darkTheme.bottomNavigationBarTheme.type, 
             equals(BottomNavigationBarType.fixed));
    });

    test('both themes should have divider thickness of 1', () {
      expect(AppTheme.lightTheme.dividerTheme.thickness, equals(1));
      expect(AppTheme.darkTheme.dividerTheme.thickness, equals(1));
    });
  });

  group('AppTheme Edge Cases', () {
    test('themes should not be null', () {
      expect(AppTheme.lightTheme, isNotNull);
      expect(AppTheme.darkTheme, isNotNull);
    });

    test('color schemes should not be null', () {
      expect(AppTheme.lightTheme.colorScheme, isNotNull);
      expect(AppTheme.darkTheme.colorScheme, isNotNull);
    });

    test('text themes should use Inter font family', () {
      final lightTextTheme = AppTheme.lightTheme.textTheme;
      final darkTextTheme = AppTheme.darkTheme.textTheme;
      
      expect(lightTextTheme.bodyLarge?.fontFamily, contains('Inter'));
      expect(darkTextTheme.bodyLarge?.fontFamily, contains('Inter'));
    });

    test('snackbar should have floating behavior', () {
      expect(AppTheme.lightTheme.snackBarTheme.behavior, 
             equals(SnackBarBehavior.floating));
      expect(AppTheme.darkTheme.snackBarTheme.behavior, 
             equals(SnackBarBehavior.floating));
    });

    test('AppBar should not be centered', () {
      expect(AppTheme.lightTheme.appBarTheme.centerTitle, isFalse);
      expect(AppTheme.darkTheme.appBarTheme.centerTitle, isFalse);
    });

    test('elevated buttons should have zero elevation', () {
      final lightElevation = AppTheme.lightTheme.elevatedButtonTheme.style!
          .elevation?.resolve({});
      final darkElevation = AppTheme.darkTheme.elevatedButtonTheme.style!
          .elevation?.resolve({});
      
      expect(lightElevation, equals(0));
      expect(darkElevation, equals(0));
    });
  });
}