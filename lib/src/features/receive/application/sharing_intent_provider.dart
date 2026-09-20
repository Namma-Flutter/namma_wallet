import 'package:share_handler/share_handler.dart';

/// Interface for Sharing Intent Provider
abstract class ISharingIntentProvider {
  /// Get the media stream for sharing intents
  Stream<SharedMedia?> getMediaStream();

  /// Get the initial media when the app is launched via sharing
  Future<SharedMedia?> getInitialSharing();
}

/// Concrete implementation of Sharing Intent Provider
class SharingIntentProvider implements ISharingIntentProvider {
  @override
  Stream<SharedMedia?> getMediaStream() {
    return ShareHandlerPlatform.instance.sharedMediaStream;
  }

  @override
  Future<SharedMedia?> getInitialSharing() {
    return ShareHandlerPlatform.instance.getInitialSharedMedia();
  }
}
