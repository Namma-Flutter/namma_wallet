import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_api_ticket_parser.dart';
import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart';

import '../../../../helpers/fake_logger.dart';

void main() {
  final getIt = GetIt.instance;

  setUp(() {
    if (!getIt.isRegistered<ILogger>()) {
      getIt.registerSingleton<ILogger>(FakeLogger());
    }
  });

  tearDown(getIt.reset);

  group('TNSTCApiTicketParser', () {
    final parser = TNSTCApiTicketParser();

    test('should parse HH:mm:ss API time into ticket start time', () {
      final model = TNSTCTicketModel(
        pnrNumber: 'T76296907',
        journeyDate: DateTime(2026, 2),
        serviceStartTime: '22:20:00',
      );

      final ticket = parser.parse(model);

      expect(ticket.startTime, isNotNull);
      expect(ticket.startTime!.hour, 22);
      expect(ticket.startTime!.minute, 20);
    });

    test('should normalize API seat numbers before ticket mapping', () {
      const model = TNSTCTicketModel(
        pnrNumber: 'T76296907',
        smsSeatNumbers: ',4UB',
      );

      final ticket = parser.parse(model);
      final seatExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Seat Number',
      );
      final seatTag = ticket.tags?.firstWhere(
        (t) => t.icon == 'event_seat',
      );

      expect(seatExtra?.value, '4UB');
      expect(seatTag?.value, '4UB');
    });

    test(
      'should fallback location to from place when pickup point is missing',
      () {
      const model = TNSTCTicketModel(
        pnrNumber: 'T76296907',
        serviceStartPlace: 'KUMBAKONAM',
      );

      final ticket = parser.parse(model);

      expect(ticket.location, 'KUMBAKONAM');
      },
    );

    test('should preserve passenger name in extras', () {
      const model = TNSTCTicketModel(
        pnrNumber: 'T76296907',
        passengers: [PassengerInfo(name: 'HarishAnbalagan')],
      );

      final ticket = parser.parse(model);
      final passengerExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Passenger',
      );

      expect(passengerExtra?.value, 'HarishAnbalagan');
    });
  });
}
