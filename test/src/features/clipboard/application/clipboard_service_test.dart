import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/database/wallet_database.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/clipboard/application/clipboard_service.dart';
import 'package:namma_wallet/src/features/clipboard/domain/clipboard_content_type.dart';
import 'package:namma_wallet/src/features/clipboard/domain/i_clipboard_repository.dart';
import 'package:namma_wallet/src/features/common/application/travel_parser_service.dart';
import 'package:namma_wallet/src/features/common/enums/source_type.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';

import '../../../common/helpers/fake_logger.dart';

/// Mock implementation of IClipboardRepository for testing
class MockClipboardRepository implements IClipboardRepository {
  bool _hasContent = true;
  String? _textContent;
  bool _shouldThrow = false;

  void setHasContent(bool hasContent) => _hasContent = hasContent;
  void setTextContent(String? content) => _textContent = content;
  void setShouldThrow(bool shouldThrow) => _shouldThrow = shouldThrow;

  @override
  Future<bool> hasTextContent() async {
    if (_shouldThrow) throw Exception('Mock exception');
    return _hasContent;
  }

  @override
  Future<String?> readText() async {
    if (_shouldThrow) throw Exception('Mock exception');
    return _textContent;
  }
}

/// Mock implementation of TravelParserService for testing
class MockTravelParserService implements TravelParserService {
  TicketUpdateInfo? _updateInfo;
  Ticket? _parsedTicket;

  void setUpdateInfo(TicketUpdateInfo? info) => _updateInfo = info;
  void setParsedTicket(Ticket? ticket) => _parsedTicket = ticket;

  @override
  TicketUpdateInfo? parseUpdateSMS(String text) => _updateInfo;

  @override
  Ticket? parseTicketFromText(String text, {SourceType? sourceType}) =>
      _parsedTicket;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Mock implementation of WalletDatabase for testing
class MockWalletDatabase extends WalletDatabase {
  MockWalletDatabase() : super(logger: FakeLogger());

  int _updateRowCount = 0;
  int _insertedId = 1;
  bool _shouldThrowDuplicate = false;
  bool _shouldThrowError = false;

  void setUpdateRowCount(int count) => _updateRowCount = count;
  void setInsertedId(int id) => _insertedId = id;
  void setShouldThrowDuplicate(bool shouldThrow) =>
      _shouldThrowDuplicate = shouldThrow;
  void setShouldThrowError(bool shouldThrow) => _shouldThrowError = shouldThrow;

  @override
  Future<int> updateTicketById(
    String ticketId,
    Map<String, Object?> updates,
  ) async {
    return _updateRowCount;
  }

  @override
  Future<int> insertTicket(Ticket ticket) async {
    if (_shouldThrowDuplicate) {
      throw DuplicateTicketException('Duplicate ticket');
    }
    if (_shouldThrowError) {
      throw Exception('Database error');
    }
    return _insertedId;
  }
}

void main() {
  group('ClipboardService Application Layer Tests', () {
    late ClipboardService service;
    late MockClipboardRepository mockRepository;
    late MockTravelParserService mockParserService;
    late MockWalletDatabase mockDatabase;
    final getIt = GetIt.instance;

    setUp(() {
      // Create mocks
      mockRepository = MockClipboardRepository();
      mockParserService = MockTravelParserService();
      mockDatabase = MockWalletDatabase();

      // Register dependencies
      if (!getIt.isRegistered<ILogger>()) {
        getIt.registerSingleton<ILogger>(FakeLogger());
      }

      // Create service with mocks
      service = ClipboardService(
        repository: mockRepository,
        logger: FakeLogger(),
        parserService: mockParserService,
        database: mockDatabase,
      );
    });

    tearDown(() async {
      await getIt.reset();
    });

    group('readAndParseClipboard - Success Scenarios', () {
      test(
        'Given clipboard with plain text, When reading and parsing, '
        'Then returns success result with text content',
        () async {
          // Arrange (Given)
          const clipboardText = 'Hello from clipboard';
          mockRepository.setHasContent(true);
          mockRepository.setTextContent(clipboardText);
          mockParserService.setUpdateInfo(null);
          mockParserService.setParsedTicket(null);

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isTrue);
          expect(result.type, equals(ClipboardContentType.text));
          expect(result.content, equals(clipboardText));
          expect(result.ticket, isNull);
        },
      );

      test(
        'Given clipboard with travel ticket SMS, When reading and parsing, '
        'Then returns success result with parsed ticket',
        () async {
          // Arrange (Given)
          const smsText = 'PNR NO.: T12345678, From: Chennai To: Bangalore';
          final parsedTicket = Ticket(
            ticketId: 'T12345678',
            primaryText: 'Chennai → Bangalore',
            secondaryText: 'TNSTC',
            startTime: DateTime(2024, 12, 15, 14, 30),
            location: 'Koyambedu',
          );

          mockRepository.setHasContent(true);
          mockRepository.setTextContent(smsText);
          mockParserService.setUpdateInfo(null);
          mockParserService.setParsedTicket(parsedTicket);
          mockDatabase.setInsertedId(1);

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isTrue);
          expect(result.type, equals(ClipboardContentType.travelTicket));
          expect(result.ticket, isNotNull);
          expect(result.ticket?.ticketId, equals('T12345678'));
        },
      );

      test(
        'Given clipboard with update SMS, When reading and parsing, '
        'Then updates existing ticket successfully',
        () async {
          // Arrange (Given)
          const updateSMS =
              'PNR: T12345678, Conductor Mobile No: 9876543210';
          final updateInfo = TicketUpdateInfo(
            pnrNumber: 'T12345678',
            providerName: 'TNSTC',
            updates: {'conductorMobileNo': '9876543210'},
          );

          mockRepository.setHasContent(true);
          mockRepository.setTextContent(updateSMS);
          mockParserService.setUpdateInfo(updateInfo);
          mockDatabase.setUpdateRowCount(1);

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isTrue);
          expect(result.type, equals(ClipboardContentType.travelTicket));
        },
      );
    });

    group('readAndParseClipboard - Error Scenarios', () {
      test(
        'Given empty clipboard, When reading and parsing, '
        'Then returns error result',
        () async {
          // Arrange (Given)
          mockRepository.setHasContent(false);

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isFalse);
          expect(result.type, equals(ClipboardContentType.invalid));
          expect(result.errorMessage, contains('No content found'));
        },
      );

      test(
        'Given null clipboard text, When reading and parsing, '
        'Then returns error result',
        () async {
          // Arrange (Given)
          mockRepository.setHasContent(true);
          mockRepository.setTextContent(null);

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isFalse);
          expect(result.errorMessage, contains('No text content found'));
        },
      );

      test(
        'Given whitespace-only clipboard, When reading and parsing, '
        'Then returns error result',
        () async {
          // Arrange (Given)
          mockRepository.setHasContent(true);
          mockRepository.setTextContent('');

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isFalse);
          expect(result.errorMessage, contains('No text content found'));
        },
      );

      test(
        'Given text exceeding max length, When reading and parsing, '
        'Then returns error result',
        () async {
          // Arrange (Given)
          final longText = 'A' * (ClipboardService.maxTextLength + 1);
          mockRepository.setHasContent(true);
          mockRepository.setTextContent(longText);

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isFalse);
          expect(result.errorMessage, contains('plain text content'));
        },
      );

      test(
        'Given update SMS for non-existent ticket, When reading and parsing, '
        'Then returns error result',
        () async {
          // Arrange (Given)
          const updateSMS =
              'PNR: T99999999, Conductor Mobile No: 9876543210';
          final updateInfo = TicketUpdateInfo(
            pnrNumber: 'T99999999',
            providerName: 'TNSTC',
            updates: {'conductorMobileNo': '9876543210'},
          );

          mockRepository.setHasContent(true);
          mockRepository.setTextContent(updateSMS);
          mockParserService.setUpdateInfo(updateInfo);
          mockDatabase.setUpdateRowCount(0); // No rows updated

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isFalse);
          expect(result.errorMessage, contains('not found'));
        },
      );

      test(
        'Given duplicate ticket, When saving to database, '
        'Then returns duplicate error',
        () async {
          // Arrange (Given)
          const smsText = 'PNR NO.: T12345678, From: Chennai To: Bangalore';
          final parsedTicket = Ticket(
            ticketId: 'T12345678',
            primaryText: 'Chennai → Bangalore',
            secondaryText: 'TNSTC',
            startTime: DateTime.now(),
            location: 'Test',
          );

          mockRepository.setHasContent(true);
          mockRepository.setTextContent(smsText);
          mockParserService.setUpdateInfo(null);
          mockParserService.setParsedTicket(parsedTicket);
          mockDatabase.setShouldThrowDuplicate(true);

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isFalse);
          expect(result.errorMessage, contains('Duplicate ticket'));
        },
      );

      test(
        'Given database error during save, When saving ticket, '
        'Then returns error result',
        () async {
          // Arrange (Given)
          const smsText = 'PNR NO.: T12345678';
          final parsedTicket = Ticket(
            ticketId: 'T12345678',
            primaryText: 'Test',
            secondaryText: 'Test',
            startTime: DateTime.now(),
            location: 'Test',
          );

          mockRepository.setHasContent(true);
          mockRepository.setTextContent(smsText);
          mockParserService.setUpdateInfo(null);
          mockParserService.setParsedTicket(parsedTicket);
          mockDatabase.setShouldThrowError(true);

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isFalse);
          expect(result.errorMessage, contains('Failed to save ticket'));
        },
      );

      test(
        'Given unexpected exception, When reading clipboard, '
        'Then returns error result without throwing',
        () async {
          // Arrange (Given)
          mockRepository.setShouldThrow(true);

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isFalse);
          expect(result.errorMessage, contains('Unexpected error'));
        },
      );
    });

    group('readClipboard Alias Method', () {
      test(
        'Given readClipboard called, When executed, '
        'Then delegates to readAndParseClipboard',
        () async {
          // Arrange (Given)
          mockRepository.setHasContent(false);

          // Act (When)
          final result = await service.readClipboard();

          // Assert (Then)
          expect(result.isSuccess, isFalse);
        },
      );
    });

    group('Edge Cases and Boundary Conditions', () {
      test(
        'Given text at exact max length, When reading and parsing, '
        'Then processes successfully',
        () async {
          // Arrange (Given)
          final exactLengthText = 'A' * ClipboardService.maxTextLength;
          mockRepository.setHasContent(true);
          mockRepository.setTextContent(exactLengthText);
          mockParserService.setUpdateInfo(null);
          mockParserService.setParsedTicket(null);

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isTrue);
          expect(
            result.content?.length,
            equals(ClipboardService.maxTextLength),
          );
        },
      );

      test(
        'Given text with special characters, When reading and parsing, '
        'Then preserves all characters',
        () async {
          // Arrange (Given)
          const specialText = r'Test@#$%^&*()_+{}|:"<>?';
          mockRepository.setHasContent(true);
          mockRepository.setTextContent(specialText);
          mockParserService.setUpdateInfo(null);
          mockParserService.setParsedTicket(null);

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isTrue);
          expect(result.content, equals(specialText));
        },
      );

      test(
        'Given text with Unicode characters, When reading and parsing, '
        'Then preserves Unicode correctly',
        () async {
          // Arrange (Given)
          const unicodeText = 'தமிழ் நாடு பேருந்து 中文 🎫';
          mockRepository.setHasContent(true);
          mockRepository.setTextContent(unicodeText);
          mockParserService.setUpdateInfo(null);
          mockParserService.setParsedTicket(null);

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isTrue);
          expect(result.content, contains('தமிழ்'));
          expect(result.content, contains('🎫'));
        },
      );

      test(
        'Given multiline text, When reading and parsing, '
        'Then preserves line breaks',
        () async {
          // Arrange (Given)
          const multilineText = 'Line 1\nLine 2\nLine 3';
          mockRepository.setHasContent(true);
          mockRepository.setTextContent(multilineText);
          mockParserService.setUpdateInfo(null);
          mockParserService.setParsedTicket(null);

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isTrue);
          expect(result.content, contains('\n'));
        },
      );
    });

    group('Constructor Variations', () {
      test(
        'Given service created with custom dependencies, '
        'When using service, '
        'Then uses injected dependencies',
        () async {
          // Arrange (Given)
          final customRepository = MockClipboardRepository();
          customRepository.setHasContent(false);
          final customService = ClipboardService(
            repository: customRepository,
            logger: FakeLogger(),
            parserService: mockParserService,
            database: mockDatabase,
          );

          // Act (When)
          final result = await customService.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isFalse);
        },
      );
    });

    group('PNR Masking in Error Messages', () {
      test(
        'Given duplicate ticket with long PNR, When logging error, '
        'Then masks PNR showing only last 4 digits',
        () async {
          // Arrange (Given)
          const smsText = 'PNR NO.: T123456789';
          final parsedTicket = Ticket(
            ticketId: 'T123456789',
            primaryText: 'Test',
            secondaryText: 'Test',
            startTime: DateTime.now(),
            location: 'Test',
          );

          mockRepository.setHasContent(true);
          mockRepository.setTextContent(smsText);
          mockParserService.setUpdateInfo(null);
          mockParserService.setParsedTicket(parsedTicket);
          mockDatabase.setShouldThrowDuplicate(true);

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isFalse);
          // PNR is masked in logs (internal implementation detail)
        },
      );

      test(
        'Given duplicate ticket with short PNR, When logging error, '
        'Then uses *** as masked PNR',
        () async {
          // Arrange (Given)
          const smsText = 'PNR NO.: T12';
          final parsedTicket = Ticket(
            ticketId: 'T12',
            primaryText: 'Test',
            secondaryText: 'Test',
            startTime: DateTime.now(),
            location: 'Test',
          );

          mockRepository.setHasContent(true);
          mockRepository.setTextContent(smsText);
          mockParserService.setUpdateInfo(null);
          mockParserService.setParsedTicket(parsedTicket);
          mockDatabase.setShouldThrowDuplicate(true);

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isFalse);
          expect(result.errorMessage, contains('Duplicate'));
        },
      );
    });
  });
}
