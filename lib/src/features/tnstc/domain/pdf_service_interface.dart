import 'dart:io';

/// Interface for PDF text extraction service.
///
/// Implementations should handle:
/// - Extracting text directly from PDF files
/// - Falling back to OCR for image-based PDFs
/// - Cleaning and normalizing extracted text
abstract interface class IPDFService {
  /// Extracts text from a PDF file.
  ///
  /// Returns the extracted and cleaned text. Falls back to OCR if the PDF
  /// is image-based or uses unsupported fonts.
  /// Throws an exception if extraction fails.
  Future<String> extractTextFrom(File pdf);
}
