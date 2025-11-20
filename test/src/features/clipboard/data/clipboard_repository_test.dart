import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/clipboard/data/clipboard_repository.dart';
import 'package:namma_wallet/src/features/clipboard/domain/i_clipboard_repository.dart';

import '../../../../helpers/fake_logger.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ClipboardRepository Data Layer Tests', () {
    late ClipboardRepository repository;
    final getIt = GetIt.instance;

    setUp(() {
      // Register fake logger
      if (!getIt.isRegistered<ILogger>()) {
        getIt.registerSingleton<ILogger>(FakeLogger());
      }

      // Create repository instance
      repository = ClipboardRepository(logger: FakeLogger());
    });

    tearDown(() async {
      await getIt.reset();
    });

    group('Interface Compliance', () {
      test(
        'Given ClipboardRepository, When checking type, '
        'Then implements IClipboardRepository interface',
        () {
          // Arrange (Given)
          final repo = ClipboardRepository();

          // Act & Assert (When & Then)
          expect(repo, isA<IClipboardRepository>());
        },
      );

      test(
        'Given ClipboardRepository, When checking methods, '
        'Then has hasTextContent method',
        () {
          // Arrange (Given)
          final repo = ClipboardRepository();

          // Act & Assert (When & Then)
          expect(repo.hasTextContent, isA<Future<bool> Function()>());
        },
      );

      test(
        'Given ClipboardRepository, When checking methods, '
        'Then has readText method',
        () {
          // Arrange (Given)
          final repo = ClipboardRepository();

          // Act & Assert (When & Then)
          expect(repo.readText, isA<Future<String?> Function()>());
        },
      );
    });

    group('hasTextContent Method', () {
      test(
        'Given clipboard with text content, When checking hasTextContent, '
        'Then returns true',
        () async {
          // Arrange (Given)
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                SystemChannels.platform,
                (MethodCall methodCall) async {
                  if (methodCall.method == 'Clipboard.hasStrings') {
                    return <String, dynamic>{'value': true};
                  }
                  return null;
                },
              );

          // Act (When)
          final hasContent = await repository.hasTextContent();

          // Assert (Then)
          expect(hasContent, isTrue);
        },
      );

      test(
        'Given empty clipboard, When checking hasTextContent, '
        'Then returns false',
        () async {
          // Arrange (Given)
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                SystemChannels.platform,
                (MethodCall methodCall) async {
                  if (methodCall.method == 'Clipboard.hasStrings') {
                    return <String, dynamic>{'value': false};
                  }
                  return null;
                },
              );

          // Act (When)
          final hasContent = await repository.hasTextContent();

          // Assert (Then)
          expect(hasContent, isFalse);
        },
      );

      test(
        'Given platform exception, When checking hasTextContent, '
        'Then returns false without throwing',
        () async {
          // Arrange (Given)
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                SystemChannels.platform,
                (MethodCall methodCall) async {
                  if (methodCall.method == 'Clipboard.hasStrings') {
                    throw PlatformException(
                      code: 'CLIPBOARD_ERROR',
                      message: 'Unable to access clipboard',
                    );
                  }
                  return null;
                },
              );

          // Act (When)
          final hasContent = await repository.hasTextContent();

          // Assert (Then)
          expect(hasContent, isFalse);
        },
      );

      test(
        'Given unexpected exception, When checking hasTextContent, '
        'Then returns false without throwing',
        () async {
          // Arrange (Given)
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                SystemChannels.platform,
                (MethodCall methodCall) async {
                  if (methodCall.method == 'Clipboard.hasStrings') {
                    throw Exception('Unexpected error');
                  }
                  return null;
                },
              );

          // Act (When)
          final hasContent = await repository.hasTextContent();

          // Assert (Then)
          expect(hasContent, isFalse);
        },
      );
    });

    group('readText Method', () {
      test(
        'Given clipboard with text, When reading text, '
        'Then returns trimmed text content',
        () async {
          // Arrange (Given)
          const clipboardText = '  Hello from clipboard  ';
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                SystemChannels.platform,
                (MethodCall methodCall) async {
                  if (methodCall.method == 'Clipboard.getData') {
                    return <String, dynamic>{'text': clipboardText};
                  }
                  return null;
                },
              );

          // Act (When)
          final text = await repository.readText();

          // Assert (Then)
          expect(text, isNotNull);
          expect(text, equals('Hello from clipboard'));
          expect(text, isNot(contains('  ')));
        },
      );

      test(
        'Given clipboard with multiline text, When reading text, '
        'Then preserves newlines but trims edges',
        () async {
          // Arrange (Given)
          const clipboardText = '  Line 1\nLine 2\nLine 3  ';
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                SystemChannels.platform,
                (MethodCall methodCall) async {
                  if (methodCall.method == 'Clipboard.getData') {
                    return <String, dynamic>{'text': clipboardText};
                  }
                  return null;
                },
              );

          // Act (When)
          final text = await repository.readText();

          // Assert (Then)
          expect(text, isNotNull);
          expect(text, contains('\n'));
          expect(text, contains('Line 1'));
          expect(text, contains('Line 3'));
        },
      );

      test(
        'Given empty clipboard, When reading text, '
        'Then returns null',
        () async {
          // Arrange (Given)
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                SystemChannels.platform,
                (MethodCall methodCall) async {
                  if (methodCall.method == 'Clipboard.getData') {
                    return null; // Null for empty clipboard
                  }
                  return null;
                },
              );

          // Act (When)
          final text = await repository.readText();

          // Assert (Then)
          expect(text, isNull);
        },
      );

      test(
        'Given whitespace-only clipboard content, When reading text, '
        'Then returns null',
        () async {
          // Arrange (Given)
          const clipboardText = '   \n\t   ';
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                SystemChannels.platform,
                (MethodCall methodCall) async {
                  if (methodCall.method == 'Clipboard.getData') {
                    return <String, dynamic>{'text': clipboardText};
                  }
                  return null;
                },
              );

          // Act (When)
          final text = await repository.readText();

          // Assert (Then)
          expect(text, isNull);
        },
      );

      test(
        'Given platform exception, When reading text, '
        'Then returns null without throwing',
        () async {
          // Arrange (Given)
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                SystemChannels.platform,
                (MethodCall methodCall) async {
                  if (methodCall.method == 'Clipboard.getData') {
                    throw PlatformException(
                      code: 'CLIPBOARD_ERROR',
                      message: 'Unable to read clipboard',
                    );
                  }
                  return null;
                },
              );

          // Act (When)
          final text = await repository.readText();

          // Assert (Then)
          expect(text, isNull);
        },
      );

      test(
        'Given unexpected exception, When reading text, '
        'Then returns null without throwing',
        () async {
          // Arrange (Given)
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                SystemChannels.platform,
                (MethodCall methodCall) async {
                  if (methodCall.method == 'Clipboard.getData') {
                    throw Exception('Network error');
                  }
                  return null;
                },
              );

          // Act (When)
          final text = await repository.readText();

          // Assert (Then)
          expect(text, isNull);
        },
      );

      test(
        'Given clipboard with special characters, When reading text, '
        'Then preserves special characters',
        () async {
          // Arrange (Given)
          const clipboardText = r'Test@#$%^&*()_+{}|:"<>?';
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                SystemChannels.platform,
                (MethodCall methodCall) async {
                  if (methodCall.method == 'Clipboard.getData') {
                    return <String, dynamic>{'text': clipboardText};
                  }
                  return null;
                },
              );

          // Act (When)
          final text = await repository.readText();

          // Assert (Then)
          expect(text, equals(clipboardText));
          expect(text, contains('@'));
          expect(text, contains('|'));
        },
      );

      test(
        'Given clipboard with Unicode characters, When reading text, '
        'Then preserves Unicode characters',
        () async {
          // Arrange (Given)
          const clipboardText = 'தமிழ் 中文 한국어 🎫';
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                SystemChannels.platform,
                (MethodCall methodCall) async {
                  if (methodCall.method == 'Clipboard.getData') {
                    return <String, dynamic>{'text': clipboardText};
                  }
                  return null;
                },
              );

          // Act (When)
          final text = await repository.readText();

          // Assert (Then)
          expect(text, equals(clipboardText));
          expect(text, contains('தமிழ்'));
          expect(text, contains('🎫'));
        },
      );

      test(
        'Given very long clipboard content, When reading text, '
        'Then returns full content',
        () async {
          // Arrange (Given)
          final clipboardText = 'A' * 15000;
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                SystemChannels.platform,
                (MethodCall methodCall) async {
                  if (methodCall.method == 'Clipboard.getData') {
                    return <String, dynamic>{'text': clipboardText};
                  }
                  return null;
                },
              );

          // Act (When)
          final text = await repository.readText();

          // Assert (Then)
          expect(text, isNotNull);
          expect(text?.length, equals(15000));
        },
      );
    });

    group('Error Handling', () {
      test(
        'Given specific platform error code, When accessing clipboard, '
        'Then logs error and returns safe default',
        () async {
          // Arrange (Given)
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                SystemChannels.platform,
                (MethodCall methodCall) async {
                  throw PlatformException(
                    code: 'ACCESS_DENIED',
                    message: 'Clipboard access denied',
                  );
                },
              );

          // Act (When)
          final hasContent = await repository.hasTextContent();
          final text = await repository.readText();

          // Assert (Then)
          expect(hasContent, isFalse);
          expect(text, isNull);
        },
      );

      test(
        'Given null response from platform, When reading text, '
        'Then returns null gracefully',
        () async {
          // Arrange (Given)
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                SystemChannels.platform,
                (MethodCall methodCall) async {
                  return null;
                },
              );

          // Act (When)
          final text = await repository.readText();

          // Assert (Then)
          expect(text, isNull);
        },
      );
    });

    group('Constructor Variations', () {
      test(
        'Given no logger provided, When creating repository, '
        'Then uses GetIt logger',
        () {
          // Arrange & Act (Given & When)
          final repo = ClipboardRepository();

          // Assert (Then)
          expect(repo, isNotNull);
          expect(repo, isA<IClipboardRepository>());
        },
      );

      test(
        'Given custom logger, When creating repository, '
        'Then uses provided logger',
        () {
          // Arrange (Given)
          final customLogger = FakeLogger();

          // Act (When)
          final repo = ClipboardRepository(logger: customLogger);

          // Assert (Then)
          expect(repo, isNotNull);
          expect(repo, isA<IClipboardRepository>());
        },
      );
    });
  });
}
