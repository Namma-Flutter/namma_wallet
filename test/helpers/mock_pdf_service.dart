import 'dart:ui';

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
  });

  /// Default text to return when extracting from PDFs
  String mockPdfText;

  /// Whether to throw an error when extracting
  bool shouldThrowError;

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
    final lines = mockPdfText.split('\n');
    final blocks = <OCRBlock>[];

    for (final (i, line) in lines.indexed) {
      if (line.trim().isEmpty) continue;
      blocks.add(
        OCRBlock(
          text: line.trim(),
          boundingBox: Rect.fromLTWH(
            0,
            i.toDouble() * 20,
            100,
            20,
          ),
          page: 0,
        ),
      );
    }

    return blocks;
  }

  @override
  Future<Map<String, dynamic>> extractStructuredData(XFile pdf) async {
    if (shouldThrowError) {
      throw Exception('Mock PDF extraction error');
    }

    // Return mock structured data
    return {
      'pnr': 'T12345678',
      'from': 'Chennai',
      'to': 'Bangalore',
    };
  }
}
