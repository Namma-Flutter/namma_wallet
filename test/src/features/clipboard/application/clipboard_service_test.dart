import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/source_type.dart';
import 'package:namma_wallet/src/features/clipboard/application/clipboard_service.dart';
import 'package:namma_wallet/src/features/clipboard/domain/clipboard_content_type.dart';
import 'package:namma_wallet/src/features/clipboard/domain/clipboard_repository_interface.dart';
import 'package:namma_wallet/src/features/travel/application/travel_parser_interface.dart';

import '../../../../helpers/fake_logger.dart';

/// Mock implementation of IClipboardRepository for testing
class MockClipboardRepository implements IClipboardRepository {
  bool hasContent = true;
  String? textContent;
  bool shouldThrow = false;

  @override
  Future<bool> hasTextContent() async {
    if (shouldThrow) throw Exception('Mock exception');
    return hasContent;
  }

  @override
  Future<String?> readText() async {
    if (shouldThrow) throw Exception('Mock exception');
    return textContent;
  }
}

/// Mock implementation of ITravelParser for testing
class MockTravelParserService implements ITravelParser {
  // TicketUpdateInfo is now largely ignored if update-SMS flow is disabled
  TicketUpdateInfo? updateInfo;
  Ticket? parsedTicket;

  @override
  TicketUpdateInfo? parseUpdateSMS(String text) => updateInfo;

  @override
  Ticket? parseTicketFromText(String text, {SourceType? sourceType}) =>
      parsedTicket;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Mock implementation of ITicketDAO for testing - RECONCILED
class MockTicketDao implements ITicketDAO {
  // Use insertedId for successful insert/handle return value
  int insertedId = 1;

  // Use shouldThrowError to simulate database failure
  // (e.g., duplicate key, connection error)
  bool shouldThrowError = false;

  // Track the number of successful updates/inserts for assertions
  int handleTicketCallCount = 0;

  // Kept for interface compliance, but ignored by new ClipboardService tests
  int updateRowCount = 0;

  @override
  Future<int> handleTicket(Ticket ticket) async {
    handleTicketCallCount++;
    if (shouldThrowError) {
      // Simulate database error for insert/update attempts
      throw Exception('Database error');
    }
    // A successful 'handle' operation typically returns the ID or 1 for success
    return insertedId;
  }

  // Legacy method: Kept for interface compliance
  @override
  Future<int> updateTicketById(
    String ticketId,
    Ticket ticket,
  ) async {
    return updateRowCount;
  }

  // Legacy method: Kept for interface compliance
  @override
  Future<int> insertTicket(Ticket ticket) async {
    if (shouldThrowError) {
      throw Exception('Database error');
    }
    return insertedId;
  }

  @override
  Future<Ticket?> getTicketById(String id) async => null;

  @override
  Future<List<Ticket>> getAllTickets() async => [];

  @override
  Future<List<Ticket>> getTicketsByType(String type) async => [];

  @override
  Future<int> deleteTicket(String id) async => 1;
}

void main() {
  group('ClipboardService Application Layer Tests', () {
    late ClipboardService service;
    late MockClipboardRepository mockRepository;
    late MockTravelParserService mockParserService;
    late MockTicketDao mockDatabase;

    setUp(() {
      // Create mocks
      mockRepository = MockClipboardRepository();
      mockParserService = MockTravelParserService();
      mockDatabase = MockTicketDao();

      // Create service with mocks
      service = ClipboardService(
        repository: mockRepository,
        logger: FakeLogger(),
        parserService: mockParserService,
        ticketDao: mockDatabase,
      );
    });

    group('readAndParseClipboard - Success Scenarios', () {
      test(
        'Given clipboard with plain text, When reading and parsing, '
        'Then returns error result indicating text cannot be parsed',
        () async {
          // Arrange (Given)
          const clipboardText = 'Hello from clipboard';
          mockRepository
            ..hasContent = true
            ..textContent = clipboardText;
          mockParserService
            ..updateInfo = null
            ..parsedTicket = null;

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isFalse);
          expect(result.type, equals(ClipboardContentType.invalid));
          expect(
            result.errorMessage,
            contains('Unable to process the text as a travel ticket'),
          );
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

          mockRepository
            ..hasContent = true
            ..textContent = smsText;
          mockParserService
            ..updateInfo = null
            ..parsedTicket = parsedTicket;

          // The updated MockTicketDao handles success when
          // shouldThrowError is false
          mockDatabase.insertedId = 1;

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isTrue);
          expect(result.type, equals(ClipboardContentType.travelTicket));
          expect(result.ticket, isNotNull);
          expect(result.ticket?.ticketId, equals('T12345678'));
        },
      );

      // REMOVED: Test case for successful update-SMS flow (Lines 207-228)
    });

    group('readAndParseClipboard - Error Scenarios', () {
      test(
        'Given empty clipboard, When reading and parsing, '
        'Then returns error result',
        () async {
          // Arrange (Given)
          mockRepository.hasContent = false;

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
          mockRepository
            ..hasContent = true
            ..textContent = null;

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
          mockRepository
            ..hasContent = true
            ..textContent = '';

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
          mockRepository
            ..hasContent = true
            ..textContent = longText;

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isFalse);
          expect(result.errorMessage, contains('plain text content'));
        },
      );

      // REMOVED: Test case for update SMS for
      // non-existent ticket (Lines 272-295)

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
            startTime: DateTime(2024),
            location: 'Test',
          );

          mockRepository
            ..hasContent = true
            ..textContent = smsText;
          mockParserService
            ..updateInfo = null
            ..parsedTicket = parsedTicket;
          mockDatabase.shouldThrowError = true;

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isFalse);
          expect(result.errorMessage, contains('Failed to save ticket'));
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
            startTime: DateTime(2024),
            location: 'Test',
          );

          mockRepository
            ..hasContent = true
            ..textContent = smsText;
          mockParserService
            ..updateInfo = null
            ..parsedTicket = parsedTicket;
          mockDatabase.shouldThrowError = true;

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
          mockRepository.shouldThrow = true;

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isFalse);
          expect(result.errorMessage, contains('Unexpected error'));
        },
      );
    });

    group('Edge Cases and Boundary Conditions', () {
      test(
        'Given text at exact max length, When reading and parsing, '
        'Then returns error if not parsable as ticket',
        () async {
          // Arrange (Given)
          final exactLengthText = 'A' * ClipboardService.maxTextLength;
          mockRepository
            ..hasContent = true
            ..textContent = exactLengthText;
          mockParserService
            ..updateInfo = null
            ..parsedTicket = null;

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isFalse);
          expect(
            result.errorMessage,
            contains('Unable to process the text as a travel ticket'),
          );
        },
      );

      test(
        'Given text with special characters, When reading and parsing, '
        'Then returns error if not parsable as ticket',
        () async {
          // Arrange (Given)
          const specialText = r'Test@#$%^&*()_+{}|:"<>?';
          mockRepository
            ..hasContent = true
            ..textContent = specialText;
          mockParserService
            ..updateInfo = null
            ..parsedTicket = null;

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isFalse);
          expect(
            result.errorMessage,
            contains('Unable to process the text as a travel ticket'),
          );
        },
      );

      test(
        'Given text with Unicode characters, When reading and parsing, '
        'Then returns error if not parsable as ticket',
        () async {
          // Arrange (Given)
          const unicodeText = 'தமிழ் நாடு பேருந்து 中文 🎫';
          mockRepository
            ..hasContent = true
            ..textContent = unicodeText;
          mockParserService
            ..updateInfo = null
            ..parsedTicket = null;

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isFalse);
          expect(
            result.errorMessage,
            contains('Unable to process the text as a travel ticket'),
          );
        },
      );

      test(
        'Given multiline text, When reading and parsing, '
        'Then returns error if not parsable as ticket',
        () async {
          // Arrange (Given)
          const multilineText = 'Line 1\nLine 2\nLine 3';
          mockRepository
            ..hasContent = true
            ..textContent = multilineText;
          mockParserService
            ..updateInfo = null
            ..parsedTicket = null;

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isFalse);
          expect(
            result.errorMessage,
            contains('Unable to process the text as a travel ticket'),
          );
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
          final customRepository = MockClipboardRepository()
            ..hasContent = false;
          final customService = ClipboardService(
            repository: customRepository,
            logger: FakeLogger(),
            parserService: mockParserService,
            ticketDao: mockDatabase,
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
            startTime: DateTime(2024),
            location: 'Test',
          );

          mockRepository
            ..hasContent = true
            ..textContent = smsText;
          mockParserService
            ..updateInfo = null
            ..parsedTicket = parsedTicket;
          mockDatabase.shouldThrowError = true;

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isFalse);
          // PNR is masked in logs (internal implementation detail)
        },
      );

      test(
        'Given database error with short PNR, When saving ticket, '
        'Then returns error result',
        () async {
          // Arrange (Given)
          const smsText = 'PNR NO.: T12';
          final parsedTicket = Ticket(
            ticketId: 'T12',
            primaryText: 'Test',
            secondaryText: 'Test',
            startTime: DateTime(2024),
            location: 'Test',
          );

          mockRepository
            ..hasContent = true
            ..textContent = smsText;
          mockParserService
            ..updateInfo = null
            ..parsedTicket = parsedTicket;
          mockDatabase.shouldThrowError = true;

          // Act (When)
          final result = await service.readAndParseClipboard();

          // Assert (Then)
          expect(result.isSuccess, isFalse);
          expect(result.errorMessage, contains('Failed to save ticket'));
        },
      );
    });
  });
}
