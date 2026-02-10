import 'package:cross_file/cross_file.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';

/// Interface for OCR (Optical Character Recognition) service.
///
/// Implementations should handle:
/// - Extracting text from PDF files using OCR
/// - Converting PDF pages to images for processing
/// - Preserving layout information (bounding boxes) for structured extraction
/// - Proper resource cleanup and error handling
abstract interface class IOCRService {
  /// Extracts text blocks with geometric information from a PDF file using
  /// OCR.
  ///
  /// This is the preferred method for structured data extraction as it
  /// preserves spatial relationships between text elements. Use
  /// [extractTextFromPDF] only when geometry is not needed.
  ///
  /// Returns a list of [OCRBlock] objects, each containing text and its
  /// bounding box. Blocks are ordered by page, then typically
  /// top-to-bottom, left-to-right.
  ///
  /// Throws an exception if OCR extraction fails.
  Future<List<OCRBlock>> extractBlocksFromPDF(XFile pdfFile);

  /// Extracts text from a PDF file using OCR (legacy method).
  ///
  /// Returns the extracted text as a string, with pages separated by double
  /// newlines. This method discards geometric information - prefer
  /// [extractBlocksFromPDF] for structured extraction.
  ///
  /// Throws an exception if OCR extraction fails.
  Future<String> extractTextFromPDF(XFile pdfFile);
}
