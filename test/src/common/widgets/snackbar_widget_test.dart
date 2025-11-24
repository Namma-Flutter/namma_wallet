import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/common/widgets/snackbar_widget.dart';

import '../../../helpers/fake_logger.dart';

void main() {
  group('CustomSnackBar', () {
    testWidgets('creates success snackbar with correct styling', (
      tester,
    ) async {
      const message = 'Operation successful';
      final snackBar = CustomSnackBar(
        message: message,
        isError: false,
      );

      expect(snackBar.content, isA<Row>());
      expect(snackBar.backgroundColor, const Color(0xff4CAF50)); // Green
      expect(snackBar.behavior, SnackBarBehavior.floating);
      expect(snackBar.dismissDirection, DismissDirection.up);
    });

    testWidgets('creates error snackbar with correct styling', (tester) async {
      const message = 'Operation failed';
      final snackBar = CustomSnackBar(
        message: message,
        isError: true,
      );

      expect(snackBar.content, isA<Row>());
      expect(snackBar.backgroundColor, const Color(0xffF44336)); // Red
      expect(snackBar.behavior, SnackBarBehavior.floating);
      expect(snackBar.dismissDirection, DismissDirection.up);
    });

    testWidgets('uses correct icon for success message', (tester) async {
      const message = 'Success message';
      final snackBar = CustomSnackBar(
        message: message,
        isError: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      // Find the success icon
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Icon && widget.icon == Icons.check_circle_outline,
        ),
        findsOneWidget,
      );
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('uses correct icon for error message', (tester) async {
      const message = 'Error message';
      final snackBar = CustomSnackBar(
        message: message,
        isError: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      // Find the error icon
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.error_outline,
        ),
        findsOneWidget,
      );
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('displays message text correctly', (tester) async {
      const message = 'This is a test message';
      final snackBar = CustomSnackBar(
        message: message,
        isError: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text(message), findsOneWidget);
    });

    testWidgets('uses custom duration when provided', (tester) async {
      const customDuration = Duration(seconds: 5);
      final snackBar = CustomSnackBar(
        message: 'Test',
        isError: false,
        duration: customDuration,
      );

      expect(snackBar.duration, customDuration);
    });

    testWidgets('uses default duration for success (2 seconds)', (
      tester,
    ) async {
      final snackBar = CustomSnackBar(
        message: 'Test',
        isError: false,
      );

      expect(snackBar.duration, const Duration(seconds: 2));
    });

    testWidgets('uses default duration for error (3 seconds)', (tester) async {
      final snackBar = CustomSnackBar(
        message: 'Test',
        isError: true,
      );

      expect(snackBar.duration, const Duration(seconds: 3));
    });

    testWidgets('has correct margin for positioning above nav bar', (
      tester,
    ) async {
      final snackBar = CustomSnackBar(
        message: 'Test',
        isError: false,
      );

      expect(
        snackBar.margin,
        const EdgeInsets.only(
          top: 50,
          left: 16,
          right: 16,
          bottom: 100,
        ),
      );
    });

    testWidgets('has rounded corners', (tester) async {
      final snackBar = CustomSnackBar(
        message: 'Test',
        isError: false,
      );

      expect(
        snackBar.shape,
        isA<RoundedRectangleBorder>().having(
          (shape) => shape.borderRadius,
          'borderRadius',
          BorderRadius.circular(12),
        ),
      );
    });

    testWidgets('icon has correct size and color', (tester) async {
      const message = 'Test message';
      final snackBar = CustomSnackBar(
        message: message,
        isError: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      final iconWidget = tester.widget<Icon>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Icon && widget.icon == Icons.check_circle_outline,
        ),
      );

      expect(iconWidget.size, 24);
      expect(iconWidget.color, Colors.white);
    });

    testWidgets('message text has correct styling', (tester) async {
      const message = 'Test message';
      final snackBar = CustomSnackBar(
        message: message,
        isError: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      final textWidget = tester.widget<Text>(find.text(message));
      expect(textWidget.style?.color, Colors.white);
      expect(textWidget.style?.fontSize, 14);
      expect(textWidget.style?.fontWeight, FontWeight.w500);
    });
  });

  group('showSnackbar', () {
    final getIt = GetIt.instance;

    setUp(() {
      // Register logger dependency if not already registered
      if (!getIt.isRegistered<ILogger>()) {
        getIt.registerSingleton<ILogger>(FakeLogger());
      }
    });

    tearDown(() async {
      await getIt.reset();
    });

    testWidgets('displays success snackbar', (tester) async {
      const message = 'Success message';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showSnackbar(context, message);
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text(message), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Icon && widget.icon == Icons.check_circle_outline,
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays error snackbar', (tester) async {
      const message = 'Error message';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showSnackbar(context, message, isError: true);
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text(message), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.error_outline,
        ),
        findsOneWidget,
      );
    });

    testWidgets('uses custom duration when provided', (tester) async {
      const message = 'Test message';
      const customDuration = Duration(seconds: 10);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showSnackbar(
                      context,
                      message,
                      duration: customDuration,
                    );
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text(message), findsOneWidget);
    });

    testWidgets('handles long messages correctly', (tester) async {
      const longMessage =
          'This is a very long message that should be '
          'displayed correctly in the snackbar without any issues. '
          'It should wrap properly and remain readable.';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showSnackbar(context, longMessage);
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text(longMessage), findsOneWidget);
    });

    testWidgets('snackbar appears above navigation bar position', (
      tester,
    ) async {
      const message = 'Test message';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showSnackbar(context, message);
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      // Verify the snackbar is displayed
      expect(find.text(message), findsOneWidget);

      // Find the SnackBar widget and verify its margin
      final snackBarWidget = tester.widget<SnackBar>(
        find.byType(SnackBar),
      );

      expect(
        snackBarWidget.margin,
        const EdgeInsets.only(
          top: 50,
          left: 16,
          right: 16,
          bottom: 100, // Above navigation bar
        ),
      );
    });

    testWidgets('can dismiss snackbar by swiping up', (tester) async {
      const message = 'Test message';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showSnackbar(context, message);
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text(message), findsOneWidget);

      // Verify dismiss direction is up
      final snackBarWidget = tester.widget<SnackBar>(
        find.byType(SnackBar),
      );
      expect(snackBarWidget.dismissDirection, DismissDirection.up);
    });

    testWidgets('multiple snack bars can be queued', (tester) async {
      const message1 = 'First message';
      const message2 = 'Second message';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        showSnackbar(context, message1);
                      },
                      child: const Text('Show 1'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showSnackbar(context, message2);
                      },
                      child: const Text('Show 2'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show 1'));
      await tester.pump();

      expect(find.text(message1), findsOneWidget);

      // Show second snackbar - it should work without errors
      await tester.tap(find.text('Show 2'));
      await tester.pump();

      // Verify no errors occurred (both snack bars can be shown)
      expect(tester.takeException(), isNull);
    });
  });

  group('Snackbar Edge Cases', () {
    final getIt = GetIt.instance;

    setUp(() {
      // Register logger dependency if not already registered
      if (!getIt.isRegistered<ILogger>()) {
        getIt.registerSingleton<ILogger>(FakeLogger());
      }
    });

    tearDown(() async {
      await getIt.reset();
    });

    testWidgets('handles empty message', (tester) async {
      const message = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showSnackbar(context, message);
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      // Should still display the snackbar with empty text
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('handles special characters in message', (tester) async {
      const message = 'Error: special characters & symbols!';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showSnackbar(context, message, isError: true);
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text(message), findsOneWidget);
    });

    testWidgets('handles unicode characters in message', (tester) async {
      const message = 'Success! ✓ Ticket saved 🎫';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showSnackbar(context, message);
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text(message), findsOneWidget);
    });

    testWidgets('snackbar is floating behavior', (tester) async {
      const message = 'Test';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showSnackbar(context, message);
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      final snackBarWidget = tester.widget<SnackBar>(
        find.byType(SnackBar),
      );
      expect(snackBarWidget.behavior, SnackBarBehavior.floating);
    });
  });
}
