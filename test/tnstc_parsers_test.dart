import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/common/application/travel_parser_service.dart';

void main() {
  group('TNSTCBusParser Tests', () {
    final parser = TNSTCBusParser();

    test('should parse standard SETC SMS correctly', () {
      const smsText = 'TNSTC Corporation:SETC , PNR NO.:T63736642 , '
          'From:CHENNAI-PT DR. M.G.R. BS To KUMBAKONAM , '
          'Trip Code:2145CHEKUMAB , Journey Date:11/02/2025 , Time:22:35 , '
          'Seat No.:20,21, .Class:AC SLEEPER SEATER , '
          'Boarding at:KOTTIVAKKAM(RTO OFFICE) . For e-Ticket: Download from '
          'View Ticket. Please carry your photo ID during journey. T&C apply.';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);
      expect(ticket!.providerName, equals('SETC'));
      expect(ticket.pnrNumber, equals('T63736642'));
      expect(ticket.sourceLocation, equals('CHENNAI-PT DR. M.G.R. BS'));
      expect(ticket.destinationLocation, equals('KUMBAKONAM'));
      expect(ticket.tripCode, equals('2145CHEKUMAB'));

      final journeyDate = DateTime.parse(ticket.journeyDate!);
      expect(journeyDate.day, equals(11));
      expect(journeyDate.month, equals(2));
      expect(journeyDate.year, equals(2025));

      expect(ticket.departureTime, equals('22:35'));
      expect(ticket.seatNumbers, equals('20,21'));
      expect(ticket.seatNumbersList.length, equals(2));
      expect(ticket.classOfService, equals('AC SLEEPER SEATER'));
      expect(ticket.boardingPoint, equals('KOTTIVAKKAM(RTO OFFICE)'));
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
      const smsText = 'TNSTC Corporation:SETC , PNR NO.:T123 , '
          'Seat No.:, .Class:AC';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);
      expect(ticket!.seatNumbers, isNull);
      expect(ticket.seatNumbersList, isEmpty);
    });

    test('should handle single seat number', () {
      const smsText = 'TNSTC Corporation:SETC , PNR NO.:T123 , '
          'Seat No.:15, .Class:AC';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);
      expect(ticket!.seatNumbers, equals('15'));
      expect(ticket.seatNumbersList, equals(['15']));
    });

    test('should parse time with comma format correctly', () {
      const smsText = 'TNSTC Corporation:SETC , PNR NO.:T69705233 , '
          'From:KUMBAKONAM To CHENNAI-PT DR. M.G.R. BS , '
          'Trip Code:2100KUMCHELB , Journey Date:21/10/2025 , '
          'Time:,21:00 , Seat No.:4LB .Class:NON AC LOWER BERTH SEATER , '
          'Boarding at:KUMBAKONAM .';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);
      expect(ticket!.providerName, equals('SETC'));
      expect(ticket.pnrNumber, equals('T69705233'));
      expect(ticket.sourceLocation, equals('KUMBAKONAM'));
      expect(ticket.destinationLocation, equals('CHENNAI-PT DR. M.G.R. BS'));
      expect(ticket.tripCode, equals('2100KUMCHELB'));
      final journeyDate = DateTime.parse(ticket.journeyDate!);
      expect(journeyDate.day, equals(21));
      expect(journeyDate.month, equals(10));
      expect(journeyDate.year, equals(2025));
      expect(ticket.departureTime, equals('21:00'));
      expect(ticket.seatNumbers, equals('4LB'));
      expect(ticket.seatNumbersList.length, equals(1));
      expect(ticket.classOfService, equals('NON AC LOWER BERTH SEATER'));
      expect(ticket.boardingPoint, equals('KUMBAKONAM'));
    });

    test('should parse time without comma format correctly', () {
      const smsText = 'TNSTC Corporation:SETC , PNR NO.:T12345 , '
          'Journey Date:15/05/2025 , Time:14:30 , Seat No.:10A';

      final ticket = parser.parseTicket(smsText);
      expect(ticket, isNotNull);
      expect(ticket!.departureTime, equals('14:30'));
    });

    test('should handle various seat number formats', () {
      // Test with seat number with letters
      const smsText1 = 'TNSTC Seat No.:4LB .Class:NON AC';
      final ticket1 = parser.parseTicket(smsText1);
      expect(ticket1, isNotNull);
      expect(ticket1!.seatNumbers, equals('4LB'));
      expect(ticket1.seatNumbersList.length, equals(1));

      // Test with upper berth seat
      const smsText2 = 'TNSTC Seat No.:4 UB, .Class:NON AC';
      final ticket2 = parser.parseTicket(smsText2);
      expect(ticket2, isNotNull);
      expect(ticket2!.seatNumbers, equals('4 UB'));
      expect(ticket2.seatNumbersList.length, equals(1));

      // Test with multiple seats
      const smsText3 = 'TNSTC Seat No.:20,21, .Class:AC SLEEPER';
      final ticket3 = parser.parseTicket(smsText3);
      expect(ticket3, isNotNull);
      expect(ticket3!.seatNumbers, equals('20,21'));
      expect(ticket3.seatNumbersList.length, equals(2));
    });

    test('should handle different class formats', () {
      // Test NON AC LOWER BERTH SEATER
      const smsText1 = 'TNSTC Class:NON AC LOWER BERTH SEATER , Boarding';
      final ticket1 = parser.parseTicket(smsText1);
      expect(ticket1, isNotNull);
      expect(ticket1!.classOfService, equals('NON AC LOWER BERTH SEATER'));

      // Test AC SLEEPER SEATER
      const smsText2 = 'TNSTC Class:AC SLEEPER SEATER , Boarding';
      final ticket2 = parser.parseTicket(smsText2);
      expect(ticket2, isNotNull);
      expect(ticket2!.classOfService, equals('AC SLEEPER SEATER'));
    });

    test('should handle different boarding point formats', () {
      // Test single word boarding point
      const smsText1 = 'TNSTC Boarding at:KUMBAKONAM . For e-Ticket';
      final ticket1 = parser.parseTicket(smsText1);
      expect(ticket1, isNotNull);
      expect(ticket1!.boardingPoint, equals('KUMBAKONAM'));

      // Test boarding point with brackets
      const smsText2 = 'TNSTC Boarding at:KOTTIVAKKAM(RTO OFFICE) . For e-Ticket';
      final ticket2 = parser.parseTicket(smsText2);
      expect(ticket2, isNotNull);
      expect(ticket2!.boardingPoint, equals('KOTTIVAKKAM(RTO OFFICE)'));
    });
  });

  group('Real SMS Data Tests', () {
    final parser = TNSTCBusParser();

    test('should parse SMS with date prefix in time field', () {
      const smsText = 'TNSTC Corporation:SETC, PNR NO.:T58823886, '
          'From:CHENNAI-PT Dr.M.G.R. BS To KUMBAKONAM, '
          'Trip Code:2300CHEKUMLB, Journey Date:10/10/2024, '
          'Time:10/10/2024,23:55, Seat No.:4LB.Class:NON AC LOWER BIRTH SEATER, '
          'Boarding at:KOTTIVAKKAM(RTO OFFICE).';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);
      expect(ticket!.providerName, equals('SETC'));
      expect(ticket.pnrNumber, equals('T58823886'));
      expect(ticket.sourceLocation, equals('CHENNAI-PT Dr.M.G.R. BS'));
      expect(ticket.destinationLocation, equals('KUMBAKONAM'));
      expect(ticket.departureTime, equals('23:55'));
      expect(ticket.seatNumbers, equals('4LB'));
      expect(ticket.classOfService, equals('NON AC LOWER BIRTH SEATER'));
    });

    test('should parse SMS with trailing comma in seat number', () {
      const smsText = 'TNSTC Corporation:SETC, PNR NO.:T58825236, '
          'From:KUMBAKONAM To CHENNAI KALAIGNAR CBT, '
          'Trip Code:2030KUMKCBNS, Journey Date:13/10/2024, '
          'Time:20:30, Seat No.:12,.Class:NON AC SLEEPER SEATER, '
          'Boarding at:KUMBAKONAM.';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);
      expect(ticket!.providerName, equals('SETC'));
      expect(ticket.pnrNumber, equals('T58825236'));
      expect(ticket.sourceLocation, equals('KUMBAKONAM'));
      expect(ticket.destinationLocation, equals('CHENNAI KALAIGNAR CBT'));
      expect(ticket.departureTime, equals('20:30'));
      expect(ticket.seatNumbers, equals('12'));
      expect(ticket.classOfService, equals('NON AC SLEEPER SEATER'));
    });

    test('should parse SMS with complex seat number format', () {
      const smsText = 'TNSTC Corporation:SETC , PNR NO.:T62602262 , '
          'From:CHENNAI-PT DR. M.G.R. BS To KUMBAKONAM , '
          'Trip Code:2300CHEKUMLB , Journey Date:17/01/2025 , '
          'Time:,23:55 , Seat No.:36-UB#10 .Class:NON AC LOWER BIRTH SEATER';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);
      expect(ticket!.providerName, equals('SETC'));
      expect(ticket.pnrNumber, equals('T62602262'));
      expect(ticket.departureTime, equals('23:55'));
      expect(ticket.seatNumbers, equals('36-UB#10'));
      expect(ticket.classOfService, equals('NON AC LOWER BIRTH SEATER'));
    });

    test('should parse SMS with no space in seat number', () {
      const smsText = 'TNSTC Corporation:SETC , PNR NO.:T68439967 , '
          'From:CHENNAI-PT DR. M.G.R. BS To KUMBAKONAM , '
          'Trip Code:2200CHEKUMLB , Journey Date:14/08/2025 , '
          'Time:,22:55 , Seat No.:13UB .Class:NON AC LOWER BERTH SEATER';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);
      expect(ticket!.providerName, equals('SETC'));
      expect(ticket.pnrNumber, equals('T68439967'));
      expect(ticket.departureTime, equals('22:55'));
      expect(ticket.seatNumbers, equals('13UB'));
      expect(ticket.classOfService, equals('NON AC LOWER BERTH SEATER'));
    });

    test('should parse SMS from different corporation', () {
      const smsText = 'TNSTC Corporation:COIMBATORE , PNR NO.:U70109781 , '
          'From:KUMBAKONAM To COIMBATORE , Trip Code:0400KUMCOICC01L , '
          'Journey Date:30/08/2025 , Time:,04:00 , Seat No.:24 .Class:DELUXE 3X2';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);
      expect(ticket!.providerName, equals('COIMBATORE'));
      expect(ticket.pnrNumber, equals('U70109781'));
      expect(ticket.sourceLocation, equals('KUMBAKONAM'));
      expect(ticket.destinationLocation, equals('COIMBATORE'));
      expect(ticket.departureTime, equals('04:00'));
      expect(ticket.seatNumbers, equals('24'));
      expect(ticket.classOfService, equals('DELUXE 3X2'));
    });

    test('should parse multiple seat numbers correctly', () {
      const smsText = 'TNSTC Corporation:SETC , PNR NO.:T63736642 , '
          'From:CHENNAI-PT DR. M.G.R. BS To KUMBAKONAM , '
          'Trip Code:2145CHEKUMAB , Journey Date:11/02/2025 , '
          'Time:22:35 , Seat No.:20,21, .Class:AC SLEEPER SEATER';

      final ticket = parser.parseTicket(smsText);

      expect(ticket, isNotNull);
      expect(ticket!.providerName, equals('SETC'));
      expect(ticket.pnrNumber, equals('T63736642'));
      expect(ticket.departureTime, equals('22:35'));
      expect(ticket.seatNumbers, equals('20,21'));
      expect(ticket.seatNumbersList.length, equals(2));
      expect(ticket.classOfService, equals('AC SLEEPER SEATER'));
    });
  });

  group('TravelParserService.parseUpdateSMS Tests', () {
    test('should parse conductor SMS and extract details', () {
      const smsText = '* TNSTC * PNR:T69705233, DOJ:21/10/2025, Conductor Mobile No: 8870571461, Vehicle No:TN01AN4317, Route No:307LB.';
      
      final updateInfo = TravelParserService.parseUpdateSMS(smsText);

      expect(updateInfo, isNotNull);
      expect(updateInfo!.pnrNumber, equals('T69705233'));
      expect(updateInfo.providerName, equals('TNSTC'));
      expect(updateInfo.updates, containsPair('contact_mobile', '8870571461'));
      expect(updateInfo.updates, containsPair('trip_code', 'TN01AN4317'));
    });

    test('should return null for non-update SMS', () {
      const smsText = 'This is a regular SMS from TNSTC.';
      final updateInfo = TravelParserService.parseUpdateSMS(smsText);
      expect(updateInfo, isNull);
    });

    test('should handle update SMS with only conductor number', () {
        const smsText = '* TNSTC * PNR:T123, Conductor Mobile No: 1234567890';
        final updateInfo = TravelParserService.parseUpdateSMS(smsText);
        expect(updateInfo, isNotNull);
        expect(updateInfo!.pnrNumber, equals('T123'));
        expect(updateInfo.updates.length, equals(1));
        expect(updateInfo.updates, containsPair('contact_mobile', '1234567890'));
    });

    test('should handle update SMS with only vehicle number', () {
        const smsText = '* TNSTC * PNR:T456, Vehicle No:TN01AB1234';
        final updateInfo = TravelParserService.parseUpdateSMS(smsText);
        expect(updateInfo, isNotNull);
        expect(updateInfo!.pnrNumber, equals('T456'));
        expect(updateInfo.updates.length, equals(1));
        expect(updateInfo.updates, containsPair('trip_code', 'TN01AB1234'));
    });

     test('should return null if PNR is missing', () {
        const smsText = '* TNSTC * Conductor Mobile No: 1234567890, Vehicle No:TN01AB1234';
        final updateInfo = TravelParserService.parseUpdateSMS(smsText);
        expect(updateInfo, isNull);
    });
  });
}