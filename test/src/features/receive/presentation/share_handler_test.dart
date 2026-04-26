import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:namma_wallet/src/common/services/archive/ticket_archive.dart';
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
        () async {
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
          await handler.handleResult(result);

          // Assert (Then)
          verify(fakeRouter.go('/')).called(1);
          verify(fakeRouter.push('/ticket/T12345678')).called(1);
        },
      );

      test(
        'Given TicketCreatedResult with null ticketId, '
        'When handleResult called, '
        'Then navigates to home',
        () async {
          // Arrange (Given)
          const result = TicketCreatedResult(
            pnrNumber: 'T12345678',
            from: 'Chennai',
            to: 'Bangalore',
            fare: '500',
            date: '15/12/2024',
          );

          // Act (When)
          await handler.handleResult(result);

          // Assert (Then)
          verify(fakeRouter.go('/')).called(1);
        },
      );

      test(
        'Given TicketCreatedResult with ticketId and warning, '
        'When handleResult called, '
        'Then navigates to ticket view and shows warning',
        () async {
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
          await handler.handleResult(result);

          // Assert (Then)
          verify(fakeRouter.go('/')).called(1);
          verify(fakeRouter.push('/ticket/T12345678')).called(1);
        },
      );

      test(
        'Given archived TicketCreatedResult, When handleResult called, '
        'Then navigates to archived tickets',
        () async {
          const result = TicketCreatedResult(
            pnrNumber: 'T12345678',
            from: 'Chennai',
            to: 'Bangalore',
            fare: '500',
            date: '15/12/2024',
            ticketId: 'T12345678',
            warning: archivedPastTicketMessage,
            isArchived: true,
          );

          await handler.handleResult(result);

          verify(fakeRouter.go(archivedTicketsLocation())).called(1);
          verifyNever(fakeRouter.push('/ticket/T12345678'));
        },
      );

      test(
        'Given archived TicketCreatedResult without warning, '
        'When handleResult called, '
        'Then still navigates to archived tickets',
        () async {
          const result = TicketCreatedResult(
            pnrNumber: 'T12345678',
            from: 'Chennai',
            to: 'Bangalore',
            fare: '500',
            date: '15/12/2024',
            ticketId: 'T12345678',
            isArchived: true,
          );

          await handler.handleResult(result);

          verify(fakeRouter.go(archivedTicketsLocation())).called(1);
          verifyNever(fakeRouter.push('/ticket/T12345678'));
        },
      );
    });

    group('handleResult - other branches', () {
      test(
        'Given TicketUpdatedResult, '
        'When handleResult called, '
        'Then navigates to share success with extras map',
        () async {
          const result = TicketUpdatedResult(
            pnrNumber: 'T12345678',
            updateType: 'Conductor Details',
          );

          await handler.handleResult(result);

          final captured = verify(
            fakeRouter.go('/share-success', extra: captureAnyNamed('extra')),
          ).captured.first as Map<String, dynamic>;
          expect(captured['pnrNumber'], equals('T12345678'));
          expect(captured['to'], equals('Conductor Details'));
          expect(captured['from'], equals('Updated'));
        },
      );

      test(
        'Given TicketNotFoundResult, '
        'When handleResult called, '
        'Then navigates home',
        () async {
          const result = TicketNotFoundResult(pnrNumber: 'T-NOT-FOUND');

          await handler.handleResult(result);

          verify(fakeRouter.go('/')).called(1);
        },
      );

      test(
        'Given ProcessingErrorResult, '
        'When handleResult called, '
        'Then navigates home',
        () async {
          const result = ProcessingErrorResult(
            message: 'failed',
            error: 'parser exploded',
          );

          await handler.handleResult(result);

          verify(fakeRouter.go('/')).called(1);
        },
      );
    });

    group('handleError', () {
      test('navigates home on error', () {
        handler.handleError('boom');

        verify(fakeRouter.go('/')).called(1);
      });
    });
  });
}
