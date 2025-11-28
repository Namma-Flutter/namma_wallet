import 'package:cross_file/cross_file.dart';
import 'package:namma_wallet/src/features/receive/domain/shared_content_type.dart';
import 'package:namma_wallet/src/features/receive/domain/sharing_intent_service_interface.dart';

class WebSharingIntentService implements ISharingIntentService {
  @override
  Future<void> initialize({
    required void Function(String content, SharedContentType type)
    onContentReceived,
    required void Function(String) onError,
  }) async {
    // Sharing intent is not supported on web (use PWA Share Target instead)
    // This method is a no-op - native sharing intents are not available
    return;
  }

  @override
  Future<String> extractContentFromFile(XFile file) async {
    throw UnsupportedError('extractContentFromFile is not supported on web');
  }

  @override
  Future<void> dispose() async {
    // No-op on web - no resources to dispose as sharing intents are not supported
    return;
  }
}
