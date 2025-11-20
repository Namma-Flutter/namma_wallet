import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_sms_parser.dart';

void main() {
  group('TNSTCSMSParser Tests', () {
    late TNSTCSMSParser parser;

    setUp(() {
      parser = TNSTCSMSParser();
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
        ticket.primaryText,
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

      // Service Class (from extras)
      final serviceClass = ticket.extras
          ?.firstWhere((e) => e.title == 'Service Class')
          .value;
      expect(serviceClass, equals('AC SLEEPER SEATER'));

      // Source Type should be SMS
      final sourceType = ticket.extras
          ?.firstWhere((e) => e.title == 'Source Type')
          .value;
      expect(sourceType, equals('SMS'));

      // Verify startTime has correct date and time
      expect(ticket.startTime.year, equals(2025));
      expect(ticket.startTime.month, equals(2));
      expect(ticket.startTime.day, equals(11));
      expect(ticket.startTime.hour, equals(22));
      expect(ticket.startTime.minute, equals(35));
    });

    test('should return ticket for empty or non-matching SMS text', () {
      const smsText = 'Random text that does not match any pattern';

      final ticket = parser.parseTicket(smsText);

      // Parser will return a ticket with empty/default values
      expect(ticket, isNotNull);
    });

    test('should handle malformed seat numbers', () {
      const smsText =
          'TNSTC Corporation:SETC , PNR NO.:T63736642 , '
          'From:CHENNAI To KUMBAKONAM , '
          'Trip Code:2145CHEKUMAB , Journey Date:11/02/2025 , Time:22:35 , '
          'Seat No.:20,21,,,, .Class:AC SLEEPER , '
          'Boarding at:KOTTIVAKKAM .';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);

      // Should clean up malformed seat numbers (trailing commas)
      final seatTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'event_seat')
          .value;
      expect(seatTag, equals('20,21')); // should trim trailing commas
    });

    test('should handle single seat number', () {
      const smsText =
          'TNSTC Corporation:SETC , PNR NO.:T63736642 , '
          'From:CHENNAI To KUMBAKONAM , '
          'Trip Code:2145CHEKUMAB , Journey Date:11/02/2025 , Time:22:35 , '
          'Seat No.:4UB .Class:AC SLEEPER , '
          'Boarding at:KOTTIVAKKAM .';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);

      final seatTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'event_seat')
          .value;
      expect(seatTag, equals('4UB'));

      // Should calculate numberOfSeats as 1
      final seatsExtra = ticket.extras
          ?.firstWhere((e) => e.title == 'Seats')
          .value;
      expect(seatsExtra, equals('1'));
    });

    test('should parse time with comma format correctly', () {
      const smsText =
          'TNSTC Corporation:SETC , PNR NO.:T63736642 , '
          'From:CHENNAI To KUMBAKONAM , '
          'Trip Code:2145CHEKUMAB , Journey Date:11/02/2025 , Time:18/01/2026, ,22:35 , '
          'Seat No.:4UB .Class:AC SLEEPER , '
          'Boarding at:KOTTIVAKKAM .';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);

      // Should extract time correctly despite date prefix
      final departureTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'access_time')
          .value;
      expect(departureTag, equals('22:35'));
    });

    test('should parse time without comma format correctly', () {
      const smsText =
          'TNSTC Corporation:SETC , PNR NO.:T63736642 , '
          'From:CHENNAI To KUMBAKONAM , '
          'Trip Code:2145CHEKUMAB , Journey Date:11/02/2025 , Dept Time:22:35 , '
          'Seat No.:4UB .Class:AC SLEEPER , '
          'Boarding at:KOTTIVAKKAM .';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);

      final departureTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'access_time')
          .value;
      expect(departureTag, equals('22:35'));
    });

    test('should handle various seat number formats', () {
      const smsText =
          'TNSTC Corporation:SETC , PNR NO.:T63736642 , '
          'From:CHENNAI To KUMBAKONAM , '
          'Trip Code:2145CHEKUMAB , Journey Date:11/02/2025 , Time:22:35 , '
          'Seat No.:1A,2B,3C .Class:AC SLEEPER , '
          'Boarding at:KOTTIVAKKAM .';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);

      final seatTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'event_seat')
          .value;
      expect(seatTag, equals('1A,2B,3C'));

      final seatsExtra = ticket.extras
          ?.firstWhere((e) => e.title == 'Seats')
          .value;
      expect(seatsExtra, equals('3'));
    });

    test('should handle different class formats', () {
      const smsText =
          'TNSTC Corporation:SETC , PNR NO.:T63736642 , '
          'From:CHENNAI To KUMBAKONAM , '
          'Trip Code:2145CHEKUMAB , Journey Date:11/02/2025 , Time:22:35 , '
          'Seat No.:4UB, Class:ORDINARY , '
          'Boarding at:KOTTIVAKKAM .';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);

      final serviceClass = ticket.extras
          ?.firstWhere((e) => e.title == 'Service Class')
          .value;
      expect(serviceClass, equals('ORDINARY'));
    });

    test('should handle different boarding point formats', () {
      const smsText =
          'TNSTC Corporation:SETC , PNR NO.:T63736642 , '
          'From:CHENNAI To KUMBAKONAM , '
          'Trip Code:2145CHEKUMAB , Journey Date:11/02/2025 , Time:22:35 , '
          'Seat No.:4UB .Class:AC SLEEPER , '
          'Boarding at:CHENNAI CENTRAL BUS STAND.';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);

      expect(ticket.location, equals('CHENNAI CENTRAL BUS STAND'));
    });

    test('should handle seat numbers with spaces', () {
      const smsText =
          'TNSTC Corporation:SETC , PNR NO.:T69704790 , '
          'From:CHENNAI-PT DR. M.G.R. BS To KUMBAKONAM , '
          'Trip Code:2300CHEKUMLB , Journey Date:17/10/2025 , Time:23:55 , '
          'Seat No.:1 UB, .Class:NON AC LOWER BERTH SEATER , '
          'Boarding at:KOTTIVAKKAM(RTO OFFICE) . For e-Ticket: Download from '
          'View Ticket. Please carry your photo ID during journey. T&C apply.';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);

      // Should capture the full seat number including the space
      final seatTag = ticket.tags
          ?.firstWhere((t) => t.icon == 'event_seat')
          .value;
      expect(seatTag, equals('1 UB'));

      // Should calculate numberOfSeats as 1
      final seatsExtra = ticket.extras
          ?.firstWhere((e) => e.title == 'Seats')
          .value;
      expect(seatsExtra, equals('1'));
    });

    test('should parse conductor SMS and store details', () {
      const conductorSms =
          'TNSTC PNR:T12345678, Journey Date:15/12/2024, '
          'Conductor Mobile No:9876543210, Vehicle No:TN01AB1234';

      final ticket = parser.parseTicket(conductorSms);

      expect(ticket, isNotNull);

      // Should extract conductor mobile
      final conductorMobile = ticket.extras
          ?.firstWhere((e) => e.title == 'Conductor Contact')
          .value;
      expect(conductorMobile, equals('9876543210'));

      // Should extract vehicle number
      final vehicleNo = ticket.extras
          ?.firstWhere((e) => e.title == 'Bus Number')
          .value;
      expect(vehicleNo, equals('TN01AB1234'));
    });

    test('should not show passenger name and age for SMS tickets', () {
      const smsText =
          'TNSTC Corporation:SETC , PNR NO.:T63736642 , '
          'From:CHENNAI To KUMBAKONAM , '
          'Trip Code:2145CHEKUMAB , Journey Date:11/02/2025 , Time:22:35 , '
          'Seat No.:4UB .Class:AC SLEEPER , '
          'Boarding at:KOTTIVAKKAM .';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);

      // Passenger Name should NOT be in extras (empty name filtered out)
      final passengerNameExtra = ticket.extras
          ?.where((e) => e.title == 'Passenger Name')
          .firstOrNull;
      expect(passengerNameExtra, isNull);

      // Age should NOT be in extras (age 0 filtered out)
      final ageExtra = ticket.extras
          ?.where((e) => e.title == 'Age')
          .firstOrNull;
      expect(ageExtra, isNull);
    });
  });
}
