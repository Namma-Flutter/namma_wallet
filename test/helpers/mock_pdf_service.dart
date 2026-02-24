import 'package:cross_file/cross_file.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';
import 'package:namma_wallet/src/common/services/pdf/pdf_service_interface.dart';

/// Mock PDF service for testing purposes
/// Returns predefined text content for PDF files
class MockPDFService implements IPDFService {
  MockPDFService({
    this.mockPdfText =
        'Mock PDF Content\nPNR: T12345678\nFrom: Chennai To: Bangalore',
    this.shouldThrowError = false,
    this.mockStructuredData = const {
      'pnr': 'T12345678',
      'from': 'Chennai',
      'to': 'Bangalore',
    },
  });

  /// Default text to return when extracting from PDFs
  String mockPdfText;

  /// Whether to throw an error when extracting
  bool shouldThrowError;

  /// Mock structured data to return from extractStructuredData
  Map<String, dynamic> mockStructuredData;

  @override
  Future<String> extractTextForDisplay(XFile pdf) async {
    if (shouldThrowError) {
      throw Exception('Mock PDF extraction error');
    }
    return mockPdfText;
  }

  @override
  Future<String> extractTextFrom(XFile pdf) => extractTextForDisplay(pdf);

  @override
  Future<List<OCRBlock>> extractBlocks(XFile pdf) async {
    if (shouldThrowError) {
      throw Exception('Mock PDF extraction error');
    }

    // Convert mock text to blocks with synthetic geometry
    return OCRBlock.fromPlainText(mockPdfText);
  }

  @override
  Future<Map<String, dynamic>> extractStructuredData(XFile pdf) async {
    if (shouldThrowError) {
      throw Exception('Mock PDF extraction error');
    }

    // Return mock structured data
    return mockStructuredData;
  }
}
