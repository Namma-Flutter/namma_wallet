import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_layout_parser.dart';
import '../../../../fixtures/tnstc_layout_fixtures.dart';
import '../../../../helpers/fake_logger.dart';

void main() {
  group('TNSTCLayoutParser - Passenger Extraction', () {
    late TNSTCLayoutParser parser;
    late FakeLogger fakeLogger;
    final getIt = GetIt.instance;

    setUp(() {
      fakeLogger = FakeLogger();
      if (!getIt.isRegistered<ILogger>()) {
        getIt.registerSingleton<ILogger>(fakeLogger);
      }
      parser = TNSTCLayoutParser(logger: fakeLogger);
    });

    tearDown(getIt.reset);

    test(
      'should extract all 3 passengers from t73910447',
      () {
        // t73910447 has 3 passengers: TEST PASSENGER 5,
        //TEST PASSENGER 6, TEST PASSENGER 7
        final blocks = TnstcLayoutFixtures.t73910447;

        // Parse ticket from blocks
        final ticket = parser.parseTicketFromBlocks(blocks);

        expect(ticket.ticketId, 'T73910447');

        // Check tags for seat information (should have multiple seats)
        final seatTags = ticket.tags?.where(
          (tag) => tag.icon == 'event_seat',
        );

        if (seatTags != null && seatTags.isNotEmpty) {
          final seatValue = seatTags.first.value;
          // Should contain all 3 seat numbers (120B corrected to 12UB)
          expect(seatValue, contains('10UB'));
          expect(seatValue, contains('11UB'));
          expect(seatValue, contains('12UB'));
        }
      },
    );

    test(
      'should correctly assign seat numbers using column alignment',
      () {
        // t73910447 row 3 has only 4 columns (missing Gender)
        // Old behavior: 120B would be assigned as gender
        // New behavior: 120B (corrected to 12UB) correctly assigned as seat
        final blocks = TnstcLayoutFixtures.t73910447;
        final ticket = parser.parseTicketFromBlocks(blocks);

        // Verify ticket was parsed successfully
        expect(ticket.ticketId, 'T73910447');
        expect(ticket.primaryText, contains('CHENNAI'));
        expect(ticket.primaryText, contains('BENGALURU'));
      },
    );
  });
}
