import 'package:flutter_test/flutter_test.dart';
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
      );

      final map = model.toMap();
      final decoded = KonfHubTicketModelMapper.fromMap(map);

      expect(decoded.bookingId, 'cdda2c1f');
      expect(decoded.eventName, 'DevFest 2025 Chennai');
      expect(decoded.additionalDetails?['Food Preference'], 'Veg');
    });
  });
}
