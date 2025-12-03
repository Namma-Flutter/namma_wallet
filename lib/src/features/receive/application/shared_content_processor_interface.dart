import 'package:namma_wallet/src/features/receive/domain/shared_content_result.dart';
import 'package:namma_wallet/src/features/receive/domain/shared_content_type.dart';

/// Interface for processing shared content (SMS, PDF text) into tickets.
///
/// Defines the contract for handling shared content from external sources,
/// parsing it into tickets, and managing updates to existing tickets.
// More methods may be added in the future.
// ignore: one_member_abstracts
abstract interface class ISharedContentProcessor {
  /// Process shared content and return the result.
  ///
  /// Attempts to:
  /// 1. Check if content is an update SMS (conductor details, etc.)
  /// 2. If update: apply to existing ticket in DB
  /// 3. If not update: parse as new ticket and save to DB
  ///
  /// [content] The text content to process
  /// [contentType] Specifies whether the content is from SMS or PDF
  ///
  /// Returns a [SharedContentResult] indicating success or failure
  Future<SharedContentResult> processContent(
    String content,
    SharedContentType contentType,
  );
}
