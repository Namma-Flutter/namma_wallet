import 'dart:async';

import 'package:namma_wallet/src/features/receive/application/sharing_intent_provider.dart';
import 'package:share_handler/share_handler.dart';

class MockSharingIntentProvider implements ISharingIntentProvider {
  final StreamController<SharedMedia?> _controller =
      StreamController<SharedMedia?>.broadcast();
  SharedMedia? initialMedia;

  void emitMedia(SharedMedia? media) {
    _controller.add(media);
  }

  void emitError(Object error) {
    _controller.addError(error);
  }

  @override
  Stream<SharedMedia?> getMediaStream() {
    return _controller.stream;
  }

  @override
  Future<SharedMedia?> getInitialSharing() async {
    return initialMedia;
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
