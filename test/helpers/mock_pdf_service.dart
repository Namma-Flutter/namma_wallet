import 'dart:io';

import 'package:namma_wallet/src/features/tnstc/domain/pdf_service_interface.dart';

/// Mock PDF service for testing purposes
/// Returns predefined text content for PDF files
class MockPDFService implements IPDFService {
  MockPDFService({
    this.mockPdfText =
        'Mock PDF Content\nPNR: T12345678\nFrom: Chennai To: Bangalore',
    this.shouldThrowError = false,
  });

  /// Default text to return when extracting from PDFs
  final String mockPdfText;

  /// Whether to throw an error when extracting
  final bool shouldThrowError;

  @override
  Future<String> extractTextFrom(File pdf) async {
    if (shouldThrowError) {
      throw Exception('Mock PDF extraction error');
    }
    return mockPdfText;
  }
}
