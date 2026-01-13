import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/receive/application/sharing_intent_service.dart';
import 'package:namma_wallet/src/features/receive/domain/shared_content_type.dart';
import 'package:namma_wallet/src/features/receive/domain/sharing_intent_service_interface.dart';
import 'package:share_handler/share_handler.dart';

import '../../../../helpers/fake_logger.dart';
import '../../../../helpers/mock_pdf_service.dart';
import '../../../../helpers/mock_sharing_intent_provider.dart';

void main() {
  group('SharingIntentService', () {
    late ISharingIntentService service;
    late MockSharingIntentProvider mockProvider;
    late MockPDFService mockPdfService;
    late FakeLogger fakeLogger;

    setUp(() {
      mockProvider = MockSharingIntentProvider();
      mockPdfService = MockPDFService();
      fakeLogger = FakeLogger();

      service = SharingIntentService(
        logger: fakeLogger,
        pdfService: mockPdfService,
        sharingIntentProvider: mockProvider,
      );
    });

    tearDown(() async {
      await service.dispose();
      await mockProvider.dispose();
    });

    group('Initialization', () {
      test('should handle initial media when present', () async {
        final media = SharedMedia(content: 'test_path.txt');
        mockProvider.initialMedia = media;

        var contentReceived = false;
        await service.initialize(
          onContentReceived: (content, type) {
            contentReceived = true;
            expect(content, equals('test_path.txt'));
            expect(type, equals(SharedContentType.sms));
          },
          onError: (error) {
            fail('Should not report error');
          },
        );

        expect(contentReceived, isTrue);
      });

      test('should handle stream events', () async {
        mockProvider.initialMedia = null;

        var contentReceived = false;
        await service.initialize(
          onContentReceived: (content, type) {
            contentReceived = true;
            expect(content, equals('stream_path.txt'));
            expect(type, equals(SharedContentType.sms));
          },
          onError: (error) {
            fail('Should not report error');
          },
        );

        mockProvider.emitMedia(SharedMedia(content: 'stream_path.txt'));

        // Wait for stream to process
        await Future<void>.delayed(Duration.zero);
        expect(contentReceived, isTrue);
      });

      test('should handle stream errors', () async {
        mockProvider.initialMedia = null;
        var errorReported = false;
        await service.initialize(
          onContentReceived: (_, _) => fail('Should not receive content'),
          onError: (error) {
            errorReported = true;
          },
        );
        mockProvider.emitError(Exception('Test error'));
        await Future<void>.delayed(Duration.zero);
        expect(errorReported, isTrue);
      });
    });

    group('File Handling', () {
      test('should process PDF file correctly', () async {
        final tempDir = await Directory.systemTemp.createTemp('test_pdf');
        final pdfFile = File('${tempDir.path}/test.pdf');
        await pdfFile.writeAsString('dummy content');

        mockPdfService.mockPdfText = 'Extracted PDF Text';

        final media = SharedMedia(
          attachments: [
            SharedAttachment(
              path: pdfFile.path,
              type: SharedAttachmentType.file,
            ),
          ],
        );
        mockProvider.initialMedia = media;

        var contentReceived = false;
        await service.initialize(
          onContentReceived: (content, type) {
            contentReceived = true;
            expect(content, equals('Extracted PDF Text'));
            expect(type, equals(SharedContentType.pdf));
          },
          onError: (error) => fail('Should not error: $error'),
        );

        expect(contentReceived, isTrue);
        await tempDir.delete(recursive: true);
      });

      test('should process Text file correctly', () async {
        final tempDir = await Directory.systemTemp.createTemp('test_txt');
        final txtFile = File('${tempDir.path}/test.txt');
        await txtFile.writeAsString('File Content');

        final media = SharedMedia(
          attachments: [
            SharedAttachment(
              path: txtFile.path,
              type: SharedAttachmentType.file,
            ),
          ],
        );
        mockProvider.initialMedia = media;

        var contentReceived = false;
        await service.initialize(
          onContentReceived: (content, type) {
            contentReceived = true;
            expect(content, equals('File Content'));
            expect(type, equals(SharedContentType.sms));
          },
          onError: (error) => fail('Should not error: $error'),
        );

        expect(contentReceived, isTrue);
        await tempDir.delete(recursive: true);
      });

      test('should handle unsupported file types', () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'test_unsupported',
        );
        final imgFile = File('${tempDir.path}/image.jpg');
        await imgFile.writeAsString('image data');

        final media = SharedMedia(
          attachments: [
            SharedAttachment(
              path: imgFile.path,
              type: SharedAttachmentType.image,
            ),
          ],
        );
        mockProvider.initialMedia = media;

        var errorReported = false;
        await service.initialize(
          onContentReceived: (_, _) => fail('Should not receive content'),
          onError: (error) {
            errorReported = true;
            expect(error, contains('not supported'));
          },
        );

        expect(errorReported, isTrue);
        await tempDir.delete(recursive: true);
      });

      test('should handle text content (not a file path)', () async {
        final media = SharedMedia(content: 'Just some shared text');
        mockProvider.initialMedia = media;

        var contentReceived = false;
        await service.initialize(
          onContentReceived: (content, type) {
            contentReceived = true;
            expect(content, equals('Just some shared text'));
            expect(type, equals(SharedContentType.sms));
          },
          onError: (error) => fail('Should not error: $error'),
        );

        expect(contentReceived, isTrue);
      });
    });

    group('extractContentFromFile', () {
      test('should extract text from PDF', () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'test_pdf_extract',
        );
        final pdfFile = File('${tempDir.path}/test.pdf');
        await pdfFile.writeAsString('dummy');

        mockPdfService.mockPdfText = 'PDF Content';

        final content = await service.extractContentFromFile(
          XFile(pdfFile.path),
        );
        expect(content, equals('PDF Content'));

        await tempDir.delete(recursive: true);
      });

      test('should extract text from text file', () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'test_txt_extract',
        );
        final txtFile = File('${tempDir.path}/test.txt');
        await txtFile.writeAsString('Text Content');

        final content = await service.extractContentFromFile(
          XFile(txtFile.path),
        );
        expect(content, equals('Text Content'));

        await tempDir.delete(recursive: true);
      });

      test('should throw on unsupported file', () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'test_bad_extract',
        );
        final badFile = File('${tempDir.path}/test.jpg');
        await badFile.writeAsString('dummy');

        expect(
          () => service.extractContentFromFile(XFile(badFile.path)),
          throwsUnsupportedError,
        );

        await tempDir.delete(recursive: true);
      });
    });
  });
}
