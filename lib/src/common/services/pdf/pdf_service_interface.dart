import 'package:cross_file/cross_file.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';

/// Interface for PDF text extraction service.
///
/// Implementations should handle:
/// - Extracting text directly from PDF files
/// - Extracting text blocks with geometric information (for structured data)
/// - Falling back to OCR for image-based PDFs
/// - Cleaning and normalizing extracted text
abstract interface class IPDFService {
  /// Extracts text from a PDF file for human-readable display.
  ///
  /// Returns cleaned and normalized text suitable for display to users.
  /// Falls back to OCR if the PDF is image-based or uses unsupported fonts.
  ///
  /// ⚠️ Do NOT use this for structured data extraction - use [extractBlocks]
  /// instead, as the cleaning process may alter field names and values.
  ///
  /// Throws an exception if extraction fails.
  Future<String> extractTextForDisplay(XFile pdf);

  /// Legacy alias for [extractTextForDisplay].
  ///
  /// Deprecated: Use [extractTextForDisplay] or [extractBlocks] instead.
  @Deprecated(
    'Use extractTextForDisplay for display or extractBlocks for '
    'structured extraction',
  )
  Future<String> extractTextFrom(XFile pdf);

  /// Extracts OCR blocks with geometric information from a PDF file.
  ///
  /// This method is preferred for structured data extraction as it preserves
  /// spatial relationships between text elements.
  ///
  /// Returns a list of [OCRBlock] objects containing text and bounding boxes.
  /// Falls back to OCR automatically for image-based PDFs.
  ///
  /// Throws an exception if extraction fails.
  Future<List<OCRBlock>> extractBlocks(XFile pdf);

  /// Extracts structured data from a PDF file.
  ///
  /// This is a higher-level method that returns a structured map of key-value
  /// pairs extracted from the PDF using layout analysis.
  ///
  /// Returns a map with field names as keys and extracted values.
  /// The exact fields depend on the document type.
  ///
  /// Throws an exception if extraction fails.
  Future<Map<String, dynamic>> extractStructuredData(XFile pdf);
}
