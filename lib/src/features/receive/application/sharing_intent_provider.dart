import 'package:listen_sharing_intent/listen_sharing_intent.dart';

/// Interface for Sharing Intent Provider
abstract class ISharingIntentProvider {
  /// Get the media stream for sharing intents
  Stream<List<SharedMediaFile>> getMediaStream();

  /// Get the initial media when the app is launched via sharing
  Future<List<SharedMediaFile>> getInitialMedia();
}

/// Concrete implementation of Sharing Intent Provider
class SharingIntentProvider implements ISharingIntentProvider {
  @override
  Stream<List<SharedMediaFile>> getMediaStream() {
    return ReceiveSharingIntent.instance.getMediaStream();
  }

  @override
  Future<List<SharedMediaFile>> getInitialMedia() {
    return ReceiveSharingIntent.instance.getInitialMedia();
  }
}
