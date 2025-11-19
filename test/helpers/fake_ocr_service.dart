import 'dart:io';

import 'package:namma_wallet/src/features/tnstc/application/ocr_service.dart';

/// Fake OCR service implementation for testing purposes
/// This service returns empty string to avoid actual OCR processing in tests
class FakeOCRService extends OCRService {
  @override
  Future<String> extractTextFromPDF(File pdfFile) async {
    // Return empty string in tests - tests use direct text input
    return '';
  }
}
