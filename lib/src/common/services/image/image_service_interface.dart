import 'package:cross_file/cross_file.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';

/// Interface for Image text extraction service.
///
/// Implementations should handle:
/// - Extracting text directly from Image file
/// - Extracting text blocks with geometric information (for structured data)
/// - Cleaning and normalizing extracted text
abstract interface class IImageService {

  /// Extracts OCR blocks with geometric information from an Image file.
  ///
  /// This method is preferred for structured data extraction as it preserves
  /// spatial relationships between text elements.
  ///
  /// Returns a list of [OCRBlock] objects containing text and bounding boxes.
  ///
  /// Throws an exception if extraction fails.
  Future<List<OCRBlock>> extractBlocks(XFile img);

  /// Extracts structured data from an Image file.
  ///
  /// This is a higher-level method that returns a structured map of key-value
  /// pairs extracted from the Image using layout analysis.
  ///
  /// Returns a map with field names as keys and extracted values.
  /// The exact fields depend on the document type.
  ///
  /// Throws an exception if extraction fails.
  Future<Map<String, dynamic>> extractStructuredData(XFile img);
}
