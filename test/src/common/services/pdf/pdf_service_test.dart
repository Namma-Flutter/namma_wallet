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
    test('uses default mappings when fieldMappings is null', () async {
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

    test('uses custom fieldMappings when provided', () async {
      const text = '''
Booking Ref: ABC987
Journey Date: 15-08-2025
Bus Route: 55B
Boarding: Madurai
Destination: Trichy
Cost: 500
Seats: 5
''';
      pdfService.mockBlocks = OCRBlock.fromPlainText(text);

      final customMappings = {
        'pnr': ['Booking Ref'],
        'date': ['Journey Date'],
        'route': ['Bus Route'],
        'from': ['Boarding'],
        'to': ['Destination'],
        'fare': ['Cost'],
        'seat': ['Seats'],
      };

      final result = await pdfService.extractStructuredData(
        FakeXFile(),
        fieldMappings: customMappings,
      );

      expect(result['pnr'], 'ABC987');
      expect(result['date'], '15-08-2025');
      expect(result['route'], '55B');
      expect(result['from'], 'Madurai');
      expect(result['to'], 'Trichy');
      expect(result['fare'], '500');
      expect(result['seat'], '5');
    });

    test(
      'extracts only mapped fields and ignores defaults if custom is provided',
      () async {
        const text = '''
PNR Number : 123456789
Custom PNR : ABC987
''';
        pdfService.mockBlocks = OCRBlock.fromPlainText(text);

        final customMappings = {
          'pnr': ['Custom PNR'],
        };

        final result = await pdfService.extractStructuredData(
          FakeXFile(),
          fieldMappings: customMappings,
        );

        expect(result['pnr'], 'ABC987');
        expect(result.containsKey('from'), isFalse);
      },
    );
  });
}
