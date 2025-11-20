/// Abstract interface for clipboard operations.
///
/// Defines the contract for reading from the system clipboard.
/// Implementations should handle platform-specific clipboard access.
///
/// Never throws - all errors should be returned as error results.
abstract class IClipboardRepository {
  /// Checks if the clipboard currently has text content.
  ///
  /// Returns `true` if clipboard contains text, `false` otherwise.
  /// Returns `false` if clipboard access fails.
  Future<bool> hasTextContent();

  /// Reads text content from the system clipboard.
  ///
  /// Returns the text content if available, or `null` if:
  /// - Clipboard is empty
  /// - Clipboard contains non-text content
  /// - Platform error occurs
  ///
  /// Never throws - returns `null` on any error.
  Future<String?> readText();
}
