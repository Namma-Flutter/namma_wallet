/// Defines the type of content found in the clipboard.
///
/// Used to categorize clipboard content for appropriate handling:
/// - [text]: Plain text content
/// - [travelTicket]: Travel ticket data (SMS/text format)
/// - [invalid]: Content that couldn't be classified or is unsupported
enum ClipboardContentType {
  /// Plain text content without any special formatting
  text,

  /// Travel ticket data (TNSTC, IRCTC, etc.)
  travelTicket,

  /// Invalid or unsupported content
  invalid,
}
