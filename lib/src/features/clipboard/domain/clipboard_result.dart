import 'package:namma_wallet/src/features/clipboard/domain/clipboard_content_type.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';

/// Represents the result of a clipboard read operation.
///
/// Contains the parsed content, type classification, and success status.
/// Never throws - failures are represented as error results.
class ClipboardResult {
  /// Creates a clipboard result with all fields.
  const ClipboardResult({
    required this.type,
    required this.isSuccess,
    this.content,
    this.ticket,
    this.errorMessage,
  });

  /// Creates a successful clipboard result.
  ///
  /// [type] - The type of content that was read
  /// [content] - The raw text content from clipboard
  /// [ticket] - Optional parsed ticket if content was a travel ticket
  factory ClipboardResult.success(
    ClipboardContentType type,
    String content, {
    Ticket? ticket,
  }) {
    return ClipboardResult(
      type: type,
      content: content,
      ticket: ticket,
      isSuccess: true,
    );
  }

  /// Creates an error clipboard result.
  ///
  /// [errorMessage] - Description of what went wrong
  factory ClipboardResult.error(String errorMessage) {
    return ClipboardResult(
      type: ClipboardContentType.invalid,
      errorMessage: errorMessage,
      isSuccess: false,
    );
  }

  /// The type of content found in the clipboard
  final ClipboardContentType type;

  /// The raw text content from clipboard (null if error occurred)
  final String? content;

  /// Parsed ticket if content was a travel ticket (null otherwise)
  final Ticket? ticket;

  /// Error message if operation failed (null if successful)
  final String? errorMessage;

  /// Whether the clipboard read operation was successful
  final bool isSuccess;
}
