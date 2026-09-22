import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_service_interface.dart';
import 'package:namma_wallet/src/common/services/pdf/pdf_service.dart';

import '../../../../helpers/fake_logger.dart';

class MockOCRService implements IOCRService {
  @override
  Future<List<OCRBlock>> extractBlocksFromImage(XFile image) async => [];

  @override
  Future<List<OCRBlock>> extractBlocksFromPDF(XFile pdfFile) async => [];

  @override
  Future<String> extractTextFromPDF(XFile pdfFile) async => '';
}

class TestPDFService extends PDFService {
  TestPDFService({required super.ocrService, required super.logger});

  List<OCRBlock> mockBlocks = [];

  @override
  Future<List<OCRBlock>> extractBlocks(XFile pdf) async {
    return mockBlocks;
  }
}

class FakeXFile extends Fake implements XFile {
  @override
  Future<int> length() async => 0;

  @override
  String get name => 'fake.pdf';
}

void main() {
  late TestPDFService pdfService;
  late MockOCRService mockOCRService;
  late FakeLogger fakeLogger;

  setUp(() {
    mockOCRService = MockOCRService();
    fakeLogger = FakeLogger();

    pdfService = TestPDFService(ocrService: mockOCRService, logger: fakeLogger);
  });

  group('PDFService extractStructuredData tests', () {
    test('extracts fields using default mappings', () async {
      const text = '''
PNR Number : 123456789
Date of Journey : 01/01/2026
Route No : 100A
Service Start Place : Chennai
Service End Place : Bangalore
Total Fare : 1000
Seat No : 1, 2
''';
      pdfService.mockBlocks = OCRBlock.fromPlainText(text);

      final result = await pdfService.extractStructuredData(FakeXFile());

      expect(result['pnr'], '123456789');
      expect(result['date'], '01/01/2026');
      expect(result['route'], '100A');
      expect(result['from'], 'Chennai');
      expect(result['to'], 'Bangalore');
      expect(result['fare'], '1000');
      expect(result['seat'], '1, 2');
    });
  });
}
