import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/features/events/domain/konfhub_ticket_model.dart';

void main() {
  group('KonfHubTicketModel', () {
    test('serialization round-trip', () {
      final model = KonfHubTicketModel(
        bookingId: 'cdda2c1f',
        bookingDate: DateTime(2025, 9, 29),
        attendeeName: 'KEERTHIVASAN S',
        organization: 'Thiran Technologies',
        eventName: 'DevFest 2025 Chennai',
        eventDate: DateTime(2025, 11, 8),
        eventStartTime: DateTime(2025, 11, 8, 9),
        eventEndTime: DateTime(2025, 11, 8, 18),
        ticketName: 'Early Bird Professional',
        location:
            'IIT Madras Research Park, MGR Film City Road, Kanagam, Tharamani, '
            'Chennai, Tamil Nadu, India',
        additionalDetails: {'Food Preference': 'Veg'},
        qrData: 'KONFHUB_TEST_QR_DATA_12345',
      );

      final map = model.toMap();
      final decoded = KonfHubTicketModelMapper.fromMap(map);

      expect(decoded.bookingId, 'cdda2c1f');
      expect(decoded.eventName, 'DevFest 2025 Chennai');
      expect(decoded.additionalDetails?['Food Preference'], 'Veg');
      expect(decoded.qrData, 'KONFHUB_TEST_QR_DATA_12345');
    });

    test('Ticket.fromKonfHub maps qrData to QR Data extras', () {
      const model = KonfHubTicketModel(
        bookingId: 'cdda2c1f',
        eventName: 'DevFest 2025 Chennai',
        qrData: 'KONFHUB_TEST_QR_DATA_12345',
      );

      final ticket = Ticket.fromKonfHub(model);
      final qrExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'QR Data',
      );

      expect(qrExtra, isNotNull);
      expect(qrExtra?.value, 'KONFHUB_TEST_QR_DATA_12345');
    });
  });
}
