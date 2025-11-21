import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/common/application/travel_parser_service.dart';
import 'package:namma_wallet/src/features/home/domain/extras_model.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';
import 'package:namma_wallet/src/features/share/application/shared_content_processor.dart';
import 'package:namma_wallet/src/features/share/domain/shared_content_result.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_pdf_parser.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_sms_parser.dart';

import '../../../helpers/fake_logger.dart';
import '../../../helpers/mock_sms_service.dart';
import '../../../helpers/mock_ticket_dao.dart';
import '../../../helpers/mock_travel_parser_service.dart';

void main() {
  group('SharedContentProcessor', () {
    final getIt = GetIt.instance;

    setUp(() {
      // Arrange - Set up mocked dependencies in a new scope
      getIt..pushNewScope()
      ..registerSingleton<ILogger>(FakeLogger())
      ..registerSingleton<TNSTCSMSParser>(TNSTCSMSParser())
      ..registerSingleton<TNSTCPDFParser>(TNSTCPDFParser());
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
          final mockTicket = Ticket(
            ticketId: 'T12345678',
            primaryText: 'Chennai → Bangalore',
            secondaryText: 'SETC - Trip123',
            startTime: DateTime(2024, 12, 15, 14, 30),
            location: 'Chennai',
            extras: [
              ExtrasModel(title: 'PNR Number', value: 'T12345678'),
              ExtrasModel(title: 'From', value: 'Chennai'),
              ExtrasModel(title: 'To', value: 'Bangalore'),
              ExtrasModel(title: 'Fare', value: '₹500.00'),
            ],
          );

          final processor = SharedContentProcessor(
            logger: FakeLogger(),
            travelParser: MockTravelParserService(),
            smsService: MockSMSService(mockTicket: mockTicket),
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
          expect(ticketResult.from, contains('Chennai'));
          expect(ticketResult.to, contains('Bangalore'));
        },
      );

      test(
        'Given empty content, When processing content, '
        'Then returns TicketCreatedResult with defaults',
        () async {
          // Arrange (Given)
          final processor = SharedContentProcessor(
            logger: FakeLogger(),
            travelParser: MockTravelParserService(),
            smsService: MockSMSService(),
            ticketDao: MockTicketDAO(),
          );

          // Act (When)
          final result = await processor.processContent(
            '',
            SharedContentType.sms,
          );

          // Assert (Then)
          expect(result, isA<TicketCreatedResult>());
        },
      );

      test(
        'Given malformed content, When processing content, '
        'Then handles gracefully and returns result',
        () async {
          // Arrange (Given)
          final processor = SharedContentProcessor(
            logger: FakeLogger(),
            travelParser: MockTravelParserService(),
            smsService: MockSMSService(),
            ticketDao: MockTicketDAO(),
          );

          const malformedContent = 'Random text without structure';

          // Act (When)
          final result = await processor.processContent(
            malformedContent,
            SharedContentType.sms,
          );

          // Assert (Then)
          expect(result, isA<TicketCreatedResult>());
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

          final processor = SharedContentProcessor(
            logger: FakeLogger(),
            travelParser: MockTravelParserService(
              mockUpdateInfo: mockUpdateInfo,
            ),
            smsService: MockSMSService(),
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

          final processor = SharedContentProcessor(
            logger: FakeLogger(),
            travelParser: MockTravelParserService(
              mockUpdateInfo: mockUpdateInfo,
            ),
            smsService: MockSMSService(),
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

          final processor = SharedContentProcessor(
            logger: FakeLogger(),
            travelParser: MockTravelParserService(
              mockUpdateInfo: mockUpdateInfo,
            ),
            smsService: MockSMSService(),
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

          final processor = SharedContentProcessor(
            logger: FakeLogger(),
            travelParser: MockTravelParserService(
              mockUpdateInfo: mockUpdateInfo,
            ),
            smsService: MockSMSService(),
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
        'Given empty content, When processing content, '
        'Then handles gracefully',
        () async {
          // Arrange (Given)
          final processor = SharedContentProcessor(
            logger: FakeLogger(),
            travelParser: MockTravelParserService(),
            smsService: MockSMSService(),
            ticketDao: MockTicketDAO(),
          );

          // Act (When)
          final result = await processor.processContent(
            '',
            SharedContentType.sms,
          );

          // Assert (Then)
          expect(result, isNotNull);
        },
      );

      test(
        'Given very long content, When processing content, '
        'Then processes without errors',
        () async {
          // Arrange (Given)
          final processor = SharedContentProcessor(
            logger: FakeLogger(),
            travelParser: MockTravelParserService(),
            smsService: MockSMSService(),
            ticketDao: MockTicketDAO(),
          );

          final longContent = 'A' * 100000;

          // Act (When)
          final result = await processor.processContent(
            longContent,
            SharedContentType.sms,
          );

          // Assert (Then)
          expect(result, isNotNull);
        },
      );
      test(
        'Given parsed ticket has missing ID, When processing content, '
        'Then returns ProcessingErrorResult',
        () async {
          // Arrange (Given)
          final mockTicket = Ticket(
            primaryText: 'Test',
            secondaryText: 'Test',
            startTime: DateTime.now(),
            location: 'Test',
          );

          final processor = SharedContentProcessor(
            logger: FakeLogger(),
            travelParser: MockTravelParserService(),
            smsService: MockSMSService(mockTicket: mockTicket),
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
          final processor = SharedContentProcessor(
            logger: FakeLogger(),
            travelParser: MockTravelParserService(),
            smsService: MockSMSService(),
            ticketDao: mockDao,
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
            logger: FakeLogger(),
            travelParser: MockTravelParserService(
              mockUpdateInfo: TicketUpdateInfo(
                pnrNumber: 'T12345678',
                providerName: 'TNSTC',
                updates: {'conductorContact': '9876543210'},
              ),
            ),
            smsService: MockSMSService(),
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
          final processor1 = SharedContentProcessor(
            logger: FakeLogger(),
            travelParser: MockTravelParserService(),
            smsService: MockSMSService(
              mockTicket: Ticket(
                ticketId: 'T11111111',
                primaryText: 'Chennai → Bangalore',
                secondaryText: 'SETC',
                startTime: DateTime.now(),
                location: 'Chennai',
                extras: [
                  ExtrasModel(title: 'PNR Number', value: 'T11111111'),
                  ExtrasModel(title: 'From', value: 'Chennai'),
                  ExtrasModel(title: 'To', value: 'Bangalore'),
                ],
              ),
            ),
            ticketDao: MockTicketDAO(),
          );

          final processor2 = SharedContentProcessor(
            logger: FakeLogger(),
            travelParser: MockTravelParserService(),
            smsService: MockSMSService(
              mockTicket: Ticket(
                ticketId: 'T22222222',
                primaryText: 'Mumbai → Delhi',
                secondaryText: 'IRCTC',
                startTime: DateTime.now(),
                location: 'Mumbai',
                extras: [
                  ExtrasModel(title: 'PNR Number', value: 'T22222222'),
                  ExtrasModel(title: 'From', value: 'Mumbai'),
                  ExtrasModel(title: 'To', value: 'Delhi'),
                ],
              ),
            ),
            ticketDao: MockTicketDAO(),
          );

          // Act (When) - Process concurrently
          final results = await Future.wait([
            processor1.processContent('SMS 1', SharedContentType.sms),
            processor2.processContent('SMS 2', SharedContentType.sms),
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
