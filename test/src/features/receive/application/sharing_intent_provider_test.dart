import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/receive/application/sharing_intent_provider.dart';
import 'package:share_handler/share_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharingIntentProvider', () {
    late SharingIntentProvider provider;
    final log = <MethodCall>[];

    setUp(() {
      provider = SharingIntentProvider();
      log.clear();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('share_handler'), (
            MethodCall methodCall,
          ) async {
            log.add(methodCall);
            if (methodCall.method == 'getInitialSharedMedia') {
              return <String, dynamic>{
                'content': 'test_content',
                'attachments': null,
              };
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('share_handler'), null);
    });

    test('getInitialSharing calls correct platform method', () async {
      final result = await provider.getInitialSharing();

      expect(log, hasLength(1));
      expect(log.first.method, equals('getInitialSharedMedia'));
      expect(result, isA<SharedMedia?>());
      expect(result?.content, equals('test_content'));
    });

    test('getMediaStream returns stream', () {
      final stream = provider.getMediaStream();
      expect(stream, isA<Stream<SharedMedia?>>());
    });
  });
}
