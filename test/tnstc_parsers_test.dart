import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/common/application/travel_parser_service.dart';

import 'helpers/fake_logger.dart';

void main() {
  // Set up GetIt for tests
  setUp(() {
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<ILogger>()) {
      getIt.registerSingleton<ILogger>(FakeLogger());
    }
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  group('TNSTCBusParser Tests', () {
    late TNSTCBusParser parser;

    setUp(() {
      parser = TNSTCBusParser();
    });

    test('should parse standard SETC SMS correctly', () {
      const smsText =
          'TNSTC Corporation:SETC , PNR NO.:T63736642 , '
          'From:CHENNAI-PT DR. M.G.R. BS To KUMBAKONAM , '
          'Trip Code:2145CHEKUMAB , Journey Date:11/02/2025 , Time:22:35 , '
          'Seat No.:20,21, .Class:AC SLEEPER SEATER , '
          'Boarding at:KOTTIVAKKAM(RTO OFFICE) . For e-Ticket: Download from '
          'View Ticket. Please carry your photo ID during journey. T&C apply.';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);

      // Core text fields
      expect(
        ticket!.primaryText,
        equals('CHENNAI-PT DR. M.G.R. BS → KUMBAKONAM'),
      );
      expect(ticket.secondaryText, equals('SETC - 2145CHEKUMAB'));

      // Provider (from extras)
      final provider = ticket.extras
          ?.firstWhere((e) => e.title == 'Provider')
          .value;
      expect(provider, equals('SETC'));

      // PNR (from tag)
      final pnrTag = ticket.tags?.firstWhere((t) => t.icon == 'qr_code').value;
      expect(pnrTag, equals('T63736642'));

      // Trip code (from extras)
      final tripCode = ticket.extras
          ?.firstWhere((e) => e.title == 'Trip Code')
          .value;
      expect(tripCode, equals('2145CHEKUMAB'));

      // Journey Date (from extras)
      final journeyDateStr = ticket.extras
          ?.firstWhere((e) => e.title == 'Journey Date')
          .value;
      final journeyDate = DateTime.parse(
        journeyDateStr!
            .split('/')
            .reversed
            .join('-'), // Converts dd/MM/yyyy → yyyy-MM-dd
      );
      expect(journeyDate.day, equals(11));
      expect(journeyDate.month, equals(2));
      expect(journeyDate.year, equals(2025));

      // Departure Time (from tag)
      final departureTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'access_time')
          .value;
      expect(departureTag, equals('22:35'));

      // Seat numbers (from tag)
      final seatTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'event_seat')
          .value;
      expect(seatTag, equals('20,21')); // cleans trailing comma

      // Split and verify seat count
      final seatList = seatTag
          ?.split(',')
          .where((s) => s.trim().isNotEmpty)
          .toList();
      expect(seatList?.length, equals(2));

      // Class of service (from tag)
      final classTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'workspace_premium')
          .value;
      expect(classTag, equals('AC SLEEPER SEATER'));

      // Boarding point (from extras)
      final boarding = ticket.extras
          ?.firstWhere((e) => e.title == 'Boarding')
          .value;
      expect(boarding, equals('KOTTIVAKKAM(RTO OFFICE)'));
    });

    test('should return null for empty or non-matching SMS text', () {
      const emptySms = '';
      final emptyTicket = parser.parseTicket(emptySms);
      expect(emptyTicket, isNull);

      const nonMatchingSms = 'This is a regular message.';
      final nonMatchingTicket = parser.parseTicket(nonMatchingSms);
      expect(nonMatchingTicket, isNull);
    });

    test('should handle malformed seat numbers', () {
      const smsText =
          'TNSTC Corporation:SETC , PNR NO.:T123 , '
          'Seat No.:, .Class:AC';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);

      // Provider (from extras)
      final provider = ticket!.extras
          ?.firstWhere((e) => e.title == 'Provider')
          .value;
      expect(provider, equals('SETC'));

      // PNR (from tag)
      final pnrTag = ticket.tags?.firstWhere((t) => t.icon == 'qr_code').value;
      expect(pnrTag, equals('T123'));

      // Seat number (should be empty or missing)
      final hasSeatTag = ticket.tags!.any((t) => t.icon == 'event_seat');
      if (hasSeatTag) {
        final seatTag = ticket.tags
            ?.firstWhere((t) => t.icon == 'event_seat')
            .value
            ?.trim();
        expect(seatTag, isEmpty);
      } else {
        // Parser may not include an empty seat tag at all
        expect(hasSeatTag, isFalse);
      }

      // Derived seat list should be empty
      final seatList = ticket.tags
          ?.where((t) => t.icon == 'event_seat')
          .expand((t) => t.value!.split(','))
          .where((s) => s.trim().isNotEmpty)
          .toList();
      expect(seatList, isEmpty);

      // Class of service (still parsed)
      final classTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'workspace_premium')
          .value;
      expect(classTag, equals('AC'));
    });

    test('should handle single seat number', () {
      const smsText =
          'TNSTC Corporation:SETC , PNR NO.:T123 , '
          'Seat No.:15, .Class:AC';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);

      // Provider (from extras)
      final provider = ticket!.extras
          ?.firstWhere((e) => e.title == 'Provider')
          .value;
      expect(provider, equals('SETC'));

      // PNR (from tag)
      final pnrTag = ticket.tags?.firstWhere((t) => t.icon == 'qr_code').value;
      expect(pnrTag, equals('T123'));

      // Seat number (from tag)
      final seatTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'event_seat')
          .value;
      expect(seatTag, equals('15')); // trailing comma cleaned

      // Derived seat list
      final seatList = seatTag
          ?.split(',')
          .where((s) => s.trim().isNotEmpty)
          .toList();
      expect(seatList, equals(['15']));

      // Class of service (from tag)
      final classTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'workspace_premium')
          .value;
      expect(classTag, equals('AC'));
    });

    test('should parse time with comma format correctly', () {
      const smsText =
          'TNSTC Corporation:SETC , PNR NO.:T69705233 , '
          'From:KUMBAKONAM To CHENNAI-PT DR. M.G.R. BS , '
          'Trip Code:2100KUMCHELB , Journey Date:21/10/2025 , '
          'Time:,21:00 , Seat No.:4LB .Class:NON AC LOWER BERTH SEATER , '
          'Boarding at:KUMBAKONAM .';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);

      // Core route info
      expect(
        ticket!.primaryText,
        equals('KUMBAKONAM → CHENNAI-PT DR. M.G.R. BS'),
      );
      expect(ticket.secondaryText, equals('SETC - 2100KUMCHELB'));

      // Provider (from extras)
      final provider = ticket.extras
          ?.firstWhere((e) => e.title == 'Provider')
          .value;
      expect(provider, equals('SETC'));

      // PNR (from tag)
      final pnrTag = ticket.tags?.firstWhere((t) => t.icon == 'qr_code').value;
      expect(pnrTag, equals('T69705233'));

      // Trip code (from extras)
      final tripCode = ticket.extras
          ?.firstWhere((e) => e.title == 'Trip Code')
          .value;
      expect(tripCode, equals('2100KUMCHELB'));

      // Journey Date (from extras)
      final journeyDateStr = ticket.extras
          ?.firstWhere((e) => e.title == 'Journey Date')
          .value;
      final journeyDate = DateTime.parse(
        journeyDateStr!
            .split('/')
            .reversed
            .join('-'), // Converts dd/MM/yyyy → yyyy-MM-dd
      );
      expect(journeyDate.day, equals(21));
      expect(journeyDate.month, equals(10));
      expect(journeyDate.year, equals(2025));

      // Departure time (from tag)
      final departureTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'access_time')
          .value;
      expect(
        departureTag,
        equals('21:00'),
      ); // comma before time handled correctly

      // Seat number (from tag)
      final seatTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'event_seat')
          .value;
      expect(seatTag, equals('4LB'));

      // Derived seat list
      final seatList = seatTag
          ?.split(',')
          .where((s) => s.trim().isNotEmpty)
          .toList();
      expect(seatList?.length, equals(1));

      // Class of service (from tag)
      final classTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'workspace_premium')
          .value;
      expect(classTag, equals('NON AC LOWER BERTH SEATER'));

      // Boarding point (from extras)
      final boarding = ticket.extras
          ?.firstWhere((e) => e.title == 'Boarding')
          .value;
      expect(boarding, equals('KUMBAKONAM'));
    });

    test('should parse time without comma format correctly', () {
      const smsText =
          'TNSTC Corporation:SETC , PNR NO.:T12345 , '
          'Journey Date:15/05/2025 , Time:14:30 , Seat No.:10A';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);

      // Provider (from extras)
      final provider = ticket!.extras
          ?.firstWhere((e) => e.title == 'Provider')
          .value;
      expect(provider, equals('SETC'));

      // PNR number (from tag)
      final pnrTag = ticket.tags?.firstWhere((t) => t.icon == 'qr_code').value;
      expect(pnrTag, equals('T12345'));

      // Journey Date (from extras)
      final journeyDateStr = ticket.extras
          ?.firstWhere((e) => e.title == 'Journey Date')
          .value;
      final journeyDate = DateTime.parse(
        journeyDateStr!
            .split('/')
            .reversed
            .join('-'), // Converts dd/MM/yyyy → yyyy-MM-dd
      );
      expect(journeyDate.day, equals(15));
      expect(journeyDate.month, equals(5));
      expect(journeyDate.year, equals(2025));

      // Departure Time (from tag)
      final departureTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'access_time')
          .value;
      expect(departureTag, equals('14:30')); // parsed correctly without comma

      // Seat number (from tag)
      final seatTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'event_seat')
          .value;
      expect(seatTag, equals('10A'));
    });

    test('should handle various seat number formats', () {
      // Case 1: Seat number with letters
      const smsText1 = 'TNSTC Seat No.:4LB .Class:NON AC';
      final ticket1 = parser.parseTicket(smsText1);

      expect(ticket1, isNotNull);
      final seatTag1 = ticket1!.tags
          ?.firstWhere((t) => t.icon == 'event_seat')
          .value;
      expect(seatTag1, equals('4LB'));
      final seatList1 = seatTag1
          ?.split(',')
          .where((s) => s.trim().isNotEmpty)
          .toList();
      expect(seatList1?.length, equals(1));

      final classTag1 = ticket1.tags
          ?.firstWhere((t) => t.icon == 'workspace_premium')
          .value;
      expect(classTag1, equals('NON AC'));

      // Case 2: Seat number with space (upper berth)
      const smsText2 = 'TNSTC Seat No.:4 UB, .Class:NON AC';
      final ticket2 = parser.parseTicket(smsText2);

      expect(ticket2, isNotNull);
      final seatTag2 = ticket2!.tags
          ?.firstWhere((t) => t.icon == 'event_seat')
          .value;
      expect(
        seatTag2,
        equals('4 UB'),
      ); // preserves space between seat and berth
      final seatList2 = seatTag2
          ?.split(',')
          .where((s) => s.trim().isNotEmpty)
          .toList();
      expect(seatList2?.length, equals(1));

      final classTag2 = ticket2.tags
          ?.firstWhere((t) => t.icon == 'workspace_premium')
          .value;
      expect(classTag2, equals('NON AC'));

      // Case 3: Multiple seats
      const smsText3 = 'TNSTC Seat No.:20,21, .Class:AC SLEEPER';
      final ticket3 = parser.parseTicket(smsText3);

      expect(ticket3, isNotNull);
      final seatTag3 = ticket3!.tags
          ?.firstWhere((t) => t.icon == 'event_seat')
          .value;
      expect(seatTag3, equals('20,21')); // trailing comma removed
      final seatList3 = seatTag3
          ?.split(',')
          .where((s) => s.trim().isNotEmpty)
          .toList();
      expect(seatList3?.length, equals(2));

      final classTag3 = ticket3.tags
          ?.firstWhere((t) => t.icon == 'workspace_premium')
          .value;
      expect(classTag3, equals('AC SLEEPER'));
    });

    test('should handle different class formats', () {
      // Case 1: NON AC LOWER BERTH SEATER
      const smsText1 = 'TNSTC Class:NON AC LOWER BERTH SEATER , Boarding';
      final ticket1 = parser.parseTicket(smsText1);

      expect(ticket1, isNotNull);
      final classTag1 = ticket1!.tags
          ?.firstWhere((t) => t.icon == 'workspace_premium')
          .value;
      expect(classTag1, equals('NON AC LOWER BERTH SEATER'));

      // Case 2: AC SLEEPER SEATER
      const smsText2 = 'TNSTC Class:AC SLEEPER SEATER , Boarding';
      final ticket2 = parser.parseTicket(smsText2);

      expect(ticket2, isNotNull);
      final classTag2 = ticket2!.tags
          ?.firstWhere((t) => t.icon == 'workspace_premium')
          .value;
      expect(classTag2, equals('AC SLEEPER SEATER'));
    });

    test('should handle different boarding point formats', () {
      // Case 1: Single word boarding point
      const smsText1 = 'TNSTC Boarding at:KUMBAKONAM . For e-Ticket';
      final ticket1 = parser.parseTicket(smsText1);

      expect(ticket1, isNotNull);
      final boarding1 = ticket1!.extras
          ?.firstWhere((e) => e.title == 'Boarding')
          .value;
      expect(boarding1, equals('KUMBAKONAM'));

      // Case 2: Boarding point with brackets
      const smsText2 =
          'TNSTC Boarding at:KOTTIVAKKAM(RTO OFFICE) . For e-Ticket';
      final ticket2 = parser.parseTicket(smsText2);

      expect(ticket2, isNotNull);
      final boarding2 = ticket2!.extras
          ?.firstWhere((e) => e.title == 'Boarding')
          .value;
      expect(boarding2, equals('KOTTIVAKKAM(RTO OFFICE)'));
    });
  });

  group('Real SMS Data Tests', () {
    late TNSTCBusParser parser;

    setUp(() {
      parser = TNSTCBusParser();
    });

    test('should parse SMS with date prefix in time field', () {
      const smsText =
          'TNSTC Corporation:SETC, PNR NO.:T58823886, '
          'From:CHENNAI-PT Dr.M.G.R. BS To KUMBAKONAM, '
          'Trip Code:2300CHEKUMLB , Journey Date:10/10/2024, '
          'Time:10/10/2024,23:55, Seat No.:4LB.Class:NON AC LOWER BIRTH SEATER, '
          'Boarding at:KOTTIVAKKAM(RTO OFFICE).';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);

      // Primary and secondary texts
      expect(
        ticket!.primaryText,
        equals('CHENNAI-PT Dr.M.G.R. BS → KUMBAKONAM'),
      );
      expect(ticket.secondaryText, equals('SETC - 2300CHEKUMLB'));

      // Provider (from extras)
      final provider = ticket.extras
          ?.firstWhere((e) => e.title == 'Provider')
          .value;
      expect(provider, equals('SETC'));

      // PNR (from tag)
      final pnrTag = ticket.tags?.firstWhere((t) => t.icon == 'qr_code').value;
      expect(pnrTag, equals('T58823886'));

      // Departure time (from tag)
      final departureTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'access_time')
          .value;
      expect(departureTag, equals('23:55'));

      // Seat number (from tag)
      final seatTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'event_seat')
          .value;
      expect(seatTag, equals('4LB'));

      // Class of service (from tag)
      final classTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'workspace_premium')
          .value;
      expect(classTag, equals('NON AC LOWER BIRTH SEATER'));

      // Boarding location
      final boarding = ticket.extras
          ?.firstWhere((e) => e.title == 'Boarding')
          .value;
      expect(boarding, equals('KOTTIVAKKAM(RTO OFFICE)'));
    });

    test('should parse SMS with trailing comma in seat number', () {
      const smsText =
          'TNSTC Corporation:SETC, PNR NO.:T58825236, '
          'From:KUMBAKONAM To CHENNAI KALAIGNAR CBT, '
          'Trip Code:2030KUMKCBNS , Journey Date:13/10/2024, '
          'Time:20:30, Seat No.:12,.Class:NON AC SLEEPER SEATER, '
          'Boarding at:KUMBAKONAM.';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);

      // Main fields
      expect(ticket!.primaryText, equals('KUMBAKONAM → CHENNAI KALAIGNAR CBT'));
      expect(ticket.secondaryText, equals('SETC - 2030KUMKCBNS'));

      // Provider (from extras)
      final provider = ticket.extras
          ?.firstWhere((e) => e.title == 'Provider')
          .value;
      expect(provider, equals('SETC'));

      // PNR number (from tag)
      final pnrTag = ticket.tags?.firstWhere((t) => t.icon == 'qr_code').value;
      expect(pnrTag, equals('T58825236'));

      // Departure time (from tag)
      final departureTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'access_time')
          .value;
      expect(departureTag, equals('20:30'));

      // Seat number (from tag)
      final seatTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'event_seat')
          .value;
      expect(seatTag, equals('12')); // trimmed trailing comma

      // Class of service (from tag)
      final classTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'workspace_premium')
          .value;
      expect(classTag, equals('NON AC SLEEPER SEATER'));

      // Boarding location (from extras)
      final boarding = ticket.extras
          ?.firstWhere((e) => e.title == 'Boarding')
          .value;
      expect(boarding, equals('KUMBAKONAM'));
    });

    test('should parse SMS with complex seat number format', () {
      const smsText =
          'TNSTC Corporation:SETC , PNR NO.:T62602262 , '
          'From:CHENNAI-PT DR. M.G.R. BS To KUMBAKONAM , '
          'Trip Code:2300CHEKUMLB , Journey Date:17/01/2025 , '
          'Time:,23:55 , Seat No.:36-UB#10 .Class:NON AC LOWER BIRTH SEATER';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);

      // Core ticket fields
      expect(
        ticket!.primaryText,
        equals('CHENNAI-PT DR. M.G.R. BS → KUMBAKONAM'),
      );
      expect(ticket.secondaryText, equals('SETC - 2300CHEKUMLB'));

      // Provider (from extras)
      final provider = ticket.extras
          ?.firstWhere((e) => e.title == 'Provider')
          .value;
      expect(provider, equals('SETC'));

      // PNR number (from tag)
      final pnrTag = ticket.tags?.firstWhere((t) => t.icon == 'qr_code').value;
      expect(pnrTag, equals('T62602262'));

      // Departure time (from tag)
      final departureTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'access_time')
          .value;
      expect(departureTag, equals('23:55'));

      // Complex seat number (from tag)
      final seatTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'event_seat')
          .value;
      expect(seatTag, equals('36-UB#10'));

      // Class of service (from tag)
      final classTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'workspace_premium')
          .value;
      expect(classTag, equals('NON AC LOWER BIRTH SEATER'));
    });

    test('should parse SMS with no space in seat number', () {
      const smsText =
          'TNSTC Corporation:SETC , PNR NO.:T68439967 , '
          'From:CHENNAI-PT DR. M.G.R. BS To KUMBAKONAM , '
          'Trip Code:2200CHEKUMLB , Journey Date:14/08/2025 , '
          'Time:,22:55 , Seat No.:13UB .Class:NON AC LOWER BERTH SEATER';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);

      // Route and corporation-trip info
      expect(
        ticket!.primaryText,
        equals('CHENNAI-PT DR. M.G.R. BS → KUMBAKONAM'),
      );
      expect(ticket.secondaryText, equals('SETC - 2200CHEKUMLB'));

      // Provider (from extras)
      final provider = ticket.extras
          ?.firstWhere((e) => e.title == 'Provider')
          .value;
      expect(provider, equals('SETC'));

      // PNR number (from tag)
      final pnrTag = ticket.tags?.firstWhere((t) => t.icon == 'qr_code').value;
      expect(pnrTag, equals('T68439967'));

      // Departure time (from tag)
      final departureTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'access_time')
          .value;
      expect(departureTag, equals('22:55'));

      // Seat number (from tag)
      final seatTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'event_seat')
          .value;
      expect(seatTag, equals('13UB')); // No space, should be parsed cleanly

      // Class of service (from tag)
      final classTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'workspace_premium')
          .value;
      expect(classTag, equals('NON AC LOWER BERTH SEATER'));
    });

    test('should parse SMS from different corporation', () {
      const smsText =
          'TNSTC Corporation:COIMBATORE , PNR NO.:U70109781 , '
          'From:KUMBAKONAM To COIMBATORE , Trip Code:0400KUMCOICC01L , '
          'Journey Date:30/08/2025 , Time:,04:00 , Seat No.:24 .Class:DELUXE 3X2';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);

      // Route and summary fields
      expect(ticket!.primaryText, equals('KUMBAKONAM → COIMBATORE'));
      expect(ticket.secondaryText, equals('COIMBATORE - 0400KUMCOICC01L'));

      // Provider (from extras)
      final provider = ticket.extras
          ?.firstWhere((e) => e.title == 'Provider')
          .value;
      expect(provider, equals('COIMBATORE'));

      // PNR number (from tag)
      final pnrTag = ticket.tags?.firstWhere((t) => t.icon == 'qr_code').value;
      expect(pnrTag, equals('U70109781'));

      // Departure time (from tag)
      final departureTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'access_time')
          .value;
      expect(departureTag, equals('04:00'));

      // Seat number (from tag)
      final seatTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'event_seat')
          .value;
      expect(seatTag, equals('24'));

      // Class of service (from tag)
      final classTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'workspace_premium')
          .value;
      expect(classTag, equals('DELUXE 3X2'));
    });

    test('should parse multiple seat numbers correctly', () {
      const smsText =
          'TNSTC Corporation:SETC , PNR NO.:T63736642 , '
          'From:CHENNAI-PT DR. M.G.R. BS To KUMBAKONAM , '
          'Trip Code:2145CHEKUMAB , Journey Date:11/02/2025 , '
          'Time:22:35 , Seat No.:20,21, .Class:AC SLEEPER SEATER';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);

      // Route and summary
      expect(
        ticket!.primaryText,
        equals('CHENNAI-PT DR. M.G.R. BS → KUMBAKONAM'),
      );
      expect(ticket.secondaryText, equals('SETC - 2145CHEKUMAB'));

      // Provider (from extras)
      final provider = ticket.extras
          ?.firstWhere((e) => e.title == 'Provider')
          .value;
      expect(provider, equals('SETC'));

      // PNR number (from tag)
      final pnrTag = ticket.tags?.firstWhere((t) => t.icon == 'qr_code').value;
      expect(pnrTag, equals('T63736642'));

      // Departure time (from tag)
      final departureTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'access_time')
          .value;
      expect(departureTag, equals('22:35'));

      // Seat numbers (from tag)
      final seatTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'event_seat')
          .value;
      expect(seatTag, equals('20,21')); // trailing comma removed

      // Check seat count manually since Ticket doesn't have seatNumbersList
      final seatList = seatTag
          ?.split(',')
          .where((s) => s.trim().isNotEmpty)
          .toList();
      expect(seatList?.length, equals(2));

      // Class of service (from tag)
      final classTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'workspace_premium')
          .value;
      expect(classTag, equals('AC SLEEPER SEATER'));
    });
  });

  group('TravelParserService.parseUpdateSMS Tests', () {
    late TravelParserService parserService;

    setUp(() {
      parserService = TravelParserService();
    });

    test('should parse conductor SMS and extract details', () {
      const smsText =
          '* TNSTC * PNR:T69705233, DOJ:21/10/2025, Conductor Mobile No: 8870571461, Vehicle No:TN01AN4317, Route No:307LB.';

      final updateInfo = parserService.parseUpdateSMS(smsText);

      expect(updateInfo, isNotNull);
      expect(updateInfo!.pnrNumber, equals('T69705233'));
      expect(updateInfo.providerName, equals('TNSTC'));
      expect(updateInfo.updates, containsPair('contact_mobile', '8870571461'));
      expect(updateInfo.updates, containsPair('trip_code', 'TN01AN4317'));
    });

    test('should return null for non-update SMS', () {
      const smsText = 'This is a regular SMS from TNSTC.';
      final updateInfo = parserService.parseUpdateSMS(smsText);
      expect(updateInfo, isNull);
    });

    test('should handle update SMS with only conductor number', () {
      const smsText = '* TNSTC * PNR:T123, Conductor Mobile No: 1234567890';
      final updateInfo = parserService.parseUpdateSMS(smsText);
      expect(updateInfo, isNotNull);
      expect(updateInfo!.pnrNumber, equals('T123'));
      expect(updateInfo.updates.length, equals(1));
      expect(updateInfo.updates, containsPair('contact_mobile', '1234567890'));
    });

    test('should handle update SMS with only vehicle number', () {
      const smsText = '* TNSTC * PNR:T456, Vehicle No:TN01AB1234';
      final updateInfo = parserService.parseUpdateSMS(smsText);
      expect(updateInfo, isNotNull);
      expect(updateInfo!.pnrNumber, equals('T456'));
      expect(updateInfo.updates.length, equals(1));
      expect(updateInfo.updates, containsPair('trip_code', 'TN01AB1234'));
    });

    test('should return null if PNR is missing', () {
      const smsText =
          '* TNSTC * Conductor Mobile No: 1234567890, Vehicle No:TN01AB1234';
      final updateInfo = parserService.parseUpdateSMS(smsText);
      expect(updateInfo, isNull);
    });
  });
}
