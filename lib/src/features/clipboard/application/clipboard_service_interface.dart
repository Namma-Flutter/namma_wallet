import 'package:flutter/material.dart';
import 'package:namma_wallet/src/features/clipboard/domain/clipboard_result.dart';

/// Interface for clipboard operations service.
///
/// Defines the contract for orchestrating clipboard reading,
/// content validation, parsing, and ticket storage.
abstract interface class IClipboardService {
  /// Reads clipboard content and attempts to parse it as a travel ticket.
  ///
  /// Workflow:
  /// 1. Check if clipboard has text content
  /// 2. Read and validate text content
  /// 3. Check if it's an update SMS (conductor details, etc.)
  /// 4. If update SMS, apply updates to existing ticket
  /// 5. Otherwise, attempt to parse as new ticket
  /// 6. Save new ticket to database
  /// 7. Return result with ticket or error
  ///
  /// Returns [ClipboardResult] with:
  /// - Success: Content type and parsed ticket
  /// - Error: Error message if content cannot be parsed as a travel ticket
  ///
  /// Never throws - all errors are returned as [ClipboardResult.error].
  Future<ClipboardResult> readAndParseClipboard();

  /// Shows a snackbar message based on the clipboard result.
  ///
  /// Displays success message or error.
  /// Only shows if context is still mounted.
  void showResultMessage(BuildContext context, ClipboardResult result);
}
