import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/domain/models/extras_model.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_interface.dart';
import 'package:namma_wallet/src/features/home/presentation/all_tickets_view.dart';

class _FakeTicketDAO extends Fake implements ITicketDAO {
  _FakeTicketDAO(this.activeTickets, this.archivedTickets);

  final List<Ticket> activeTickets;
  final List<Ticket> archivedTickets;

  @override
  Future<List<Ticket>> getActiveTickets() async => activeTickets;

  @override
  Future<List<Ticket>> getArchivedTickets() async => archivedTickets;
}

class _FakeHapticService extends Fake implements IHapticService {}

void main() {
  late _FakeTicketDAO ticketDAO;

  final tickets = [
    Ticket(
      ticketId: 'PNR-123',
      primaryText: 'Chennai → Bengaluru',
      secondaryText: 'Train 12608',
      location: 'Chennai Central',
      type: TicketType.train,
      extras: [
        ExtrasModel(title: 'From', value: 'Chennai'),
        ExtrasModel(title: 'To', value: 'Bengaluru'),
      ],
    ),
    const Ticket(
      ticketId: 'EVENT-456',
      primaryText: 'Madurai Film Festival',
      location: 'Madurai',
      type: TicketType.event,
    ),
  ];

  setUp(() async {
    await GetIt.I.reset();
    ticketDAO = _FakeTicketDAO(tickets, []);
    getIt
      ..registerSingleton<ITicketDAO>(ticketDAO)
      ..registerSingleton<IHapticService>(_FakeHapticService());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Future<void> pumpAllTicketsView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(home: AllTicketsView()),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('search filters tickets by route and ticket ID', (tester) async {
    await pumpAllTicketsView(tester);

    expect(find.text('Madurai Film Festival'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('ticketSearchField')),
      'pnr-123',
    );
    await tester.pumpAndSettle();

    expect(find.text('Chennai'), findsOneWidget);
    expect(find.text('Madurai Film Festival'), findsNothing);
    expect(find.text('1 ticket'), findsOneWidget);
  });

  testWidgets('clearing search restores all tickets', (tester) async {
    await pumpAllTicketsView(tester);

    await tester.enterText(
      find.byKey(const Key('ticketSearchField')),
      'bengaluru',
    );
    await tester.pumpAndSettle();
    expect(find.text('Madurai Film Festival'), findsNothing);

    await tester.tap(find.byKey(const Key('clearTicketSearchButton')));
    await tester.pumpAndSettle();

    expect(find.text('Madurai Film Festival'), findsOneWidget);
    expect(find.text('2 tickets'), findsOneWidget);
  });
}
