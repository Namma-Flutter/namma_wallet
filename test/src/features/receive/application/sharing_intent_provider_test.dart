import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listen_sharing_intent/listen_sharing_intent.dart';
import 'package:namma_wallet/src/features/receive/application/sharing_intent_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharingIntentProvider', () {
    late SharingIntentProvider provider;
    final log = <MethodCall>[];

    setUp(() {
      provider = SharingIntentProvider();
      log.clear();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('receive_sharing_intent/messages'),
            (MethodCall methodCall) async {
              log.add(methodCall);
              if (methodCall.method == 'getInitialMedia') {
                return '[{"path":"test_path","type":"text",'
                    '"thumbnail":null,"duration":null}]';
              }
              return null;
            },
          );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('receive_sharing_intent/messages'),
            null,
          );
    });

    test('getInitialMedia calls correct platform method', () async {
      final result = await provider.getInitialMedia();

      expect(log, hasLength(1));
      expect(log.first.method, equals('getInitialMedia'));
      expect(result, isA<List<SharedMediaFile>>());
      expect(result.first.path, equals('test_path'));
    });

    test('getMediaStream returns stream', () {
      final stream = provider.getMediaStream();
      expect(stream, isA<Stream<List<SharedMediaFile>>>());
    });
  });
}
