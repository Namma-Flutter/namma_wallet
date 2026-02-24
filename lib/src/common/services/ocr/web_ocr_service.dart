import 'package:cross_file/cross_file.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_service_interface.dart';

class WebOCRService implements IOCRService {
  @override
  Future<List<OCRBlock>> extractBlocksFromPDF(XFile pdfFile) async {
    // OCR is not yet supported on web
    throw UnsupportedError(
      'OCR block extraction from PDF is not supported on web platform.',
    );
  }

  @override
  Future<String> extractTextFromPDF(XFile pdfFile) async {
    // OCR is not yet supported on web
    throw UnsupportedError(
      'OCR text extraction from PDF is not supported on web platform.',
    );
  }
}
