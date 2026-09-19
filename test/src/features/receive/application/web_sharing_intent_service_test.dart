import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/receive/application/web_sharing_intent_service.dart';

void main() {
  group('WebSharingIntentService', () {
    late WebSharingIntentService service;

    setUp(() {
      service = WebSharingIntentService();
    });

    group('initialize', () {
      test('completes normally without calling callbacks', () async {
        var onContentReceivedCalled = false;
        var onErrorCalled = false;

        await expectLater(
          service.initialize(
            onContentReceived: (content, type) {
              onContentReceivedCalled = true;
            },
            onError: (error) {
              onErrorCalled = true;
            },
          ),
          completes,
        );

        expect(onContentReceivedCalled, isFalse);
        expect(onErrorCalled, isFalse);
      });
    });

    group('extractContentFromFile', () {
      test('throws UnsupportedError', () async {
        final mockFile = XFile('dummy/path.txt');

        expect(
          () => service.extractContentFromFile(mockFile),
          throwsA(
            isA<UnsupportedError>().having(
              (e) => e.message,
              'message',
              'extractContentFromFile is not supported on web',
            ),
          ),
        );
      });
    });

    group('dispose', () {
      test('completes normally', () async {
        await expectLater(service.dispose(), completes);
      });
    });
  });
}
