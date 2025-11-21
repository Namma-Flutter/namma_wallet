import 'dart:io';

/// Interface for OCR (Optical Character Recognition) service.
///
/// Implementations should handle:
/// - Extracting text from PDF files using OCR
/// - Converting PDF pages to images for processing
/// - Proper resource cleanup and error handling
abstract interface class IOCRService {
  /// Extracts text from a PDF file using OCR.
  ///
  /// Returns the extracted text as a string, with pages separated by double newlines.
  /// Throws an exception if OCR extraction fails.
  Future<String> extractTextFromPDF(File pdfFile);
}
