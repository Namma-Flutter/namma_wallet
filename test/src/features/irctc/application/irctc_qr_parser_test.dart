// QR payloads are CSV-style with no whitespace between concatenated literals.
// ignore_for_file: missing_whitespace_between_adjacent_strings

import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_qr_parser.dart';

import '../../../../helpers/fake_logger.dart';

void main() {
  late IRCTCQRParser parser;

  setUp(() {
    parser = IRCTCQRParser(logger: FakeLogger());
  });

  group('IRCTCQRParser.isIRCTCQRCode', () {
    test('returns true when PNR marker is present', () {
      expect(parser.isIRCTCQRCode('PNR No.: 1234567890'), isTrue);
    });

    test('returns true when Train No. marker is present', () {
      expect(parser.isIRCTCQRCode('Train No.: 12345'), isTrue);
    });

    test('returns true when IRCTC C Fee marker is present', () {
      expect(parser.isIRCTCQRCode('IRCTC C Fee: 30'), isTrue);
    });

    test('returns false for unrelated content', () {
      expect(parser.isIRCTCQRCode('Hello, world!'), isFalse);
    });
  });

  group('IRCTCQRParser.parseQRCode', () {
    const goodQr =
        'PNR No.:1234567890,'
        'TXN ID:TXN-9999,'
        'Passenger Name:JANE DOE,'
        'Gender:F,'
        'Age:28,'
        'Status:CNF,'
        'Quota:GN,'
        'Train No.:12345,'
        'Train Name:VANDE BHARAT,'
        'Scheduled Departure:05-Jan-2026 06:30:00,'
        'Date Of Journey:05-Jan-2026,'
        'Boarding Station:MAS,'
        'Class:SL (Sleeper),'
        'From:MAS,'
        'To:SBC,'
        'Ticket Fare:1200.50,'
        'IRCTC C Fee:30.00';

    test('extracts all expected fields from a well-formed QR string', () {
      final t = parser.parseQRCode(goodQr);

      expect(t, isNotNull);
      expect(t!.pnrNumber, '1234567890');
      expect(t.transactionId, 'TXN-9999');
      expect(t.passengerName, 'JANE DOE');
      expect(t.gender, 'F');
      expect(t.age, 28);
      expect(t.status, 'CNF');
      expect(t.quota, 'GN');
      expect(t.trainNumber, '12345');
      expect(t.trainName, 'VANDE BHARAT');
      expect(t.fromStation, 'MAS');
      expect(t.toStation, 'SBC');
      expect(t.boardingStation, 'MAS');
      expect(t.travelClass, 'SL (Sleeper)');
      expect(t.dateOfJourney, DateTime(2026, 1, 5));
      expect(t.scheduledDeparture, DateTime(2026, 1, 5, 6, 30));
      expect(t.ticketFare, 1200.50);
      expect(t.irctcFee, 30.0);
    });

    test('keeps class string as-is when there is no parenthesised label', () {
      const qr = 'PNR No.:1,Class:SL';
      final t = parser.parseQRCode(qr);
      expect(t!.travelClass, 'SL');
    });

    test('returns null fields for missing date / datetime values', () {
      const qr = 'PNR No.:1';
      final t = parser.parseQRCode(qr);
      expect(t!.dateOfJourney, isNull);
      expect(t.scheduledDeparture, isNull);
      expect(t.age, isNull);
      expect(t.ticketFare, isNull);
    });

    test('handles unrecognised month gracefully (returns null date)', () {
      const qr = 'PNR No.:1,Date Of Journey:05-Foo-2026';
      final t = parser.parseQRCode(qr);
      expect(t!.dateOfJourney, isNull);
    });

    test('handles malformed datetime gracefully', () {
      const qr = 'PNR No.:1,Scheduled Departure:not-a-datetime';
      final t = parser.parseQRCode(qr);
      expect(t!.scheduledDeparture, isNull);
    });

    test('parses numeric month variant for date', () {
      const qr = 'PNR No.:1,Date Of Journey:05-01-2026';
      final t = parser.parseQRCode(qr);
      expect(t!.dateOfJourney, DateTime(2026, 1, 5));
    });
  });
}
