// We will add more methods in the future.
// ignore_for_file: one_member_abstracts

import 'dart:io';

import 'package:namma_wallet/src/features/share/application/shared_content_processor.dart';

/// Abstract interface for sharing intent services.
///
/// Defines the contract for handling incoming shared content from other apps
/// (files, text, etc.) and extracting their text content.
///
/// Implementations should:
/// - Handle multiple file types (PDF, text files, etc.)
/// - Never throw exceptions - handle errors gracefully via onError callback
/// - Extract text content from files before passing to onContentReceived
/// - Use appropriate fallback mechanisms for unsupported file types
abstract class ISharingIntentService {
  /// Initialize the sharing intent service with callbacks.
  ///
  /// The [onContentReceived] callback receives extracted text content
  /// from shared files or direct text content, along with the content type.
  ///
  /// The [onError] callback receives error messages when
  /// content processing fails.
  void initialize({
    required void Function(String content, SharedContentType type)
    onContentReceived,
    required void Function(String) onError,
  });

  /// Extract text content from a file based on its type.
  ///
  /// The [file] can be any supported file type (PDF, text, etc.).
  /// Implementations should detect the file type and use appropriate
  /// extraction methods.
  ///
  /// Returns the extracted text content.
  /// May throw exceptions for unsupported file types or extraction errors.
  Future<String> extractContentFromFile(File file);

  /// Dispose resources and cleanup.
  ///
  /// This should cancel any subscriptions and free resources.
  void dispose();
}
