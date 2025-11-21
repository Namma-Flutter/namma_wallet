import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/share/application/sharing_intent_service.dart';
import 'package:namma_wallet/src/features/share/domain/sharing_intent_service_interface.dart';
import 'package:namma_wallet/src/features/tnstc/domain/ocr_service_interface.dart';
import 'package:namma_wallet/src/features/tnstc/domain/pdf_service_interface.dart';

import '../../../helpers/fake_logger.dart';
import '../../../helpers/mock_ocr_service.dart';
import '../../../helpers/mock_pdf_service.dart';

void main() {
  group('SharingIntentService', () {
    late GetIt getIt;
    late ISharingIntentService service;

    setUp(() {
      getIt = GetIt.asNewInstance()
        ..registerSingleton<ILogger>(FakeLogger())
        ..registerSingleton<IOCRService>(MockOCRService())
        ..registerSingleton<IPDFService>(MockPDFService());

      service = SharingIntentService(
        logger: getIt<ILogger>(),
        pdfService: getIt<IPDFService>(),
      );
    });

    tearDown(() async {
      // Cleanup - Reset GetIt after each test
      service.dispose();
      await getIt.reset();
    });

    group('Interface Compliance', () {
      test(
        'Given SharingIntentService, When checking type, '
        'Then implements ISharingIntentService interface',
        () {
          // Arrange (Given)
          final concreteService = SharingIntentService(
            logger: getIt<ILogger>(),
            pdfService: getIt<IPDFService>(),
          );

          // Act & Assert (When & Then)
          expect(concreteService, isA<ISharingIntentService>());
        },
      );

      test(
        'Given service registered in GetIt, When retrieving service, '
        'Then returns registered instance',
        () {
          // Arrange (Given)
          final testService = SharingIntentService(
            logger: getIt<ILogger>(),
            pdfService: getIt<IPDFService>(),
          );
          getIt.registerSingleton<ISharingIntentService>(testService);

          // Act (When)
          final retrievedService = getIt<ISharingIntentService>();

          // Assert (Then)
          expect(retrievedService, isA<SharingIntentService>());
          expect(retrievedService, same(testService));

          // Cleanup
          getIt.unregister<ISharingIntentService>();
        },
      );
    });

    group('extractContentFromFile', () {
      test(
        'Given a PDF file, When extracting content, '
        'Then returns extracted text from PDFService',
        () async {
          // Arrange (Given)
          final mockPdfService = MockPDFService(
            mockPdfText: 'Test PDF Content\nPNR: T99999999',
          );
          final testService = SharingIntentService(
            logger: FakeLogger(),
            pdfService: mockPdfService,
          );
          final tempDir = await Directory.systemTemp.createTemp('test_pdf');
          final pdfFile = File('${tempDir.path}/test.pdf');
          await pdfFile.writeAsString('dummy pdf content');

          try {
            // Act (When)
            final content = await testService.extractContentFromFile(pdfFile);

            // Assert (Then)
            expect(content, contains('Test PDF Content'));
            expect(content, contains('PNR: T99999999'));
          } finally {
            // Cleanup
            await tempDir.delete(recursive: true);
          }
        },
      );

      test(
        'Given a text file, When extracting content, '
        'Then returns file content as string',
        () async {
          // Arrange (Given)
          final testService = SharingIntentService(
            logger: FakeLogger(),
            pdfService: MockPDFService(),
          );
          final tempDir = await Directory.systemTemp.createTemp('test_txt');
          final textFile = File('${tempDir.path}/test.txt');
          const textContent = 'Test Text Content\nLine 2\nLine 3';
          await textFile.writeAsString(textContent);

          try {
            // Act (When)
            final content = await testService.extractContentFromFile(textFile);

            // Assert (Then)
            expect(content, equals(textContent));
          } finally {
            // Cleanup
            await tempDir.delete(recursive: true);
          }
        },
      );

      test(
        'Given a .sms file, When extracting content, '
        'Then reads as text file',
        () async {
          // Arrange (Given)
          final testService = SharingIntentService(
            logger: FakeLogger(),
            pdfService: MockPDFService(),
          );
          final tempDir = await Directory.systemTemp.createTemp('test_sms');
          final smsFile = File('${tempDir.path}/message.sms');
          const smsContent = 'PNR: T12345678, From: Chennai To: Bangalore';
          await smsFile.writeAsString(smsContent);

          try {
            // Act (When)
            final content = await testService.extractContentFromFile(smsFile);

            // Assert (Then)
            expect(content, equals(smsContent));
          } finally {
            // Cleanup
            await tempDir.delete(recursive: true);
          }
        },
      );

      test(
        'Given PDF with uppercase extension, When extracting content, '
        'Then handles case-insensitive extension matching',
        () async {
          // Arrange (Given)
          final mockPdfService = MockPDFService(
            mockPdfText: 'Uppercase PDF Content',
          );
          final testService = SharingIntentService(
            logger: FakeLogger(),
            pdfService: mockPdfService,
          );
          final tempDir = await Directory.systemTemp.createTemp('test_pdf');
          final pdfFile = File('${tempDir.path}/test.PDF');
          await pdfFile.writeAsString('dummy pdf content');

          try {
            // Act (When)
            final content = await testService.extractContentFromFile(pdfFile);

            // Assert (Then)
            expect(content, contains('Uppercase PDF Content'));
          } finally {
            // Cleanup
            await tempDir.delete(recursive: true);
          }
        },
      );

      test(
        'Given PDF extraction fails, When extracting content, '
        'Then propagates the exception',
        () async {
          // Arrange (Given)
          final mockPdfService = MockPDFService(shouldThrowError: true);
          final testService = SharingIntentService(
            logger: FakeLogger(),
            pdfService: mockPdfService,
          );
          final tempDir = await Directory.systemTemp.createTemp('test_pdf');
          final pdfFile = File('${tempDir.path}/test.pdf');
          await pdfFile.writeAsString('dummy pdf content');

          try {
            // Act & Assert (When & Then)
            expect(
              () => testService.extractContentFromFile(pdfFile),
              throwsException,
            );
          } finally {
            // Cleanup
            await tempDir.delete(recursive: true);
          }
        },
      );

      test(
        'Given empty PDF file, When extracting content, '
        'Then returns empty string from PDFService',
        () async {
          // Arrange (Given)
          final mockPdfService = MockPDFService(mockPdfText: '');
          final testService = SharingIntentService(
            logger: FakeLogger(),
            pdfService: mockPdfService,
          );
          final tempDir = await Directory.systemTemp.createTemp('test_pdf');
          final pdfFile = File('${tempDir.path}/empty.pdf');
          await pdfFile.writeAsString('');

          try {
            // Act (When)
            final content = await testService.extractContentFromFile(pdfFile);

            // Assert (Then)
            expect(content, isEmpty);
          } finally {
            // Cleanup
            await tempDir.delete(recursive: true);
          }
        },
      );

      test(
        'Given empty text file, When extracting content, '
        'Then returns empty string',
        () async {
          // Arrange (Given)
          final testService = SharingIntentService(
            logger: FakeLogger(),
            pdfService: MockPDFService(),
          );
          final tempDir = await Directory.systemTemp.createTemp('test_txt');
          final textFile = File('${tempDir.path}/empty.txt');
          await textFile.writeAsString('');

          try {
            // Act (When)
            final content = await testService.extractContentFromFile(textFile);

            // Assert (Then)
            expect(content, isEmpty);
          } finally {
            // Cleanup
            await tempDir.delete(recursive: true);
          }
        },
      );

      test(
        'Given file with special characters in name, When extracting content, '
        'Then extracts content successfully',
        () async {
          // Arrange (Given)
          final testService = SharingIntentService(
            logger: FakeLogger(),
            pdfService: MockPDFService(),
          );
          final tempDir = await Directory.systemTemp.createTemp('test_special');
          final textFile = File('${tempDir.path}/test-file@123.txt');
          const textContent = 'Content with special chars';
          await textFile.writeAsString(textContent);

          try {
            // Act (When)
            final content = await testService.extractContentFromFile(textFile);

            // Assert (Then)
            expect(content, equals(textContent));
          } finally {
            // Cleanup
            await tempDir.delete(recursive: true);
          }
        },
      );

      test(
        'Given large text file, When extracting content, '
        'Then extracts all content without errors',
        () async {
          // Arrange (Given)
          final testService = SharingIntentService(
            logger: FakeLogger(),
            pdfService: MockPDFService(),
          );
          final tempDir = await Directory.systemTemp.createTemp('test_large');
          final textFile = File('${tempDir.path}/large.txt');
          final largeContent = 'A' * 100000; // 100KB of text
          await textFile.writeAsString(largeContent);

          try {
            // Act (When)
            final content = await testService.extractContentFromFile(textFile);

            // Assert (Then)
            expect(content.length, equals(100000));
            expect(content, equals(largeContent));
          } finally {
            // Cleanup
            await tempDir.delete(recursive: true);
          }
        },
      );

      test(
        'Given file with Unicode content, When extracting content, '
        'Then handles Unicode correctly',
        () async {
          // Arrange (Given)
          final testService = SharingIntentService(
            logger: FakeLogger(),
            pdfService: MockPDFService(),
          );
          final tempDir = await Directory.systemTemp.createTemp('test_unicode');
          final textFile = File('${tempDir.path}/unicode.txt');
          const unicodeContent = 'Tamil: தமிழ் | Hindi: हिन्दी | Emoji: 🚌🎫';
          await textFile.writeAsString(unicodeContent);

          try {
            // Act (When)
            final content = await testService.extractContentFromFile(textFile);

            // Assert (Then)
            expect(content, equals(unicodeContent));
            expect(content, contains('தமிழ்'));
            expect(content, contains('हिन्दी'));
            expect(content, contains('🚌'));
          } finally {
            // Cleanup
            await tempDir.delete(recursive: true);
          }
        },
      );

      test(
        'Given file with no extension, When extracting content, '
        'Then reads as text file',
        () async {
          // Arrange (Given)
          final testService = SharingIntentService(
            logger: FakeLogger(),
            pdfService: MockPDFService(),
          );
          final tempDir = await Directory.systemTemp.createTemp('test_no_ext');
          final textFile = File('${tempDir.path}/noextension');
          const textContent = 'Content without extension';
          await textFile.writeAsString(textContent);

          try {
            // Act (When)
            final content = await testService.extractContentFromFile(textFile);

            // Assert (Then)
            expect(content, equals(textContent));
          } finally {
            // Cleanup
            await tempDir.delete(recursive: true);
          }
        },
      );

      test(
        'Given multiple files extracted sequentially, '
        'When extracting content, '
        'Then each extraction is independent',
        () async {
          // Arrange (Given)
          final testService = SharingIntentService(
            logger: FakeLogger(),
            pdfService: MockPDFService(),
          );
          final tempDir = await Directory.systemTemp.createTemp('test_multi');

          final file1 = File('${tempDir.path}/file1.txt');
          await file1.writeAsString('Content 1');

          final file2 = File('${tempDir.path}/file2.txt');
          await file2.writeAsString('Content 2');

          try {
            // Act (When)
            final content1 = await testService.extractContentFromFile(file1);
            final content2 = await testService.extractContentFromFile(file2);

            // Assert (Then)
            expect(content1, equals('Content 1'));
            expect(content2, equals('Content 2'));
            expect(content1, isNot(equals(content2)));
          } finally {
            // Cleanup
            await tempDir.delete(recursive: true);
          }
        },
      );
    });

    group('Error Handling and Edge Cases', () {
      test(
        'Given file path with spaces, When extracting content, '
        'Then handles path correctly',
        () async {
          // Arrange (Given)
          final testService = SharingIntentService(
            logger: FakeLogger(),
            pdfService: MockPDFService(),
          );
          final tempDir = await Directory.systemTemp.createTemp('test spaces');
          final textFile = File('${tempDir.path}/file with spaces.txt');
          const textContent = 'Content in file with spaces';
          await textFile.writeAsString(textContent);

          try {
            // Act (When)
            final content = await testService.extractContentFromFile(textFile);

            // Assert (Then)
            expect(content, equals(textContent));
          } finally {
            // Cleanup
            await tempDir.delete(recursive: true);
          }
        },
      );

      test(
        'Given text file with line breaks, When extracting content, '
        'Then preserves line breaks',
        () async {
          // Arrange (Given)
          final testService = SharingIntentService(
            logger: FakeLogger(),
            pdfService: MockPDFService(),
          );
          final tempDir = await Directory.systemTemp.createTemp('test_lines');
          final textFile = File('${tempDir.path}/multiline.txt');
          const textContent = 'Line 1\nLine 2\r\nLine 3\rLine 4';
          await textFile.writeAsString(textContent);

          try {
            // Act (When)
            final content = await testService.extractContentFromFile(textFile);

            // Assert (Then)
            expect(content, equals(textContent));
            expect(content, contains('\n'));
          } finally {
            // Cleanup
            await tempDir.delete(recursive: true);
          }
        },
      );

      test(
        'Given file with mixed extensions (e.g., .tar.pdf), '
        'When extracting content, '
        'Then uses the last extension',
        () async {
          // Arrange (Given)
          final mockPdfService = MockPDFService(
            mockPdfText: 'Mixed extension PDF',
          );
          final testService = SharingIntentService(
            logger: FakeLogger(),
            pdfService: mockPdfService,
          );
          final tempDir = await Directory.systemTemp.createTemp('test_mixed');
          final pdfFile = File('${tempDir.path}/archive.tar.pdf');
          await pdfFile.writeAsString('dummy pdf content');

          try {
            // Act (When)
            final content = await testService.extractContentFromFile(pdfFile);

            // Assert (Then)
            expect(content, contains('Mixed extension PDF'));
          } finally {
            // Cleanup
            await tempDir.delete(recursive: true);
          }
        },
      );
    });

    group('Dispose', () {
      test(
        'Given service is initialized, When dispose is called, '
        'Then cleans up resources without errors',
        () {
          // Arrange (Given)
          final testService = SharingIntentService(
            logger: FakeLogger(),
            pdfService: MockPDFService(),
          );

          // Act (When) & Assert (Then)
          expect(testService.dispose, returnsNormally);
        },
      );

      test(
        'Given service is disposed, When dispose is called again, '
        'Then does not throw error (idempotent)',
        () {
          // Arrange (Given)
          final testService = SharingIntentService(
            logger: FakeLogger(),
            pdfService: MockPDFService(),
          )..dispose();

          // Act (When) & Assert (Then)
          expect(testService.dispose, returnsNormally);
        },
      );
    });
  });
}
