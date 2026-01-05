/// Defines the type of content found in the clipboard.
///
/// Used to categorize clipboard content for appropriate handling:
/// - [travelTicket]: Travel ticket data (SMS/text format)
/// - [invalid]: Content that couldn't be classified or is unsupported
enum ClipboardContentType {
  /// Travel ticket data (TNSTC, IRCTC, etc.)
  travelTicket,

  /// Invalid or unsupported content
  invalid,
}
