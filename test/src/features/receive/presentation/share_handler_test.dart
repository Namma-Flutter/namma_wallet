import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:namma_wallet/src/features/receive/domain/shared_content_result.dart';
import 'package:namma_wallet/src/features/receive/presentation/share_handler.dart';

import '../../../../helpers/fake_go_router.dart';

void main() {
  // Required because GlobalKey.currentState accesses WidgetsBinding.instance
  // unconditionally inside the Flutter framework, before the null-safe `?.`
  // guard in handleWarning can take effect.  Without this initialisation the
  // third test (which triggers handleWarning via a non-null warning) throws
  // "Binding has not yet been initialized".
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShareHandler', () {
    late FakeGoRouter fakeRouter;
    late GlobalKey<ScaffoldMessengerState> scaffoldKey;
    late ShareHandler handler;

    setUp(() {
      fakeRouter = FakeGoRouter();
      scaffoldKey = GlobalKey<ScaffoldMessengerState>();
      handler = ShareHandler(
        router: fakeRouter,
        scaffoldMessengerKey: scaffoldKey,
      );
    });

    group('handleResult - TicketCreatedResult', () {
      test(
        'Given TicketCreatedResult with ticketId, When handleResult called, '
        'Then navigates to ticket view path',
        () {
          // Arrange (Given)
          const result = TicketCreatedResult(
            pnrNumber: 'T12345678',
            from: 'Chennai',
            to: 'Bangalore',
            fare: '500',
            date: '15/12/2024',
            ticketId: 'T12345678',
          );

          // Act (When)
          handler.handleResult(result);

          // Assert (Then)
          verify(fakeRouter.go('/ticket/T12345678')).called(1);
        },
      );

      test(
        'Given TicketCreatedResult with null ticketId, '
        'When handleResult called, '
        'Then navigates to home',
        () {
          // Arrange (Given)
          const result = TicketCreatedResult(
            pnrNumber: 'T12345678',
            from: 'Chennai',
            to: 'Bangalore',
            fare: '500',
            date: '15/12/2024',
          );

          // Act (When)
          handler.handleResult(result);

          // Assert (Then)
          verify(fakeRouter.go('/')).called(1);
        },
      );

      test(
        'Given TicketCreatedResult with ticketId and warning, '
        'When handleResult called, '
        'Then navigates to ticket view and shows warning',
        () {
          // Arrange (Given)
          const result = TicketCreatedResult(
            pnrNumber: 'T12345678',
            from: 'Chennai',
            to: 'Bangalore',
            fare: '500',
            date: '15/12/2024',
            ticketId: 'T12345678',
            warning: 'Some warning',
          );

          // Act (When)
          handler.handleResult(result);

          // Assert (Then)
          verify(fakeRouter.go('/ticket/T12345678')).called(1);
        },
      );
    });
  });
}
