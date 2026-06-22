import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/import/presentation/widgets/import_method_card_widget.dart';

void main() {
  // Helper to wrap widget in a MaterialApp with a fixed-size Scaffold
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 200,
          height: 200,
          child: child,
        ),
      ),
    );
  }

  group('ImportMethodCardWidget – Rendering', () {
    testWidgets(
      'Given required props, When rendered, Then shows icon and title',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        // Act
        await tester.pumpWidget(
          buildTestWidget(
            const ImportMethodCardWidget(
              icon: Icons.picture_as_pdf,
              title: 'PDF File',
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
        expect(find.text('PDF File'), findsOneWidget);
      },
    );

    testWidgets(
      'Given subtitle provided, When rendered, Then shows subtitle text',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        // Act
        await tester.pumpWidget(
          buildTestWidget(
            const ImportMethodCardWidget(
              icon: Icons.picture_as_pdf,
              title: 'PDF File',
              subtitle: 'Import from PDF',
            ),
          ),
        );

        // Assert
        expect(find.text('Import from PDF'), findsOneWidget);
      },
    );

    testWidgets(
      'Given no subtitle, When rendered, Then subtitle text is absent',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        // Act
        await tester.pumpWidget(
          buildTestWidget(
            const ImportMethodCardWidget(
              icon: Icons.camera_alt,
              title: 'Camera',
            ),
          ),
        );

        // Assert — no stray subtitle text should appear
        expect(find.text('Camera'), findsOneWidget);
        expect(find.text('Import from PDF'), findsNothing);
      },
    );

    testWidgets(
      'Given isLoading is false (default), When rendered, '
      'Then CircularProgressIndicator is absent',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        // Act
        await tester.pumpWidget(
          buildTestWidget(
            const ImportMethodCardWidget(
              icon: Icons.upload_file,
              title: 'Upload',
            ),
          ),
        );

        // Assert
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets(
      'Given isLoading is true, When rendered, '
      'Then CircularProgressIndicator is visible',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        // Act
        await tester.pumpWidget(
          buildTestWidget(
            const ImportMethodCardWidget(
              icon: Icons.upload_file,
              title: 'Upload',
              isLoading: true,
            ),
          ),
        );

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'Given isLoading is true, When rendered, '
      'Then icon and title still appear behind loading overlay',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        // Act
        await tester.pumpWidget(
          buildTestWidget(
            const ImportMethodCardWidget(
              icon: Icons.upload_file,
              title: 'Upload',
              isLoading: true,
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.upload_file), findsOneWidget);
        expect(find.text('Upload'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );
  });

  group('ImportMethodCardWidget – Icon Color', () {
    testWidgets(
      'Given no backgroundColor, When rendered, '
      'Then icon color is NOT white (uses theme primary)',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            ),
            home: const Scaffold(
              body: SizedBox(
                width: 200,
                height: 200,
                child: ImportMethodCardWidget(
                  key: Key('card_no_bg'),
                  icon: Icons.camera_alt,
                  title: 'Camera',
                ),
              ),
            ),
          ),
        );

        // Act
        final iconWidget = tester.widget<Icon>(find.byIcon(Icons.camera_alt));

        // Assert — white is reserved for custom background cards
        expect(iconWidget.color, isNot(equals(Colors.white)));
      },
    );

    testWidgets(
      'Given backgroundColor provided, When rendered, '
      'Then icon color is white',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          buildTestWidget(
            const ImportMethodCardWidget(
              key: Key('card_with_bg'),
              icon: Icons.qr_code_scanner,
              title: 'QR Scan',
              backgroundColor: Colors.deepPurple,
            ),
          ),
        );

        // Act
        final iconWidget = tester.widget<Icon>(
          find.byIcon(Icons.qr_code_scanner),
        );

        // Assert
        expect(iconWidget.color, equals(Colors.white));
      },
    );

    testWidgets(
      'Given isLoading true and backgroundColor provided, When rendered, '
      'Then spinner color is white',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          buildTestWidget(
            const ImportMethodCardWidget(
              icon: Icons.qr_code_scanner,
              title: 'QR Scan',
              isLoading: true,
              backgroundColor: Colors.teal,
            ),
          ),
        );

        // Act
        final spinner = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );

        // Assert
        expect(spinner.color, equals(Colors.white));
      },
    );

    testWidgets(
      'Given isLoading true and no backgroundColor, When rendered, '
      'Then spinner color is NOT white (uses theme primary)',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            ),
            home: const Scaffold(
              body: SizedBox(
                width: 200,
                height: 200,
                child: ImportMethodCardWidget(
                  icon: Icons.upload_file,
                  title: 'Upload',
                  isLoading: true,
                ),
              ),
            ),
          ),
        );

        // Act
        final spinner = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );

        // Assert
        expect(spinner.color, isNot(equals(Colors.white)));
      },
    );
  });

  group('ImportMethodCardWidget – Tap Behaviour', () {
    testWidgets(
      'Given onTap provided and isLoading false, When tapped, '
      'Then callback is invoked',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        var tapped = false;

        await tester.pumpWidget(
          buildTestWidget(
            ImportMethodCardWidget(
              key: const Key('tappable_card'),
              icon: Icons.upload_file,
              title: 'Upload',
              onTap: () => tapped = true,
            ),
          ),
        );

        // Act
        await tester.tap(find.byKey(const Key('tappable_card')));
        await tester.pumpAndSettle();

        // Assert
        expect(tapped, isTrue);
      },
    );

    testWidgets(
      'Given isLoading is true, When tapped, Then callback is NOT invoked',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        var tapped = false;

        await tester.pumpWidget(
          buildTestWidget(
            ImportMethodCardWidget(
              key: const Key('loading_card'),
              icon: Icons.upload_file,
              title: 'Upload',
              isLoading: true,
              onTap: () => tapped = true,
            ),
          ),
        );

        // Act — use pump() not pumpAndSettle(); a disabled InkWell never
        // produces animations that settle, causing pumpAndSettle to timeout.
        await tester.tap(find.byKey(const Key('loading_card')));
        await tester.pump();

        // Assert — callback must not fire during loading
        expect(tapped, isFalse);
      },
    );

    testWidgets(
      'Given onTap is null, When tapped, Then no exception is thrown',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          buildTestWidget(
            const ImportMethodCardWidget(
              key: Key('no_tap_card'),
              icon: Icons.upload_file,
              title: 'Upload',
            ),
          ),
        );

        // Act & Assert
        await tester.tap(find.byKey(const Key('no_tap_card')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('ImportMethodCardWidget – Visual Structure', () {
    testWidgets(
      'Given widget rendered, When inspected, '
      'Then Material and InkWell are present',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          buildTestWidget(
            const ImportMethodCardWidget(
              icon: Icons.picture_as_pdf,
              title: 'PDF',
            ),
          ),
        );

        // Assert
        expect(find.byType(Material), findsWidgets);
        expect(find.byType(InkWell), findsOneWidget);
      },
    );

    testWidgets(
      'Given widget rendered, When inspected, '
      'Then Stack is used for overlay support',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          buildTestWidget(
            const ImportMethodCardWidget(
              icon: Icons.picture_as_pdf,
              title: 'PDF',
            ),
          ),
        );

        // Assert — findsWidgets because Scaffold itself also contains a Stack
        expect(find.byType(Stack), findsWidgets);
      },
    );

    testWidgets(
      'Given widget rendered, When inspected, Then icon size is 52',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          buildTestWidget(
            const ImportMethodCardWidget(
              icon: Icons.camera_alt,
              title: 'Camera',
            ),
          ),
        );

        // Act
        final iconWidget = tester.widget<Icon>(find.byIcon(Icons.camera_alt));

        // Assert
        expect(iconWidget.size, equals(52));
      },
    );

    testWidgets(
      'Given isLoading true, When rendered, '
      'Then Positioned.fill overlay widget is present',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          buildTestWidget(
            const ImportMethodCardWidget(
              icon: Icons.upload_file,
              title: 'Upload',
              isLoading: true,
            ),
          ),
        );

        // Assert — Positioned.fill produces a Positioned widget in the tree
        expect(find.byType(Positioned), findsOneWidget);
      },
    );

    testWidgets(
      'Given isLoading false, When rendered, '
      'Then no Positioned overlay widget exists',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          buildTestWidget(
            const ImportMethodCardWidget(
              icon: Icons.upload_file,
              title: 'Upload',
            ),
          ),
        );

        // Assert
        expect(find.byType(Positioned), findsNothing);
      },
    );
  });

  group('ImportMethodCardWidget – backgroundColor', () {
    testWidgets(
      'Given custom backgroundColor, When rendered, '
      'Then Material widget uses that color',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        const customColor = Colors.orange;

        await tester.pumpWidget(
          buildTestWidget(
            const ImportMethodCardWidget(
              icon: Icons.photo,
              title: 'Photo',
              backgroundColor: customColor,
            ),
          ),
        );

        // Act — find the Material whose color matches our custom color
        // (can't use .first because Scaffold has its own Material in the tree).
        final material = tester.widget<Material>(
          find.byWidgetPredicate(
            (widget) => widget is Material && widget.color == customColor,
          ),
        );

        // Assert
        expect(material.color, equals(customColor));
      },
    );

    testWidgets(
      'Given no backgroundColor, When rendered, '
      'Then Material widget uses theme surface color',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final theme = ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: const Scaffold(
              body: SizedBox(
                width: 200,
                height: 200,
                child: ImportMethodCardWidget(
                  icon: Icons.photo,
                  title: 'Photo',
                ),
              ),
            ),
          ),
        );

        // Act
        final material = tester.widget<Material>(
          find.byType(Material).first,
        );

        // Assert
        expect(material.color, equals(theme.colorScheme.surface));
      },
    );
  });

  group('ImportMethodCardWidget – Edge Cases', () {
    testWidgets(
      'Given a very long title, When rendered, Then widget does not overflow',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          buildTestWidget(
            const ImportMethodCardWidget(
              icon: Icons.upload_file,
              title:
                  'This is a very very very very very long import method title',
            ),
          ),
        );

        // Assert
        expect(tester.takeException(), isNull);
        expect(find.byType(ImportMethodCardWidget), findsOneWidget);
      },
    );

    testWidgets(
      'Given a very long subtitle, When rendered, '
      'Then widget does not overflow',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          buildTestWidget(
            const ImportMethodCardWidget(
              icon: Icons.upload_file,
              title: 'Upload',
              subtitle:
                  'This is an extremely long subtitle that '
                  'should be ellipsized '
                  'and not cause any layout overflow',
            ),
          ),
        );

        // Assert
        expect(tester.takeException(), isNull);
        expect(find.byType(ImportMethodCardWidget), findsOneWidget);
      },
    );

    testWidgets(
      'Given an empty string title, When rendered, '
      'Then widget builds without error',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          buildTestWidget(
            const ImportMethodCardWidget(
              icon: Icons.upload_file,
              title: '',
            ),
          ),
        );

        // Assert
        expect(tester.takeException(), isNull);
        expect(find.byType(ImportMethodCardWidget), findsOneWidget);
      },
    );

    testWidgets(
      'Given widget rebuilt with isLoading toggled, When pump called, '
      'Then UI updates correctly',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        // Initially not loading
        await tester.pumpWidget(
          buildTestWidget(
            const ImportMethodCardWidget(
              icon: Icons.upload_file,
              title: 'Upload',
            ),
          ),
        );
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // Update to loading state
        await tester.pumpWidget(
          buildTestWidget(
            const ImportMethodCardWidget(
              icon: Icons.upload_file,
              title: 'Upload',
              isLoading: true,
            ),
          ),
        );
        await tester.pump();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );
  });
}
