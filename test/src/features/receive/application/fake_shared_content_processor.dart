import 'package:namma_wallet/src/features/receive/application/shared_content_processor_interface.dart';
import 'package:namma_wallet/src/features/receive/domain/shared_content_result.dart';
import 'package:namma_wallet/src/features/receive/domain/shared_content_type.dart';

/// Fake implementation of [ISharedContentProcessor] for testing.
class FakeSharedContentProcessor implements ISharedContentProcessor {
  SharedContentResult? resultToReturn;
  Future<SharedContentResult> Function(String, SharedContentType)?
  onProcessContent;

  int callCount = 0;
  final List<String> receivedContents = [];
  final List<SharedContentType> receivedTypes = [];

  @override
  Future<SharedContentResult> processContent(
    String content,
    SharedContentType contentType,
  ) async {
    callCount++;
    receivedContents.add(content);
    receivedTypes.add(contentType);
    if (onProcessContent != null) {
      return onProcessContent!(content, contentType);
    }
    return resultToReturn ??
        const ProcessingErrorResult(
          message: 'No result configured',
          error: 'No fake result set',
        );
  }
}
