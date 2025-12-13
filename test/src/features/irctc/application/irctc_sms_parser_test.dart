import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/services/pdf/station_pdf_parser.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_sms_parser.dart';

void main() {
  /// Test group validating IRCTC SMS parser behavior.
  group('IRCTCParser SMS Parser', () {
    /// Parser instance used across tests.
    late IRCTCSMSParser irctcParser;

    /// Initialize parser before each test.
    setUp(() {
      final stationPdfParser = GetIt.I<StationPdfParser>();
      irctcParser = IRCTCSMSParser(stationPdfParser: stationPdfParser);
    });

    /// Validates parsing of CANCELLED IRCTC ticket SMS format.
    test('should parse cancelled IRCTC ticket to Ticket model correctly', () {
      /// Sample cancelled ticket SMS.
      const smsText =
          'PNR 4321751237 cancelled being Waitlist after chart preparation, '
          'Amount 590 will be refunded in your account within 3-4 days.-IRCTC';

      /// Parse SMS text to Ticket model.
      final ticket = irctcParser.parseTicket(smsText);

      expect(ticket, isNotNull);

      // Primary info validations
      expect(ticket.ticketId, equals('4321751237'));
      expect(ticket.primaryText, equals(' → ')); // No route available.
      expect(ticket.secondaryText, equals('Train  •  • '));

      // PNR Tag
      final pnrTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'confirmation_number',
      );
      expect(pnrTag?.value, equals('4321751237'));

      // Fare Tag
      final fareTag = ticket.tags?.firstWhere((t) => t.icon == 'attach_money');
      expect(fareTag?.value, equals('₹590.00')); // New extraction logic

      // Extras (Fare)
      expect(
        ticket.extras?.firstWhere((e) => e.title == 'Fare').value,
        equals('590.00'),
      );

      // Status Tag should indicate cancellation
      final statusTag = ticket.tags?.firstWhere((t) => t.icon == 'info');
      expect(statusTag?.value?.toLowerCase(), contains('cancel'));
    });

    /// Validates parsing of standard IRCTC SMS message.
    test('should parse standard IRCTC ticket to Ticket model correctly', () {
      /// Standard IRCTC SMS with full details.
      const smsText =
          'PNR:4321751237,TRN:12291,DOJ:24-10-25,SL,YPR-MAS,DP:22:45,'
          'Boarding at YPR only,\n'
          'MAGESH K,S2 24,\n'
          'Fare:270,C Fee:11.8+PG.This rail travel is insured.\n'
          '-IRCTC';

      final ticket = irctcParser.parseTicket(smsText);

      expect(ticket, isNotNull);

      // Basic ticket metadata
      expect(ticket.ticketId, equals('4321751237'));
      expect(ticket.primaryText, equals('YPR → MAS'));
      expect(ticket.secondaryText, equals('Train 12291 • SL • MAGESH K'));

      /// Validate parsed start time from DOJ + DP fields.
      expect(ticket.startTime?.year, equals(2025));
      expect(ticket.startTime?.month, equals(10));
      expect(ticket.startTime?.day, equals(24));
      expect(ticket.startTime?.hour, equals(22));
      expect(ticket.startTime?.minute, equals(45));

      /// Boarding station
      expect(ticket.location, equals('YPR'));

      // Tag: PNR
      final pnrTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'confirmation_number',
      );
      expect(pnrTag?.value, equals('4321751237'));

      // Tag: Train Number
      final trainTag = ticket.tags?.firstWhere((t) => t.icon == 'train');
      expect(trainTag?.value, equals('12291'));

      // Tag: Class
      final classTag = ticket.tags?.firstWhere((t) => t.icon == 'event_seat');
      expect(classTag?.value, equals('SL'));

      // Tag: Fare
      final fareTag = ticket.tags?.firstWhere((t) => t.icon == 'attach_money');
      expect(fareTag?.value, equals('₹270.00'));

      // EXTRAS validations
      expect(
        ticket.extras?.firstWhere((e) => e.title == 'Passenger').value,
        equals('MAGESH K'),
      );

      expect(
        ticket.extras?.firstWhere((e) => e.title == 'Boarding').value,
        equals('YPR'),
      );

      expect(
        ticket.extras?.firstWhere((e) => e.title == 'Date of Journey').value,
        equals('24/10/2025'),
      );

      expect(
        ticket.extras?.firstWhere((e) => e.title == 'Fare').value,
        equals('270.00'),
      );

      expect(
        ticket.extras?.firstWhere((e) => e.title == 'IRCTC Fee').value,
        equals('11.80'),
      );
    });

    /// Validates parsing of WAITLISTED IRCTC SMS message.
    test('should parse waitlisted IRCTC ticket to Ticket model correctly', () {
      /// Sample waitlist SMS.
      const smsText =
          'PNR:4126774243,TRN:16021,DOJ:30-11-25,SL,TRL-SBC,DP:21:55,'
          'Boarding at TRL only,\n'
          'MAGESH K,WL 31,\n'
          'Fare:240,C Fee:17.7+PG+AGENT CHGS, IF ANY\n'
          '-IRCTC';

      final ticket = irctcParser.parseTicket(smsText);

      expect(ticket, isNotNull);

      expect(ticket.primaryText, equals('TRL → SBC'));

      // Status tag includes waitlist number
      final statusTag = ticket.tags?.firstWhere((t) => t.icon == 'info');
      expect(statusTag?.value, contains('WL 31'));

      // Fare tag
      final fareTag = ticket.tags?.firstWhere((t) => t.icon == 'attach_money');
      expect(fareTag?.value, equals('₹240.00'));
    });

    /// Validates multi-passenger SMS format.
    test(
      'should parse multi-passenger IRCTC ticket to Ticket model correctly',
      () {
        /// Multi-passenger sample SMS.
        const smsText =
            'PNR:4621385568,TRN:12692,DOJ:23-11-24,SL,SMVB-MAS,DP:23:00,'
            'Boarding at SMVB only,\n'
            'HARISH ANBALAGAN+2,S4 15,S4 16,S4 9,\n'
            'Fare:780,C Fee:11.8+PG\n'
            'QR Code URL:https://qr.indianrail.gov.in?q=M60LCLB0 -IRCTC';

        final ticket = irctcParser.parseTicket(smsText);

        expect(ticket, isNotNull);

        // Secondary text uses first passenger name correctly
        expect(
          ticket.secondaryText,
          equals('Train 12692 • SL • HARISH ANBALAGAN+2'),
        );

        // Fare tag
        final fareTag = ticket.tags?.firstWhere(
          (t) => t.icon == 'attach_money',
        );
        expect(fareTag?.value, equals('₹780.00'));
      },
    );

    /// Validates old-style IRCTC SMS without modern formatting.
    test('should parse old-format IRCTC SMS into Ticket model correctly', () {
      /// Old-format SMS sample.
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

      // Class tag should correctly detect 2S
      final classTag = ticket.tags?.firstWhere((t) => t.icon == 'event_seat');
      expect(classTag?.value, equals('2S'));

      // Old format may not contain passenger name → expect empty string
      expect(
        ticket.extras?.firstWhere((e) => e.title == 'Passenger').value,
        equals(''),
      );
    });
  });
}
