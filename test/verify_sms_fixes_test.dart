import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/common/application/travel_parser_service.dart';

void main() {
  test('Verify SMS parsing has all latest fixes', () {
    // Typical TNSTC SMS format
    const smsText = '''
TNSTC-SETC Booking Confirmed. PNR: T73309927, Trip: 1315KUMCHEAB, From: KUMBAKONAM, To: CHENNAI-PT DR. M.G.R. BS, DOJ: 18/01/2026, Dept Time: 13:15, Class: AC SLEEPER SEATER, Seat No.: 4UB, Fare: Rs.735.00
''';

    final parser = TNSTCBusParser();
    final ticket = parser.parseTicket(smsText);

    expect(ticket, isNotNull, reason: 'Ticket should be parsed');
    expect(ticket!.extras, isNotNull, reason: 'Ticket should have extras');

    print('Ticket extras:');
    for (final extra in ticket.extras!) {
      print('  ${extra.title}: ${extra.value}');
    }

    // Verify correct field names
    final extraTitles = ticket.extras!.map((e) => e.title).toList();

    // Should have "Service Class", not "Class"
    expect(
      extraTitles.contains('Service Class'),
      isTrue,
      reason: 'Should use "Service Class" not "Class"',
    );
    expect(
      extraTitles.contains('Class'),
      isFalse,
      reason: 'Should NOT have "Class" field',
    );

    // Should NOT have "Boarding"
    expect(
      extraTitles.contains('Boarding'),
      isFalse,
      reason: 'Should NOT have "Boarding" field',
    );

    // Should NOT have "Journey Date" in extras
    expect(
      extraTitles.contains('Journey Date'),
      isFalse,
      reason: 'Should NOT have duplicate "Journey Date" in extras',
    );

    // Should have From and To (UI will filter them)
    expect(
      extraTitles.contains('From'),
      isTrue,
      reason: 'Should have "From" field',
    );
    expect(
      extraTitles.contains('To'),
      isTrue,
      reason: 'Should have "To" field',
    );

    // Should have these fields
    expect(extraTitles.contains('Provider'), isTrue);
    expect(extraTitles.contains('Trip Code'), isTrue);
    expect(extraTitles.contains('Seat'), isTrue);
    expect(extraTitles.contains('Departure Time'), isTrue);
    expect(extraTitles.contains('Source Type'), isTrue);

    // Verify Source Type value
    final sourceType = ticket.extras!.firstWhere(
      (e) => e.title == 'Source Type',
    );
    expect(sourceType.value, 'SMS');
  });
}
