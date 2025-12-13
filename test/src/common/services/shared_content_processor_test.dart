import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/pdf/station_pdf_parser.dart';
import 'package:namma_wallet/src/features/receive/application/shared_content_processor.dart';
import 'package:namma_wallet/src/features/receive/domain/shared_content_result.dart';
import 'package:namma_wallet/src/features/receive/domain/shared_content_type.dart';
import 'package:namma_wallet/src/features/travel/application/travel_parser_interface.dart';

import '../../../helpers/fake_logger.dart';
import '../../../helpers/mock_ticket_dao.dart';
import '../../../helpers/mock_travel_parser_service.dart';

void main() {
  group('SharedContentProcessor', () {
    final getIt = GetIt.instance;

    setUp(() {
      // Arrange - Set up mocked dependencies in a new scope
      final logger = FakeLogger();
      getIt
        ..pushNewScope()
        ..registerSingleton<ILogger>(logger);
    });

    tearDown(() async {
      // Cleanup - Pop the scope to remove test-specific dependencies
      await getIt.popScope();
    });

    group('processContent - New Ticket Creation', () {
      test(
        'Given valid SMS content, When processing content, '
        'Then returns TicketCreatedResult with ticket details',
        () async {
          // Arrange (Given)
          final logger = getIt<ILogger>();
          final stationPdfParser = GetIt.I<StationPdfParser>();
          final processor = SharedContentProcessor(
            logger: logger,
            travelParser: MockTravelParserService(
              logger: logger,
              stationPdfParser: stationPdfParser,
            ),
            ticketDao: MockTicketDAO(),
          );

          const smsContent = '''
            Corporation : SETC, From : CHENNAI To BANGALORE
            PNR NO. : T12345678, Trip Code : Trip123
            Journey Date : 15/12/2024, Time : 14:30
          ''';

          // Act (When)
          final result = await processor.processContent(
            smsContent,
            SharedContentType.sms,
          );

          // Assert (Then)
          expect(result, isA<TicketCreatedResult>());
          final ticketResult = result as TicketCreatedResult;
          expect(ticketResult.pnrNumber, equals('T12345678'));
          expect(ticketResult.from, contains('CHENNAI'));
          expect(ticketResult.to, contains('BANGALORE'));
        },
      );

      test(
        'Given empty content, When processing content, '
        'Then returns ProcessingErrorResult',
        () async {
          // Arrange (Given)
          final logger = getIt<ILogger>();
          final stationPdfParser = GetIt.I<StationPdfParser>();
          final processor = SharedContentProcessor(
            logger: logger,
            travelParser: MockTravelParserService(
              logger: logger,
              stationPdfParser: stationPdfParser,
            ),
            ticketDao: MockTicketDAO(),
          );

          // Act (When)
          final result = await processor.processContent(
            '',
            SharedContentType.sms,
          );

          // Assert (Then)
          expect(result, isA<ProcessingErrorResult>());
          expect(
            (result as ProcessingErrorResult).error,
            contains('No supported ticket format found'),
          );
        },
      );

      test(
        'Given malformed content, When processing content, '
        'Then handles gracefully and returns result',
        () async {
          // Arrange (Given)
          final logger = getIt<ILogger>();
          final stationPdfParser = GetIt.I<StationPdfParser>();
          final processor = SharedContentProcessor(
            logger: logger,
            travelParser: MockTravelParserService(
              logger: logger,
              stationPdfParser: stationPdfParser,
            ),
            ticketDao: MockTicketDAO(),
          );

          const malformedContent = 'Random text without structure';

          // Act (When)
          final result = await processor.processContent(
            malformedContent,
            SharedContentType.sms,
          );

          // Assert (Then)
          expect(result, isA<ProcessingErrorResult>());
          expect(
            (result as ProcessingErrorResult).error,
            contains('No supported ticket format found'),
          );
        },
      );
    });

    group('processContent - Ticket Updates', () {
      test(
        'Given update SMS with conductor details, '
        'When processing content and ticket exists, '
        'Then returns TicketUpdatedResult',
        () async {
          // Arrange (Given)
          final mockUpdateInfo = TicketUpdateInfo(
            pnrNumber: 'T12345678',
            providerName: 'TNSTC',
            updates: {
              'conductorContact': '9876543210',
              'busNumber': 'TN01AB1234',
            },
          );

          final logger = getIt<ILogger>();
          final stationPdfParser = GetIt.I<StationPdfParser>();
          final processor = SharedContentProcessor(
            logger: logger,
            travelParser: MockTravelParserService(
              logger: logger,
              stationPdfParser: stationPdfParser,
              mockUpdateInfo: mockUpdateInfo,
            ),
            ticketDao: MockTicketDAO(),
          );

          const updateSms = '''
            PNR NO. : T12345678, Journey Date : 15/12/2024,
            Conductor Mobile No: 9876543210, Vehicle No:TN01AB1234
          ''';

          // Act (When)
          final result = await processor.processContent(
            updateSms,
            SharedContentType.sms,
          );

          // Assert (Then)
          expect(result, isA<TicketUpdatedResult>());
          final updateResult = result as TicketUpdatedResult;
          expect(updateResult.pnrNumber, equals('T12345678'));
          expect(updateResult.updateType, equals('Conductor Details'));
        },
      );

      test(
        'Given update SMS but ticket not found, '
        'When processing content, '
        'Then returns TicketNotFoundResult',
        () async {
          // Arrange (Given)
          final mockUpdateInfo = TicketUpdateInfo(
            pnrNumber: 'T99999999',
            providerName: 'TNSTC',
            updates: {'conductorContact': '9876543210'},
          );

          final logger = getIt<ILogger>();
          final stationPdfParser = GetIt.I<StationPdfParser>();
          final processor = SharedContentProcessor(
            logger: logger,
            travelParser: MockTravelParserService(
              logger: logger,
              stationPdfParser: stationPdfParser,
              mockUpdateInfo: mockUpdateInfo,
            ),
            ticketDao: MockTicketDAO(updateReturnCount: 0),
          );

          const updateSms = '''
            PNR NO. : T99999999,
            Conductor Mobile No: 9876543210
          ''';

          // Act (When)
          final result = await processor.processContent(
            updateSms,
            SharedContentType.sms,
          );

          // Assert (Then)
          expect(result, isA<TicketNotFoundResult>());
          final notFoundResult = result as TicketNotFoundResult;
          expect(notFoundResult.pnrNumber, equals('T99999999'));
        },
      );

      test(
        'Given update SMS with multiple updates, '
        'When processing content, '
        'Then all updates are passed to DAO',
        () async {
          // Arrange (Given)
          final mockDao = MockTicketDAO();
          final mockUpdateInfo = TicketUpdateInfo(
            pnrNumber: 'T12345678',
            providerName: 'TNSTC',
            updates: {
              'conductorContact': '9876543210',
              'busNumber': 'TN01AB1234',
              'platform': '5',
            },
          );

          final logger = getIt<ILogger>();
          final stationPdfParser = GetIt.I<StationPdfParser>();
          final processor = SharedContentProcessor(
            logger: logger,
            travelParser: MockTravelParserService(
              logger: logger,
              stationPdfParser: stationPdfParser,
              mockUpdateInfo: mockUpdateInfo,
            ),
            ticketDao: mockDao,
          );

          const updateSms = '''
            PNR NO. : T12345678,
            Conductor Mobile No: 9876543210,
            Vehicle No:TN01AB1234,
            Platform: 5
          ''';

          // Act (When)
          await processor.processContent(
            updateSms,
            SharedContentType.sms,
          );

          // Assert (Then)
          expect(mockDao.updateCalls.length, equals(1));
          expect(mockDao.updateCalls.first.key, equals('T12345678'));
          expect(
            mockDao.updateCalls.first.value,
            containsPair('conductorContact', '9876543210'),
          );
          expect(
            mockDao.updateCalls.first.value,
            containsPair('busNumber', 'TN01AB1234'),
          );
        },
      );
    });

    group('processContent - Error Handling', () {
      test(
        'Given DAO throws exception, When processing content, '
        'Then returns ProcessingErrorResult',
        () async {
          // Arrange (Given)
          final mockUpdateInfo = TicketUpdateInfo(
            pnrNumber: 'T12345678',
            providerName: 'TNSTC',
            updates: {'conductorContact': '9876543210'},
          );

          final logger = getIt<ILogger>();
          final stationPdfParser = GetIt.I<StationPdfParser>();
          final processor = SharedContentProcessor(
            logger: logger,
            travelParser: MockTravelParserService(
              logger: logger,
              stationPdfParser: stationPdfParser,
              mockUpdateInfo: mockUpdateInfo,
            ),
            ticketDao: MockTicketDAO(shouldThrowOnUpdate: true),
          );

          const updateSms = 'PNR NO. : T12345678, Conductor: 9876543210';

          // Act (When)
          final result = await processor.processContent(
            updateSms,
            SharedContentType.sms,
          );

          // Assert (Then)
          expect(result, isA<ProcessingErrorResult>());
          final errorResult = result as ProcessingErrorResult;
          expect(errorResult.message, contains('Failed to process'));
          expect(errorResult.error, contains('Mock update error'));
        },
      );

      test(
        'Given very long content, When processing content, '
        'Then processes without errors',
        () async {
          // Arrange (Given)
          final logger = getIt<ILogger>();
          final stationPdfParser = GetIt.I<StationPdfParser>();
          final processor = SharedContentProcessor(
            logger: logger,
            travelParser: MockTravelParserService(
              logger: logger,
              stationPdfParser: stationPdfParser,
            ),
            ticketDao: MockTicketDAO(),
          );

          final longContent = 'A' * 100000;

          // Act (When)
          final result = await processor.processContent(
            longContent,
            SharedContentType.sms,
          );

          // Assert (Then)
          expect(result, isA<ProcessingErrorResult>());
        },
      );
      test(
        'Given parsed ticket has missing ID, When processing content, '
        'Then returns ProcessingErrorResult',
        () async {
          // Arrange (Given)
          final logger = getIt<ILogger>();
          final stationPdfParser = GetIt.I<StationPdfParser>();
          final processor = SharedContentProcessor(
            logger: logger,
            travelParser: MockTravelParserService(
              logger: logger,
              stationPdfParser: stationPdfParser,
              // Return a ticket with null ticketId
              mockTicket: Ticket(
                primaryText: 'Test → Test',
                secondaryText: 'Test Bus',
                startTime: DateTime(2024),
                location: 'Test',
                type: TicketType.bus,
              ),
            ),
            ticketDao: MockTicketDAO(),
          );

          // Act (When)
          final result = await processor.processContent(
            'content',
            SharedContentType.sms,
          );

          // Assert (Then)
          expect(result, isA<ProcessingErrorResult>());
          expect(
            (result as ProcessingErrorResult).error,
            contains('Missing ticketId'),
          );
        },
      );
    });

    group('processContent - Result Types', () {
      test(
        'Given TicketCreatedResult, When checking fields, '
        'Then all required fields are present',
        () {
          // Arrange (Given)
          const result = TicketCreatedResult(
            pnrNumber: 'T12345678',
            from: 'Chennai',
            to: 'Bangalore',
            fare: '500.00',
            date: '2024-12-15',
          );

          // Assert (Then)
          expect(result.pnrNumber, equals('T12345678'));
          expect(result.from, equals('Chennai'));
          expect(result.to, equals('Bangalore'));
          expect(result.fare, equals('500.00'));
          expect(result.date, equals('2024-12-15'));
        },
      );

      test(
        'Given TicketUpdatedResult, When checking fields, '
        'Then all required fields are present',
        () {
          // Arrange (Given)
          const result = TicketUpdatedResult(
            pnrNumber: 'T12345678',
            updateType: 'Conductor Details',
          );

          // Assert (Then)
          expect(result.pnrNumber, equals('T12345678'));
          expect(result.updateType, equals('Conductor Details'));
        },
      );

      test(
        'Given ProcessingErrorResult, When checking fields, '
        'Then all required fields are present',
        () {
          // Arrange (Given)
          const result = ProcessingErrorResult(
            message: 'Error message',
            error: 'Error details',
          );

          // Assert (Then)
          expect(result.message, equals('Error message'));
          expect(result.error, equals('Error details'));
        },
      );

      test(
        'Given TicketNotFoundResult, When checking fields, '
        'Then all required fields are present',
        () {
          // Arrange (Given)
          const result = TicketNotFoundResult(
            pnrNumber: 'T12345678',
          );

          // Assert (Then)
          expect(result.pnrNumber, equals('T12345678'));
        },
      );

      test(
        'Given all result types, When checking inheritance, '
        'Then all extend SharedContentResult',
        () {
          // Arrange (Given) & Assert (Then)
          expect(
            const TicketCreatedResult(
              pnrNumber: '',
              from: '',
              to: '',
              fare: '',
              date: '',
            ),
            isA<SharedContentResult>(),
          );
          expect(
            const TicketUpdatedResult(pnrNumber: '', updateType: ''),
            isA<SharedContentResult>(),
          );
          expect(
            const ProcessingErrorResult(message: '', error: ''),
            isA<SharedContentResult>(),
          );
          expect(
            const TicketNotFoundResult(pnrNumber: ''),
            isA<SharedContentResult>(),
          );
        },
      );
    });

    group('processContent - Integration Scenarios', () {
      test(
        'Given sequential ticket creation and update, '
        'When processing both, '
        'Then both operations succeed',
        () async {
          // Arrange (Given)
          final mockDao = MockTicketDAO();
          final logger = getIt<ILogger>();
          final stationPdfParser = GetIt.I<StationPdfParser>();
          final processor = SharedContentProcessor(
            logger: logger,
            travelParser: MockTravelParserService(
              logger: logger,
              stationPdfParser: stationPdfParser,
            ),
            ticketDao: MockTicketDAO(),
          );

          const createSms = '''
            Corporation : SETC, From : CHENNAI To BANGALORE
            PNR NO. : T12345678
          ''';

          // Act (When) - Create ticket
          final createResult = await processor.processContent(
            createSms,
            SharedContentType.sms,
          );

          // Assert (Then)
          expect(createResult, isA<TicketCreatedResult>());

          // Arrange for update
          final updateProcessor = SharedContentProcessor(
            logger: logger,
            travelParser: MockTravelParserService(
              logger: logger,
              stationPdfParser: stationPdfParser,
              mockUpdateInfo: TicketUpdateInfo(
                pnrNumber: 'T12345678',
                providerName: 'TNSTC',
                updates: {'conductorContact': '9876543210'},
              ),
            ),
            ticketDao: mockDao,
          );

          const updateSms = 'PNR NO. : T12345678, Conductor: 9876543210';

          // Act (When) - Update ticket
          final updateResult = await updateProcessor.processContent(
            updateSms,
            SharedContentType.sms,
          );

          // Assert (Then)
          expect(updateResult, isA<TicketUpdatedResult>());
        },
      );

      test(
        'Given multiple processors working concurrently, '
        'When processing different content, '
        'Then each processor works independently',
        () async {
          // Arrange (Given)
          final logger = getIt<ILogger>();
          final stationPdfParser = GetIt.I<StationPdfParser>();
          final processor1 = SharedContentProcessor(
            logger: logger,
            travelParser: MockTravelParserService(
              logger: logger,
              stationPdfParser: stationPdfParser,
            ),
            ticketDao: MockTicketDAO(),
          );

          final processor2 = SharedContentProcessor(
            logger: logger,
            travelParser: MockTravelParserService(
              logger: logger,
              stationPdfParser: stationPdfParser,
            ),
            ticketDao: MockTicketDAO(),
          );

          // Act (When) - Process concurrently with proper PNR format
          final results = await Future.wait([
            processor1.processContent(
              'PNR NO: T11111111, From: Chennai To Bangalore',
              SharedContentType.sms,
            ),
            processor2.processContent(
              'PNR NO: T22222222, From: Mumbai To Pune',
              SharedContentType.sms,
            ),
          ]);

          // Assert (Then)
          expect(results.length, equals(2));
          expect(results[0], isA<TicketCreatedResult>());
          expect(results[1], isA<TicketCreatedResult>());

          final result1 = results[0] as TicketCreatedResult;
          final result2 = results[1] as TicketCreatedResult;

          expect(result1.pnrNumber, equals('T11111111'));
          expect(result2.pnrNumber, equals('T22222222'));
        },
      );
    });
  });
}
