import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/receive/application/sharing_intent_provider.dart';
import 'package:share_handler/share_handler.dart';

/// Fake implementation of ShareHandlerPlatform for testing
class FakeShareHandlerPlatform extends ShareHandlerPlatform {
  FakeShareHandlerPlatform() : super() {
    // Required token for PlatformInterface
    ShareHandlerPlatform.instance = this;
  }

  SharedMedia? _initialSharedMedia;
  final StreamController<SharedMedia> _streamController =
      StreamController<SharedMedia>.broadcast();

  @override
  Stream<SharedMedia> get sharedMediaStream => _streamController.stream;

  @override
  Future<SharedMedia?> getInitialSharedMedia() async {
    return _initialSharedMedia;
  }

  // Test helpers
  void setInitialSharedMedia(SharedMedia? media) {
    _initialSharedMedia = media;
  }

  void addSharedMedia(SharedMedia media) {
    _streamController.add(media);
  }

  Future<void> dispose() async {
    await _streamController.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharingIntentProvider', () {
    late SharingIntentProvider provider;
    late FakeShareHandlerPlatform fakePlatform;

    setUp(() {
      fakePlatform = FakeShareHandlerPlatform();
      provider = SharingIntentProvider();
    });

    tearDown(() async {
      await fakePlatform.dispose();
    });

    test('getInitialSharing calls correct platform method', () async {
      final testMedia = SharedMedia(content: 'test_content');
      fakePlatform.setInitialSharedMedia(testMedia);

      final result = await provider.getInitialSharing();

      expect(result, equals(testMedia));
      expect(result?.content, equals('test_content'));
    });

    test('getInitialSharing returns null when no media', () async {
      fakePlatform.setInitialSharedMedia(null);

      final result = await provider.getInitialSharing();

      expect(result, isNull);
    });

    test('getMediaStream returns stream', () {
      final stream = provider.getMediaStream();
      expect(stream, isA<Stream<SharedMedia>>());
    });

    test('getMediaStream emits shared media', () async {
      final testMedia = SharedMedia(content: 'test_content');

      final streamFuture = provider.getMediaStream().first;
      fakePlatform.addSharedMedia(testMedia);

      final result = await streamFuture;
      expect(result, isNotNull);
      expect(result?.content, equals('test_content'));
    });
  });
}
