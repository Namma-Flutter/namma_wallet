/// Content type for shared content
enum SharedContentType {
  /// SMS text content
  sms,

  /// PDF file content (text extracted from PDF)
  pdf,

  /// Image file content (text extracted from image using OCR)
  image,

  /// PKPass file content
  pkpass,
}
