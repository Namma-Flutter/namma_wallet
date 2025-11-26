import 'dart:async';

import 'package:listen_sharing_intent/listen_sharing_intent.dart';
import 'package:namma_wallet/src/features/receive/application/sharing_intent_provider.dart';

class MockSharingIntentProvider implements ISharingIntentProvider {
  final StreamController<List<SharedMediaFile>> _controller =
      StreamController<List<SharedMediaFile>>.broadcast();
  List<SharedMediaFile> initialMedia = [];

  void emitMedia(List<SharedMediaFile> media) {
    _controller.add(media);
  }

  @override
  Stream<List<SharedMediaFile>> getMediaStream() {
    return _controller.stream;
  }

  @override
  Future<List<SharedMediaFile>> getInitialMedia() async {
    return initialMedia;
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
