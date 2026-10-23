import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/domain/models/extras_model.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_interface.dart';
import 'package:namma_wallet/src/common/services/ticket_change_notifier.dart';
import 'package:namma_wallet/src/features/home/presentation/home_view.dart';
import 'package:namma_wallet/src/features/home/presentation/ticket_search_view.dart';
import 'package:namma_wallet/src/features/receive/domain/sms_queue_service_interface.dart';

class _FakeTicketDAO extends Fake implements ITicketDAO {
  _FakeTicketDAO(this.tickets);

  final List<Ticket> tickets;

  @override
  Future<List<Ticket>> getActiveTickets() async => tickets;

  @override
  Future<List<Ticket>> getArchivedTickets() async => [];
}

class _FakeHapticService extends Fake implements IHapticService {}

class _FakeSmsQueueService extends Fake implements ISMSQueueService {
  @override
  final ValueNotifier<bool> isParsing = ValueNotifier(false);
}

void main() {
  final tickets = [
    Ticket(
      ticketId: 'PNR-123',
      primaryText: 'Chennai to Bengaluru',
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

  late _FakeSmsQueueService smsQueueService;

  setUp(() async {
    await GetIt.I.reset();
    smsQueueService = _FakeSmsQueueService();
    getIt
      ..registerSingleton<ITicketDAO>(_FakeTicketDAO(tickets))
      ..registerSingleton<IHapticService>(_FakeHapticService())
      ..registerSingleton<TicketChangeNotifier>(TicketChangeNotifier())
      ..registerSingleton<ISMSQueueService>(smsQueueService);
  });

  tearDown(() async {
    smsQueueService.isParsing.dispose();
    await GetIt.I.reset();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      initialLocation: AppRoute.home.path,
      routes: [
        GoRoute(
          path: AppRoute.home.path,
          name: AppRoute.home.name,
          builder: (context, state) => const HomeView(),
        ),
        GoRoute(
          path: AppRoute.ticketSearch.path,
          name: AppRoute.ticketSearch.name,
          builder: (context, state) => const TicketSearchView(),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  testWidgets('tapping Home search opens a separate ticket search screen', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Train 12608'), findsOneWidget);
    await tester.tap(find.byKey(const Key('homeTicketSearchField')));
    await tester.pumpAndSettle();

    expect(find.text('Search tickets'), findsOneWidget);
    expect(find.byKey(const Key('ticketSearchInput')), findsOneWidget);
    expect(find.text('Train 12608'), findsNothing);
  });

  testWidgets('search screen filters all saved tickets by ID and details', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('homeTicketSearchField')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('ticketSearchInput')),
      'pnr-123',
    );
    await tester.pumpAndSettle();

    expect(find.text('Train 12608'), findsOneWidget);
    expect(find.text('Madurai Film Festival'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('ticketSearchInput')),
      'madurai',
    );
    await tester.pumpAndSettle();

    expect(find.text('Madurai Film Festival'), findsOneWidget);
    expect(find.text('Train 12608'), findsNothing);
  });
}
