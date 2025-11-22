import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_sms_parser.dart';

void main() {
  group('IRCTCParser SMS Parser', () {
    late IRCTCSMSParser irctcParser;

    setUp(() {
      irctcParser = IRCTCSMSParser();
    });

    // ----------------------------------------------------------------------
    // 1. CANCELLED TICKET
    // ----------------------------------------------------------------------
    test('should parse cancelled IRCTC ticket to Ticket model correctly', () {
      const smsText =
          'PNR 4321751237 cancelled being Waitlist after chart preparation, '
          'Amount 590 will be refunded in your account within 3-4 days.-IRCTC';

      final ticket = irctcParser.parseTicket(smsText);

      expect(ticket, isNotNull);

      // Primary info
      expect(ticket.ticketId, equals('4321751237'));
      expect(ticket.primaryText, equals(' → ')); // No route available, correct.
      expect(ticket.secondaryText, equals('Train  •  • '));

      // Tags
      final pnrTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'confirmation_number',
      );
      expect(pnrTag?.value, equals('4321751237'));

      final fareTag = ticket.tags?.firstWhere((t) => t.icon == 'attach_money');
      expect(fareTag?.value, equals('₹590.00')); // Uses new fare extraction

      // Extras
      expect(
        ticket.extras?.firstWhere((e) => e.title == 'Fare').value,
        equals('590.00'),
      );

      // Status
      final statusTag = ticket.tags?.firstWhere((t) => t.icon == 'info');
      expect(statusTag?.value?.toLowerCase(), contains('cancel'));
    });

    // ----------------------------------------------------------------------
    // 2. NORMAL CONFIRMED TICKET
    // ----------------------------------------------------------------------
    test('should parse standard IRCTC ticket to Ticket model correctly', () {
      const smsText =
          'PNR:4424909275,TRN:12291,DOJ:24-10-25,SL,YPR-MAS,DP:22:45,'
          'Boarding at YPR only,\n'
          'MAGESH K,S2 24,\n'
          'Fare:270,C Fee:11.8+PG.This rail travel is insured.\n'
          '-IRCTC';

      final ticket = irctcParser.parseTicket(smsText);

      expect(ticket, isNotNull);

      // Generic Ticket Fields
      expect(ticket.ticketId, equals('4424909275'));
      expect(ticket.primaryText, equals('YPR → MAS'));
      expect(ticket.secondaryText, equals('Train 12291 • SL • MAGESH K'));

      // startTime (DOJ + DP)
      expect(ticket.startTime.year, equals(2025));
      expect(ticket.startTime.month, equals(10));
      expect(ticket.startTime.day, equals(24));
      expect(ticket.startTime.hour, equals(22));
      expect(ticket.startTime.minute, equals(45));

      // location
      expect(ticket.location, equals('YPR'));

      // tag: PNR
      final pnrTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'confirmation_number',
      );
      expect(pnrTag?.value, equals('4424909275'));

      // tag: Train No
      final trainTag = ticket.tags?.firstWhere((t) => t.icon == 'train');
      expect(trainTag?.value, equals('12291'));

      // tag: Class
      final classTag = ticket.tags?.firstWhere((t) => t.icon == 'event_seat');
      expect(classTag?.value, equals('SL'));

      // tag: Fare
      final fareTag = ticket.tags?.firstWhere((t) => t.icon == 'attach_money');
      expect(fareTag?.value, equals('₹270.00'));

      // EXTRAS — Passenger
      expect(
        ticket.extras?.firstWhere((e) => e.title == 'Passenger').value,
        equals('MAGESH K'),
      );

      // EXTRAS — Boarding
      expect(
        ticket.extras?.firstWhere((e) => e.title == 'Boarding').value,
        equals('YPR'),
      );

      // EXTRAS — Date of Journey
      expect(
        ticket.extras?.firstWhere((e) => e.title == 'Date of Journey').value,
        equals('2025-10-24'),
      );

      // EXTRAS — Fare
      expect(
        ticket.extras?.firstWhere((e) => e.title == 'Fare').value,
        equals('270.00'),
      );

      // EXTRAS — IRCTC Fee
      expect(
        ticket.extras?.firstWhere((e) => e.title == 'IRCTC Fee').value,
        equals('11.80'),
      );
    });

    // ----------------------------------------------------------------------
    // 3. WAITLISTED TICKET
    // ----------------------------------------------------------------------
    test('should parse waitlisted IRCTC ticket to Ticket model correctly', () {
      const smsText =
          'PNR:4126774243,TRN:16021,DOJ:30-11-25,SL,TRL-SBC,DP:21:55,'
          'Boarding at TRL only,\n'
          'MAGESH K,WL 31,\n'
          'Fare:240,C Fee:17.7+PG+AGENT CHGS, IF ANY\n'
          '-IRCTC';

      final ticket = irctcParser.parseTicket(smsText);

      expect(ticket, isNotNull);

      expect(ticket.primaryText, equals('TRL → SBC'));

      // Status Tag
      final statusTag = ticket.tags?.firstWhere((t) => t.icon == 'info');
      // Status extraction now supports the number
      expect(statusTag?.value, contains('WL 31'));

      // Fare Tag
      final fareTag = ticket.tags?.firstWhere((t) => t.icon == 'attach_money');
      expect(fareTag?.value, equals('₹240.00'));
    });

    // ----------------------------------------------------------------------
    // 4. MULTI PASSENGER TICKET
    // ----------------------------------------------------------------------
    test(
      'should parse multi-passenger IRCTC ticket to Ticket model correctly',
      () {
        const smsText =
            'PNR:4621385568,TRN:12692,DOJ:23-11-24,SL,SMVB-MAS,DP:23:00,'
            'Boarding at SMVB only,\n'
            'HARISH ANBALAGAN+2,S4 15,S4 16,S4 9,\n'
            'Fare:780,C Fee:11.8+PG\n'
            'QR Code URL:https://qr.indianrail.gov.in?q=M60LCLB0 -IRCTC';

        final ticket = irctcParser.parseTicket(smsText);

        expect(ticket, isNotNull);

        // Passenger extraction is now safer and works
        expect(
          ticket.secondaryText,
          equals('Train 12692 • SL • HARISH ANBALAGAN+2'),
        );

        final fareTag = ticket.tags?.firstWhere(
          (t) => t.icon == 'attach_money',
        );
        expect(fareTag?.value, equals('₹780.00'));
      },
    );

    // ----------------------------------------------------------------------
    // 5. OLD-FORMAT SMS
    // ----------------------------------------------------------------------
    test('should parse old-format IRCTC SMS into Ticket model correctly', () {
      const smsText =
          'PNR-4930936485\n'
          'Trn:12679\n'
          'Dt:16-10-25\n'
          'Frm MAS to SA\n'
          'Cls:2S\n'
          'P1-D1,37\n'
          'Chart Prepared';

      final ticket = irctcParser.parseTicket(smsText);

      expect(ticket, isNotNull);

      expect(ticket.primaryText, equals('MAS → SA'));
      expect(ticket.secondaryText, contains('2S'));

      final classTag = ticket.tags?.firstWhere((t) => t.icon == 'event_seat');
      expect(classTag?.value, equals('2S'));

      // The name extraction in this case should now be empty due to lack
      // of a clear name pattern
      expect(
        ticket.extras?.firstWhere((e) => e.title == 'Passenger').value,
        equals(''),
      );
    });
  });
}
