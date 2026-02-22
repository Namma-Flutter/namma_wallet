import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/irctc/domain/irctc_ticket_model.dart';

import '../../../../helpers/fake_logger.dart';

void main() {
  setUpAll(() {
    GetIt.instance.registerSingleton<ILogger>(FakeLogger());
  });

  tearDownAll(() async {
    await GetIt.instance.reset();
  });

  // ... tests ...
  test(
    'Ticket.fromIRCTC with valid dates should populate startTime and extras',
    () {
      final model = IRCTCTicket(
        pnrNumber: '1234567890',
        passengerName: 'John Doe',
        age: 30,
        status: 'CNF',
        trainNumber: '12601',
        trainName: 'Mangalore Mail',
        boardingStation: 'MAS',
        fromStation: 'MAS',
        toStation: 'MAQ',
        dateOfJourney: DateTime(2023, 10, 25),
        scheduledDeparture: DateTime(2023, 10, 25, 20, 15),
        ticketFare: 500,
        irctcFee: 20,
      );

      final ticket = Ticket.fromIRCTC(model);

      expect(ticket.startTime, DateTime(2023, 10, 25, 20, 15));
      // Verify extras also present
      expect(ticket.extras?.any((e) => e.title == 'Date of Journey'), isTrue);
      expect(ticket.extras?.any((e) => e.title == 'Departure'), isTrue);
    },
  );

  test(
    'Ticket.fromIRCTC with null dates should have null startTime '
    'and missing extras',
    () {
      const model = IRCTCTicket(
        pnrNumber: '1234567890',
        passengerName: 'Jane Doe',
        age: 25,
        status: 'WL',
        trainNumber: '12602',
        trainName: 'Chennai Mail',
        boardingStation: 'MAQ',
        fromStation: 'MAQ',
        toStation: 'MAS',
      );

      final ticket = Ticket.fromIRCTC(model);

      expect(ticket.startTime, isNull);

      // Verify extras related to date/time are missing
      expect(ticket.extras?.any((e) => e.title == 'Date of Journey'), isFalse);
      expect(ticket.extras?.any((e) => e.title == 'Departure'), isFalse);
    },
  );
}
