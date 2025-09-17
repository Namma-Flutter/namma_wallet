import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/tnstc/application/sms_service.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_pdf_parser.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_sms_parser.dart';

void main() {
  group('TNSTC SMS Parser Tests', () {
    test('should parse SMS format correctly', () {
      const smsText = 'TNSTC Corporation:SETC , PNR NO.:T63736642 , '
          'From:CHENNAI-PT DR. M.G.R. BS To KUMBAKONAM , '
          'Trip Code:2145CHEKUMAB , Journey Date:11/02/2025 , Time:22:35 , '
          'Seat No.:20,21, .Class:AC SLEEPER SEATER , '
          'Boarding at:KOTTIVAKKAM(RTO OFFICE) . For e-Ticket: Download from '
          'View Ticket. Please carry your photo ID during journey. T&C apply.';

      final ticket = TNSTCSMSParser.parseTicket(smsText);

      expect(ticket.corporation, equals('SETC'));
      expect(ticket.pnrNumber, equals('T63736642'));
      expect(ticket.serviceStartPlace, equals('CHENNAI-PT DR. M.G.R. BS'));
      expect(ticket.serviceEndPlace, equals('KUMBAKONAM'));
      expect(ticket.tripCode, equals('2145CHEKUMAB'));
      expect(ticket.journeyDate?.day, equals(11));
      expect(ticket.journeyDate?.month, equals(2));
      expect(ticket.journeyDate?.year, equals(2025));
      expect(ticket.serviceStartTime, equals('22:35'));
      expect(ticket.passengerInfo?.seatNumber, equals('20,21'));
      expect(ticket.numberOfSeats, equals(2));
      expect(ticket.classOfService, equals('AC SLEEPER SEATER'));
      expect(ticket.passengerPickupPoint, equals('KOTTIVAKKAM(RTO OFFICE)'));
    });

    test('should handle empty SMS text gracefully', () {
      const smsText = '';
      final ticket = TNSTCSMSParser.parseTicket(smsText);

      expect(ticket.corporation, equals(''));
      expect(ticket.pnrNumber, equals(''));
      expect(ticket.numberOfSeats, equals(1)); // Default value
      expect(ticket.journeyDate, isNotNull); // Should be current date
    });

    test('should handle malformed seat numbers', () {
      const smsText = 'TNSTC Corporation:SETC , PNR NO.:T123 , '
          'Seat No.:, .Class:AC';

      final ticket = TNSTCSMSParser.parseTicket(smsText);

      expect(ticket.numberOfSeats, equals(1)); // Default when no valid seats
      expect(ticket.passengerInfo?.seatNumber, equals(''));
    });

    test('should handle single seat number', () {
      const smsText = 'TNSTC Corporation:SETC , PNR NO.:T123 , '
          'Seat No.:15, .Class:AC';

      final ticket = TNSTCSMSParser.parseTicket(smsText);

      expect(ticket.numberOfSeats, equals(1));
      expect(ticket.passengerInfo?.seatNumber, equals('15'));
    });

    test('should parse time with comma format correctly', () {
      const smsText = 'TNSTC Corporation:SETC , PNR NO.:T69705233 , '
          'From:KUMBAKONAM To CHENNAI-PT DR. M.G.R. BS , '
          'Trip Code:2100KUMCHELB , Journey Date:21/10/2025 , '
          'Time:,21:00 , Seat No.:4LB .Class:NON AC LOWER BERTH SEATER , '
          'Boarding at:KUMBAKONAM . For e-Ticket: Download from View Ticket. '
          'Please carry your photo ID during journey. T&C apply. '
          'https://www.radiantinfo.com';

      final ticket = TNSTCSMSParser.parseTicket(smsText);

      expect(ticket.corporation, equals('SETC'));
      expect(ticket.pnrNumber, equals('T69705233'));
      expect(ticket.serviceStartPlace, equals('KUMBAKONAM'));
      expect(ticket.serviceEndPlace, equals('CHENNAI-PT DR. M.G.R. BS'));
      expect(ticket.tripCode, equals('2100KUMCHELB'));
      expect(ticket.journeyDate?.day, equals(21));
      expect(ticket.journeyDate?.month, equals(10));
      expect(ticket.journeyDate?.year, equals(2025));
      expect(ticket.serviceStartTime, equals('21:00')); // Time with comma
      expect(ticket.passengerInfo?.seatNumber, equals('4LB'));
      expect(ticket.numberOfSeats, equals(1));
      expect(ticket.classOfService, equals('NON AC LOWER BERTH SEATER'));
      expect(ticket.passengerPickupPoint, equals('KUMBAKONAM'));
    });

    test('should parse time without comma format correctly', () {
      const smsText = 'TNSTC Corporation:SETC , PNR NO.:T12345 , '
          'Journey Date:15/05/2025 , Time:14:30 , Seat No.:10A';

      final ticket = TNSTCSMSParser.parseTicket(smsText);

      expect(ticket.serviceStartTime, equals('14:30')); // Time without comma
    });

    test('should handle various seat number formats', () {
      // Test with seat number with letters
      const smsText1 = 'Seat No.:4LB .Class:NON AC';
      final ticket1 = TNSTCSMSParser.parseTicket(smsText1);
      expect(ticket1.passengerInfo?.seatNumber, equals('4LB'));
      expect(ticket1.numberOfSeats, equals(1));

      // Test with upper berth seat
      const smsText2 = 'Seat No.:4 UB, .Class:NON AC';
      final ticket2 = TNSTCSMSParser.parseTicket(smsText2);
      expect(ticket2.passengerInfo?.seatNumber, equals('4 UB'));
      expect(ticket2.numberOfSeats, equals(1));

      // Test with multiple seats
      const smsText3 = 'Seat No.:20,21, .Class:AC SLEEPER';
      final ticket3 = TNSTCSMSParser.parseTicket(smsText3);
      expect(ticket3.passengerInfo?.seatNumber, equals('20,21'));
      expect(ticket3.numberOfSeats, equals(2));
    });

    test('should handle different class formats', () {
      // Test NON AC LOWER BERTH SEATER
      const smsText1 = 'Class:NON AC LOWER BERTH SEATER , Boarding';
      final ticket1 = TNSTCSMSParser.parseTicket(smsText1);
      expect(ticket1.classOfService, equals('NON AC LOWER BERTH SEATER'));

      // Test AC SLEEPER SEATER
      const smsText2 = 'Class:AC SLEEPER SEATER , Boarding';
      final ticket2 = TNSTCSMSParser.parseTicket(smsText2);
      expect(ticket2.classOfService, equals('AC SLEEPER SEATER'));

      // Test NON AC LOWER BIRTH SEATER (with typo)
      const smsText3 = 'Class:NON AC LOWER BIRTH SEATER , Boarding';
      final ticket3 = TNSTCSMSParser.parseTicket(smsText3);
      expect(ticket3.classOfService, equals('NON AC LOWER BIRTH SEATER'));
    });

    test('should handle different boarding point formats', () {
      // Test single word boarding point
      const smsText1 = 'Boarding at:KUMBAKONAM . For e-Ticket';
      final ticket1 = TNSTCSMSParser.parseTicket(smsText1);
      expect(ticket1.passengerPickupPoint, equals('KUMBAKONAM'));

      // Test boarding point with brackets
      const smsText2 = 'Boarding at:KOTTIVAKKAM(RTO OFFICE) . For e-Ticket';
      final ticket2 = TNSTCSMSParser.parseTicket(smsText2);
      expect(ticket2.passengerPickupPoint, equals('KOTTIVAKKAM(RTO OFFICE)'));
    });

    test('should parse complete SMS with all fields', () {
      // Test the original SMS format
      const originalSms = 'TNSTC Corporation:SETC , PNR NO.:T60856763 , '
          'From:CHENNAI-PT DR. M.G.R. BS To KUMBAKONAM , '
          'Trip Code:2300CHEKUMLB , Journey Date:10/01/2025 , Time:23:55 , '
          'Seat No.:4 UB, .Class:NON AC LOWER BIRTH SEATER , '
          'Boarding at:KOTTIVAKKAM(RTO OFFICE) . For e-Ticket: Download from '
          'View Ticket. Please carry your photo ID during journey. T&C apply. '
          'https://www.radiantinfo.com';

      final originalTicket = TNSTCSMSParser.parseTicket(originalSms);

      // Test the new SMS format with comma before time
      const newSms = 'TNSTC Corporation:SETC , PNR NO.:T69705233 , '
          'From:KUMBAKONAM To CHENNAI-PT DR. M.G.R. BS , '
          'Trip Code:2100KUMCHELB , Journey Date:21/10/2025 , '
          'Time:,21:00 , Seat No.:4LB .Class:NON AC LOWER BERTH SEATER , '
          'Boarding at:KUMBAKONAM . For e-Ticket: Download from View Ticket. '
          'Please carry your photo ID during journey. T&C apply. '
          'https://www.radiantinfo.com';

      final newTicket = TNSTCSMSParser.parseTicket(newSms);

      // Verify both formats parse correctly
      expect(originalTicket.serviceStartTime, equals('23:55'));
      expect(newTicket.serviceStartTime, equals('21:00'));

      expect(originalTicket.corporation, equals('SETC'));
      expect(newTicket.corporation, equals('SETC'));

      expect(originalTicket.pnrNumber, equals('T60856763'));
      expect(newTicket.pnrNumber, equals('T69705233'));
    });
  });

  group('TNSTC PDF Parser Tests', () {
    test('should parse PDF format with dash separators', () {
      const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Date of Journey : 15-03-2025
Route No : 123ABC
Service Start Place : CHENNAI CENTRAL
Service End Place : COIMBATORE
Service Start Time : 14:30
Class of Service : AC Seater
No. of Seats : 2
Total Fare : 450.00
Trip Code : TEST123
      ''';

      final ticket = TNSTCPDFParser.parseTicket(pdfText);

      expect(ticket.corporation, equals('SETC'));
      expect(ticket.pnrNumber, equals('T12345678'));
      expect(ticket.journeyDate?.day, equals(15));
      expect(ticket.journeyDate?.month, equals(3));
      expect(ticket.journeyDate?.year, equals(2025));
      expect(ticket.routeNo, equals('123ABC'));
      expect(ticket.serviceStartPlace, equals('CHENNAI CENTRAL'));
      expect(ticket.serviceEndPlace, equals('COIMBATORE'));
      expect(ticket.serviceStartTime, equals('14:30'));
      expect(ticket.classOfService, equals('AC Seater'));
      expect(ticket.numberOfSeats, equals(2));
      expect(ticket.totalFare, equals(450.00));
      expect(ticket.tripCode, equals('TEST123'));
    });

    test('should parse PDF format with slash separators', () {
      const pdfText = '''
Corporation : TNSTC
PNR Number : T87654321
Date of Journey : 20/04/2025
Route No : 456DEF
Total Fare : 300.50
No. of Seats : 1
      ''';

      final ticket = TNSTCPDFParser.parseTicket(pdfText);

      expect(ticket.corporation, equals('TNSTC'));
      expect(ticket.pnrNumber, equals('T87654321'));
      expect(ticket.journeyDate?.day, equals(20));
      expect(ticket.journeyDate?.month, equals(4));
      expect(ticket.journeyDate?.year, equals(2025));
      expect(ticket.numberOfSeats, equals(1));
      expect(ticket.totalFare, equals(300.50));
    });

    test('should handle empty PDF text gracefully', () {
      const pdfText = '';
      final ticket = TNSTCPDFParser.parseTicket(pdfText);

      expect(ticket.corporation, equals(''));
      expect(ticket.pnrNumber, equals(''));
      expect(ticket.numberOfSeats, equals(1)); // Default value
      expect(ticket.totalFare, equals(0.0)); // Default value
      expect(ticket.journeyDate, isNotNull); // Should be current date
    });

    test('should handle malformed numbers gracefully', () {
      const pdfText = '''
Corporation : SETC
No. of Seats : invalid
Total Fare : not_a_number
      ''';

      final ticket = TNSTCPDFParser.parseTicket(pdfText);

      expect(ticket.numberOfSeats, equals(1)); // Default value
      expect(ticket.totalFare, equals(0.0)); // Default value
    });

    test('should parse passenger info correctly', () {
      const pdfText = '''
Corporation : SETC
Name    Age    Adult/Child    Gender    Seat No.
John Doe    30
Adult
M
15A
      ''';

      final ticket = TNSTCPDFParser.parseTicket(pdfText);

      expect(ticket.passengerInfo?.name, equals('John Doe'));
      expect(ticket.passengerInfo?.type, equals('Adult'));
      expect(ticket.passengerInfo?.gender, equals('M'));
    });
  });

  group('Date Parsing Tests', () {
    test('should handle various date formats', () {
      // Test with SMS parser (uses / separator)
      const smsText1 = 'Journey Date:15/03/2025';
      final smsTicket = TNSTCSMSParser.parseTicket(smsText1);
      expect(smsTicket.journeyDate?.day, equals(15));
      expect(smsTicket.journeyDate?.month, equals(3));
      expect(smsTicket.journeyDate?.year, equals(2025));

      // Test with PDF parser (should handle both / and - separators)
      const pdfText1 = 'Date of Journey : 20-04-2025';
      final pdfTicket1 = TNSTCPDFParser.parseTicket(pdfText1);
      expect(pdfTicket1.journeyDate?.day, equals(20));
      expect(pdfTicket1.journeyDate?.month, equals(4));
      expect(pdfTicket1.journeyDate?.year, equals(2025));

      const pdfText2 = 'Date of Journey : 25/06/2025';
      final pdfTicket2 = TNSTCPDFParser.parseTicket(pdfText2);
      expect(pdfTicket2.journeyDate?.day, equals(25));
      expect(pdfTicket2.journeyDate?.month, equals(6));
      expect(pdfTicket2.journeyDate?.year, equals(2025));
    });

    test('should handle invalid dates gracefully', () {
      const smsText = 'Journey Date:invalid-date';
      final smsTicket = TNSTCSMSParser.parseTicket(smsText);
      expect(smsTicket.journeyDate, isNotNull);
      // Should fallback to current date

      const pdfText = 'Date of Journey : 32/13/2025'; // Invalid date
      final pdfTicket = TNSTCPDFParser.parseTicket(pdfText);
      expect(pdfTicket.journeyDate, isNotNull);
      // Should fallback to current date
    });
  });

  group('SMS Service Integration Tests', () {
    test('should convert old parser to new TNSTCTicketModel', () {
      const smsText = 'TNSTC Corporation:SETC , PNR NO.:T69705233 , '
          'From:KUMBAKONAM To CHENNAI-PT DR. M.G.R. BS , '
          'Trip Code:2100KUMCHELB , Journey Date:21/10/2025 , '
          'Time:,21:00 , Seat No.:4LB .Class:NON AC LOWER BERTH SEATER , '
          'Boarding at:KUMBAKONAM . For e-Ticket: Download from View Ticket. '
          'Please carry your photo ID during journey. T&C apply. '
          'https://www.radiantinfo.com';

      final smsService = SMSService();
      final ticketModel = smsService.parseTicket(smsText);

      // Test basic fields
      expect(ticketModel.corporation, equals('SETC'));
      expect(ticketModel.pnrNumber, equals('T69705233'));
      expect(ticketModel.serviceStartPlace, equals('KUMBAKONAM'));
      expect(ticketModel.serviceEndPlace, equals('CHENNAI-PT DR. M.G.R. BS'));
      expect(ticketModel.tripCode, equals('2100KUMCHELB'));
      expect(ticketModel.serviceStartTime, equals('21:00'));
      expect(ticketModel.classOfService, equals('NON AC LOWER BERTH SEATER'));

      // Test date parsing
      expect(ticketModel.journeyDate?.day, equals(21));
      expect(ticketModel.journeyDate?.month, equals(10));
      expect(ticketModel.journeyDate?.year, equals(2025));

      // Test passenger info conversion
      expect(ticketModel.passengers.length, equals(1));
      expect(ticketModel.passengers.first.seatNumber, equals('4LB'));
      expect(ticketModel.passengers.first.type, equals('Adult'));

      // Test convenience getters
      expect(ticketModel.displayPnr, equals('T69705233'));
      expect(ticketModel.displayFrom, equals('KUMBAKONAM'));
      expect(ticketModel.displayTo, equals('CHENNAI-PT DR. M.G.R. BS'));
      expect(ticketModel.displayClass, equals('NON AC LOWER BERTH SEATER'));
      expect(ticketModel.displayDate, equals('21/10/2025'));
      expect(ticketModel.seatNumbers, equals('4LB'));
    });

    test('should handle multiple passengers in seat numbers', () {
      const smsText = 'TNSTC Corporation:SETC , PNR NO.:T12345 , '
          'Seat No.:20,21, .Class:AC SLEEPER SEATER';

      final smsService = SMSService();
      final ticketModel = smsService.parseTicket(smsText);

      expect(ticketModel.passengers.length, equals(1));
      expect(ticketModel.passengers.first.seatNumber, equals('20,21'));
      expect(ticketModel.seatNumbers, equals('20,21'));
      expect(ticketModel.numberOfSeats, equals(2));
    });

    test('should handle empty SMS gracefully with new model', () {
      const smsText = '';

      final smsService = SMSService();
      final ticketModel = smsService.parseTicket(smsText);

      expect(ticketModel.corporation, isEmpty);
      expect(ticketModel.pnrNumber, isEmpty);
      // Empty SMS still creates a default passenger with empty values
      expect(ticketModel.passengers.length, equals(1));
      expect(ticketModel.passengers.first.name, isEmpty);
      expect(ticketModel.passengers.first.seatNumber, isEmpty);
      expect(ticketModel.displayPnr, equals('Unknown'));
      expect(ticketModel.displayFrom, equals('Unknown'));
      expect(ticketModel.displayTo, equals('Unknown'));
      expect(ticketModel.displayClass, equals('Unknown'));
      expect(ticketModel.displayFare, equals('₹0.00'));
      expect(ticketModel.seatNumbers, isEmpty);
    });

    test('should test model properties', () {
      const smsText = 'TNSTC Corporation:SETC , PNR NO.:T69705233 , '
          'From:KUMBAKONAM To CHENNAI-PT DR. M.G.R. BS , '
          'Time:,21:00 , Journey Date:21/10/2025';

      final smsService = SMSService();
      final ticketModel = smsService.parseTicket(smsText);

      // Test model properties
      expect(ticketModel.corporation, isNotNull);
      expect(ticketModel.pnrNumber, isNotNull);
      expect(ticketModel.serviceStartPlace, isNotNull);
      expect(ticketModel.serviceEndPlace, isNotNull);
      expect(ticketModel.serviceStartTime, isNotNull);
      expect(ticketModel.journeyDate, isNotNull);
    });

    test('should handle fare conversion properly', () {
      // SMS format typically doesn't include fare, so it should be null
      const smsText = 'TNSTC Corporation:SETC , PNR NO.:T12345';

      final smsService = SMSService();
      final ticketModel = smsService.parseTicket(smsText);

      expect(ticketModel.totalFare, isNull);
      expect(ticketModel.displayFare, equals('₹0.00'));
    });
  });

  group('Edge Case Tests', () {
    test('should handle time parsing with various formats', () {
      final testCases = [
        {'input': 'Time:21:00', 'expected': '21:00'},
        {'input': 'Time:,21:00', 'expected': '21:00'},
        {'input': 'Time: 21:00', 'expected': '21:00'},
        {'input': 'Time: ,21:00', 'expected': '21:00'},
        {'input': 'Time:, 21:00', 'expected': '21:00'},
        {'input': 'Time : , 21:00', 'expected': '21:00'},
        {'input': 'Time:10/10/2024,23:55', 'expected': '23:55'}, // Date prefix
      ];

      for (final testCase in testCases) {
        final ticket = TNSTCSMSParser.parseTicket(testCase['input']!);
        expect(ticket.serviceStartTime, equals(testCase['expected']),
            reason: 'Failed for input: ${testCase['input']}');
      }
    });

    test('should handle seat number extraction with various formats', () {
      final testCases = [
        {'input': 'Seat No.:4LB .Class:NON AC', 'expected': '4LB', 'count': 1},
        {
          'input': 'Seat No.:4 UB, .Class:NON AC',
          'expected': '4 UB',
          'count': 1
        },
        {'input': 'Seat No.:20,21, .Class:AC', 'expected': '20,21', 'count': 2},
        {
          'input': 'Seat No.:1A,2A,3A, .Class:SLEEPER',
          'expected': '1A,2A,3A',
          'count': 3
        },
        {
          'input': 'Seat No.: .Class:AC',
          'expected': '',
          'count': 1
        }, // Empty seat
        {
          'input': 'Seat No.:36-UB#10 .Class:NON AC',
          'expected': '36-UB#10',
          'count': 1
        }, // Complex format
        {
          'input': 'Seat No.:13UB .Class:NON AC',
          'expected': '13UB',
          'count': 1
        }, // No space
        {
          'input': 'Seat No.:12, .Class:NON AC',
          'expected': '12',
          'count': 1
        }, // Trailing comma
      ];

      for (final testCase in testCases) {
        final ticket = TNSTCSMSParser.parseTicket(testCase['input']! as String);
        expect(ticket.passengerInfo?.seatNumber, equals(testCase['expected']),
            reason: 'Seat number failed for input: ${testCase['input']}');
        expect(ticket.numberOfSeats, equals(testCase['count']! as int),
            reason: 'Seat count failed for input: ${testCase['input']}');
      }
    });
  });

  group('Real SMS Data Tests', () {
    test('should parse SMS with date prefix in time field', () {
      const smsText = 'TNSTC Corporation:SETC, PNR NO.:T58823886, '
          'From:CHENNAI-PT Dr.M.G.R. BS To KUMBAKONAM, '
          'Trip Code:2300CHEKUMLB, Journey Date:10/10/2024, '
          'Time:10/10/2024,23:55, Seat No.:4LB.Class:NON AC LOWER BIRTH SEATER, '
          'Boarding at:KOTTIVAKKAM(RTO OFFICE).';

      final ticket = TNSTCSMSParser.parseTicket(smsText);

      expect(ticket.corporation, equals('SETC'));
      expect(ticket.pnrNumber, equals('T58823886'));
      expect(ticket.serviceStartPlace, equals('CHENNAI-PT Dr.M.G.R. BS'));
      expect(ticket.serviceEndPlace, equals('KUMBAKONAM'));
      expect(ticket.serviceStartTime,
          equals('23:55')); // Should extract time correctly
      expect(ticket.passengerInfo?.seatNumber, equals('4LB'));
      expect(ticket.classOfService, equals('NON AC LOWER BIRTH SEATER'));
    });

    test('should parse SMS with trailing comma in seat number', () {
      const smsText = 'TNSTC Corporation:SETC, PNR NO.:T58825236, '
          'From:KUMBAKONAM To CHENNAI KALAIGNAR CBT, '
          'Trip Code:2030KUMKCBNS, Journey Date:13/10/2024, '
          'Time:20:30, Seat No.:12,.Class:NON AC SLEEPER SEATER, '
          'Boarding at:KUMBAKONAM.';

      final ticket = TNSTCSMSParser.parseTicket(smsText);

      expect(ticket.corporation, equals('SETC'));
      expect(ticket.pnrNumber, equals('T58825236'));
      expect(ticket.serviceStartPlace, equals('KUMBAKONAM'));
      expect(ticket.serviceEndPlace, equals('CHENNAI KALAIGNAR CBT'));
      expect(ticket.serviceStartTime, equals('20:30'));
      expect(ticket.passengerInfo?.seatNumber,
          equals('12')); // Should remove trailing comma
      expect(ticket.classOfService, equals('NON AC SLEEPER SEATER'));
    });

    test('should parse SMS with complex seat number format', () {
      const smsText = 'TNSTC Corporation:SETC , PNR NO.:T62602262 , '
          'From:CHENNAI-PT DR. M.G.R. BS To KUMBAKONAM , '
          'Trip Code:2300CHEKUMLB , Journey Date:17/01/2025 , '
          'Time:,23:55 , Seat No.:36-UB#10 .Class:NON AC LOWER BIRTH SEATER';

      final ticket = TNSTCSMSParser.parseTicket(smsText);

      expect(ticket.corporation, equals('SETC'));
      expect(ticket.pnrNumber, equals('T62602262'));
      expect(ticket.serviceStartTime, equals('23:55'));
      expect(ticket.passengerInfo?.seatNumber, equals('36-UB#10'));
      expect(ticket.classOfService, equals('NON AC LOWER BIRTH SEATER'));
    });

    test('should parse SMS with no space in seat number', () {
      const smsText = 'TNSTC Corporation:SETC , PNR NO.:T68439967 , '
          'From:CHENNAI-PT DR. M.G.R. BS To KUMBAKONAM , '
          'Trip Code:2200CHEKUMLB , Journey Date:14/08/2025 , '
          'Time:,22:55 , Seat No.:13UB .Class:NON AC LOWER BERTH SEATER';

      final ticket = TNSTCSMSParser.parseTicket(smsText);

      expect(ticket.corporation, equals('SETC'));
      expect(ticket.pnrNumber, equals('T68439967'));
      expect(ticket.serviceStartTime, equals('22:55'));
      expect(ticket.passengerInfo?.seatNumber,
          equals('13UB')); // No space between number and letters
      expect(ticket.classOfService, equals('NON AC LOWER BERTH SEATER'));
    });

    test('should parse SMS from different corporation', () {
      const smsText = 'TNSTC Corporation:COIMBATORE , PNR NO.:U70109781 , '
          'From:KUMBAKONAM To COIMBATORE , Trip Code:0400KUMCOICC01L , '
          'Journey Date:30/08/2025 , Time:,04:00 , Seat No.:24 .Class:DELUXE 3X2';

      final ticket = TNSTCSMSParser.parseTicket(smsText);

      expect(ticket.corporation, equals('COIMBATORE')); // Different corporation
      expect(ticket.pnrNumber, equals('U70109781')); // Different PNR format
      expect(ticket.serviceStartPlace, equals('KUMBAKONAM'));
      expect(ticket.serviceEndPlace, equals('COIMBATORE'));
      expect(ticket.serviceStartTime, equals('04:00'));
      expect(ticket.passengerInfo?.seatNumber, equals('24'));
      expect(ticket.classOfService, equals('DELUXE 3X2'));
    });

    test('should parse multiple seat numbers correctly', () {
      const smsText = 'TNSTC Corporation:SETC , PNR NO.:T63736642 , '
          'From:CHENNAI-PT DR. M.G.R. BS To KUMBAKONAM , '
          'Trip Code:2145CHEKUMAB , Journey Date:11/02/2025 , '
          'Time:22:35 , Seat No.:20,21, .Class:AC SLEEPER SEATER';

      final ticket = TNSTCSMSParser.parseTicket(smsText);

      expect(ticket.corporation, equals('SETC'));
      expect(ticket.pnrNumber, equals('T63736642'));
      expect(ticket.serviceStartTime, equals('22:35'));
      expect(ticket.passengerInfo?.seatNumber, equals('20,21'));
      expect(ticket.numberOfSeats, equals(2)); // Should count two seats
      expect(ticket.classOfService, equals('AC SLEEPER SEATER'));
    });

    test('should handle all edge cases in SMS Service integration', () {
      // Test with complex seat format through SMS Service
      const smsText = 'TNSTC Corporation:COIMBATORE , PNR NO.:U70109781 , '
          'From:KUMBAKONAM To COIMBATORE , Time:,04:00 , '
          'Seat No.:36-UB#10 .Class:DELUXE 3X2';

      final smsService = SMSService();
      final ticketModel = smsService.parseTicket(smsText);

      expect(ticketModel.corporation, equals('COIMBATORE'));
      expect(ticketModel.pnrNumber, equals('U70109781'));
      expect(ticketModel.serviceStartTime, equals('04:00'));
      expect(ticketModel.passengers.first.seatNumber, equals('36-UB#10'));
      expect(ticketModel.seatNumbers, equals('36-UB#10'));
      expect(ticketModel.classOfService, equals('DELUXE 3X2'));

      // Test display methods
      expect(ticketModel.displayPnr, equals('U70109781'));
      expect(ticketModel.displayClass, equals('DELUXE 3X2'));
    });
  });
}
