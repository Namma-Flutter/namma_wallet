import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_sms_parser.dart';

void main() {
  group('TNSTCSMSParser Time Parsing Tests', () {
    late TNSTCSMSParser parser;

    setUp(() {
      parser = TNSTCSMSParser();
    });

    test('should parse SETC SMS with time correctly', () {
      const smsText = 'TNSTC Corporation:SETC , PNR NO.:T73309927 , '
          'From:KUMBAKONAM To CHENNAI-PT DR. M.G.R. BS , '
          'Trip Code:1315KUMCHEAB , Journey Date:18/01/2026 , '
          'Time:,13:15 , Seat No.:4UB .Class:AC SLEEPER SEATER , '
          'Boarding at:KUMBAKONAM . For e-Ticket: Download from '
          'View Ticket. Please carry your photo ID during journey. '
          'T&C apply. https://www.radiantinfo.com';

      final ticket = parser.parseTicket(smsText);

      // Test Ticket fields (not TNSTCTicketModel fields)
      expect(ticket.ticketId, equals('T73309927'));
      expect(
        ticket.primaryText,
        equals('KUMBAKONAM → CHENNAI-PT DR. M.G.R. BS'),
      );
      expect(ticket.secondaryText, equals('SETC - 1315KUMCHEAB'));

      // Test startTime (combined from journeyDate + serviceStartTime)
      expect(ticket.startTime.year, equals(2026));
      expect(ticket.startTime.month, equals(1));
      expect(ticket.startTime.day, equals(18));
      expect(ticket.startTime.hour, equals(13));
      expect(ticket.startTime.minute, equals(15));

      expect(ticket.location, equals('KUMBAKONAM'));

      // Test tags
      expect(ticket.tags, isNotNull);
      final tripCodeTag = ticket.tags!.firstWhere(
        (tag) => tag.value == '1315KUMCHEAB',
        orElse: () => throw Exception('Trip code tag not found'),
      );
      expect(tripCodeTag.icon, equals('confirmation_number'));

      final timeTag = ticket.tags!.firstWhere(
        (tag) => tag.value == '13:15',
        orElse: () => throw Exception('Time tag not found'),
      );
      expect(timeTag.icon, equals('access_time'));

      // Test extras (where TNSTC details are stored)
      expect(ticket.extras, isNotNull);

      final pnrExtra = ticket.extras!.firstWhere(
        (extra) => extra.title == 'PNR Number',
        orElse: () => throw Exception('PNR extra not found'),
      );
      expect(pnrExtra.value, equals('T73309927'));

      final tripCodeExtra = ticket.extras!.firstWhere(
        (extra) => extra.title == 'Trip Code',
        orElse: () => throw Exception('Trip Code extra not found'),
      );
      expect(tripCodeExtra.value, equals('1315KUMCHEAB'));

      final departureExtra = ticket.extras!.firstWhere(
        (extra) => extra.title == 'Departure Time',
        orElse: () => throw Exception('Departure Time extra not found'),
      );
      // formatTimeString converts "13:15" to "01:15 PM"
      expect(departureExtra.value, equals('01:15 PM'));

      final providerExtra = ticket.extras!.firstWhere(
        (extra) => extra.title == 'Provider',
        orElse: () => throw Exception('Provider extra not found'),
      );
      expect(providerExtra.value, equals('SETC'));

      final sourceTypeExtra = ticket.extras!.firstWhere(
        (extra) => extra.title == 'Source Type',
        orElse: () => throw Exception('Source Type extra not found'),
      );
      expect(sourceTypeExtra.value, equals('SMS'));
    });

    test('should parse standard TNSTC SMS without SETC correctly', () {
      const smsText =
          'TNSTC Corporation:TNSTC KUMBAKONAM , PNR NO.:T63736642 , '
          'From:CHENNAI-PT DR. M.G.R. BS To KUMBAKONAM , '
          'Trip Code:2145CHEKUMAB , Journey Date:11/02/2025 , Time:22:35 , '
          'Seat No.:20,21, .Class:AC SLEEPER SEATER , '
          'Boarding at:KOTTIVAKKAM(RTO OFFICE) . For e-Ticket: Download from '
          'View Ticket. Please carry your photo ID during journey. T&C apply.';

      final ticket = parser.parseTicket(smsText);

      // Test Ticket fields
      expect(ticket.ticketId, equals('T63736642'));
      expect(
        ticket.primaryText,
        equals('CHENNAI-PT DR. M.G.R. BS → KUMBAKONAM'),
      );
      expect(ticket.secondaryText, equals('TNSTC KUMBAKONAM - 2145CHEKUMAB'));

      // Test startTime
      expect(ticket.startTime.year, equals(2025));
      expect(ticket.startTime.month, equals(2));
      expect(ticket.startTime.day, equals(11));
      expect(ticket.startTime.hour, equals(22));
      expect(ticket.startTime.minute, equals(35));

      expect(ticket.location, equals('KOTTIVAKKAM(RTO OFFICE)'));

      // Verify extras contain the corporation info
      final providerExtra = ticket.extras!.firstWhere(
        (extra) => extra.title == 'Provider',
        orElse: () => throw Exception('Provider extra not found'),
      );
      expect(providerExtra.value, equals('TNSTC KUMBAKONAM'));
    });

    test('should handle SMS with missing time gracefully', () {
      const smsText =
          'TNSTC Corporation:SETC , PNR NO.:T12345678 , '
          'From:CHENNAI To MADURAI , '
          'Trip Code:1234CHEMADAB , Journey Date:20/02/2025 , '
          'Seat No.:5A .Class:SLEEPER , '
          'Boarding at:CHENNAI . For e-Ticket: Download from View Ticket.';

      final ticket = parser.parseTicket(smsText);

      // Should still parse successfully
      expect(ticket.ticketId, equals('T12345678'));
      expect(ticket.primaryText, equals('CHENNAI → MADURAI'));

      // startTime should use journey date with default time (00:00)
      expect(ticket.startTime.year, equals(2025));
      expect(ticket.startTime.month, equals(2));
      expect(ticket.startTime.day, equals(20));
      // Time should default to 00:00 when not provided
      expect(ticket.startTime.hour, equals(0));
      expect(ticket.startTime.minute, equals(0));
    });
  });
}
