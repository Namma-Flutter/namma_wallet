/// Content type for shared content
enum SharedContentType {
  /// SMS text content
  sms,

  /// PDF file content (text extracted from PDF)
  pdf,

  /// Image file content (image file path; OCR happens downstream)
  image,

  /// PKPass file content
  pkpass,
}
