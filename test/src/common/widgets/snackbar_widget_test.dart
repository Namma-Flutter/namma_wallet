import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/widgets/snackbar_widget.dart';

import '../../../helpers/fake_logger.dart';

void main() {
  group('CustomSnackBar', () {
    testWidgets('creates success snackbar with correct styling', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                const message = 'Operation successful';
                final snackBar = CustomSnackBar(
                  message: message,
                  isError: false,
                  context: context,
                );

                expect(snackBar.content, isA<Row>());
                expect(
                  snackBar.backgroundColor,
                  Theme.of(context).colorScheme.secondary,
                );
                expect(snackBar.behavior, SnackBarBehavior.floating);
                expect(snackBar.dismissDirection, DismissDirection.up);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('creates error snackbar with correct styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                const message = 'Operation failed';
                final snackBar = CustomSnackBar(
                  message: message,
                  isError: true,
                  context: context,
                );

                expect(snackBar.content, isA<Row>());
                expect(
                  snackBar.backgroundColor,
                  Theme.of(context).colorScheme.error,
                );
                expect(snackBar.behavior, SnackBarBehavior.floating);
                expect(snackBar.dismissDirection, DismissDirection.up);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('uses correct icon for success message', (tester) async {
      const message = 'Success message';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final snackBar = CustomSnackBar(
                  message: message,
                  isError: false,
                  context: context,
                );
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
      await tester.pumpAndSettle();

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

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final snackBar = CustomSnackBar(
                  message: message,
                  isError: true,
                  context: context,
                );
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
      await tester.pumpAndSettle();

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

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final snackBar = CustomSnackBar(
                  message: message,
                  isError: false,
                  context: context,
                );
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
      await tester.pumpAndSettle();

      expect(find.text(message), findsOneWidget);
    });

    testWidgets('uses custom duration when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                const customDuration = Duration(seconds: 5);
                final snackBar = CustomSnackBar(
                  message: 'Test',
                  isError: false,
                  context: context,
                  duration: customDuration,
                );

                expect(snackBar.duration, customDuration);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('uses default duration for success (2 seconds)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final snackBar = CustomSnackBar(
                  message: 'Test',
                  isError: false,
                  context: context,
                );

                expect(snackBar.duration, const Duration(seconds: 2));
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('uses default duration for error (3 seconds)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final snackBar = CustomSnackBar(
                  message: 'Test',
                  isError: true,
                  context: context,
                );

                expect(snackBar.duration, const Duration(seconds: 3));
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('has responsive margin above bottom navigation', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final snackBar = CustomSnackBar(
                  message: 'Test',
                  isError: false,
                  context: context,
                );

                final expectedMargin = EdgeInsets.only(
                  bottom:
                      MediaQuery.of(context).padding.bottom +
                      MediaQuery.of(context).viewInsets.bottom +
                      80 +
                      16,
                  left: 16,
                  right: 16,
                );

                expect(snackBar.margin, expectedMargin);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('has rounded corners', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final snackBar = CustomSnackBar(
                  message: 'Test',
                  isError: false,
                  context: context,
                );

                expect(
                  snackBar.shape,
                  isA<RoundedRectangleBorder>().having(
                    (shape) => shape.borderRadius,
                    'borderRadius',
                    BorderRadius.circular(12),
                  ),
                );
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('icon has correct size and color', (tester) async {
      const message = 'Test message';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final snackBar = CustomSnackBar(
                  message: message,
                  isError: false,
                  context: context,
                );
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
      await tester.pumpAndSettle();

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

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final snackBar = CustomSnackBar(
                  message: message,
                  isError: false,
                  context: context,
                );
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
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

      // Verify the snackbar is displayed
      expect(find.text(message), findsOneWidget);

      // Find the SnackBar widget and verify its margin
      final snackBarWidget = tester.widget<SnackBar>(
        find.byType(SnackBar),
      );

      // Verify the margin uses responsive positioning above bottom nav
      final context = tester.element(find.byType(Scaffold));
      final expectedMargin = EdgeInsets.only(
        bottom:
            MediaQuery.of(context).padding.bottom +
            MediaQuery.of(context).viewInsets.bottom +
            80 +
            16,
        left: 16,
        right: 16,
      );
      expect(snackBarWidget.margin, expectedMargin);
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
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

      expect(find.text(message1), findsOneWidget);

      // Show second snackbar - it should work without errors
      await tester.tap(find.text('Show 2'));
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

      final snackBarWidget = tester.widget<SnackBar>(
        find.byType(SnackBar),
      );
      expect(snackBarWidget.behavior, SnackBarBehavior.floating);
    });
  });
}
