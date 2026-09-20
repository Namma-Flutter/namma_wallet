import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/irctc/domain/irctc_ticket_model.dart';

void main() {
  group('IRCTCTicket.toReadableString', () {
    test('renders all populated fields', () {
      const ticket = IRCTCTicket(
        pnrNumber: '1234567890',
        passengerName: 'Jane Doe',
        age: 28,
        status: 'CNF',
        trainNumber: '12345',
        trainName: 'Vande Bharat',
        fromStation: 'MAS',
        toStation: 'SBC',
        ticketFare: 1200,
        irctcFee: 30,
        gender: 'F',
        travelClass: '3A',
        seatNumber: 'B1-23',
        arrivalTime: '06:30',
        distance: 360,
      );

      final readable = ticket.toReadableString();

      expect(readable, contains('PNR: 1234567890'));
      expect(readable, contains('Jane Doe'));
      expect(readable, contains('12345'));
      expect(readable, contains('Vande Bharat'));
      expect(readable, contains('MAS → SBC'));
      expect(readable, contains('360 km'));
      expect(readable, contains('CNF'));
      expect(readable, contains('₹1200.0 + ₹30.0'));
      expect(readable, contains('B1-23'));
    });

    test('renders Unknown placeholders when nullable fields are missing', () {
      const ticket = IRCTCTicket();

      final readable = ticket.toReadableString();

      expect(readable, contains('Date: Unknown'));
      expect(readable, contains('Arrival: Unknown'));
      expect(readable, contains('Distance: Unknown'));
      expect(readable, contains('Booking Date: Unknown'));
      expect(readable, contains('Seat: Unknown'));
    });

    test('zero-pads day/month in journey and booking dates', () {
      final ticket = IRCTCTicket(
        dateOfJourney: DateTime(2026, 1, 5),
        bookingDate: DateTime(2026, 3, 9),
      );

      final readable = ticket.toReadableString();

      expect(readable, contains('Date: 05-01-2026'));
      expect(readable, contains('Booking Date: 09-03-2026'));
    });
  });
}
