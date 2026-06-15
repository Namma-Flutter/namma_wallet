import 'package:namma_wallet/src/features/receive/application/shared_content_processor_interface.dart';
import 'package:namma_wallet/src/features/receive/domain/shared_content_result.dart';
import 'package:namma_wallet/src/features/receive/domain/shared_content_type.dart';

typedef ProcessContentCallback = Future<SharedContentResult> Function(
  String content,
  SharedContentType type,
);

/// A simple mock for [ISharedContentProcessor] used in unit tests.
class MockSharedContentProcessor implements ISharedContentProcessor {
  SharedContentResult resultToReturn = const ProcessingErrorResult(
    message: 'Not configured',
    error: 'resultToReturn not set',
  );

  /// Optional override — takes priority over [resultToReturn].
  ProcessContentCallback? onProcessContent;

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
    return resultToReturn;
  }
}
