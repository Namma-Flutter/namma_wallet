import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/receive/application/sms_queue_service.dart';
import 'package:namma_wallet/src/features/receive/domain/shared_content_result.dart';
import 'package:namma_wallet/src/features/receive/domain/shared_content_type.dart';
import 'package:namma_wallet/src/features/receive/domain/sms_queue_service_interface.dart';

import '../../../../helpers/fake_logger.dart';
import 'fake_notifications_plugin.dart';
import 'fake_shared_content_processor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.nammaflutter.nammawallet/sms_queue');

  group('SMSQueueService', () {
    late FakeSharedContentProcessor fakeProcessor;
    late FakeNotificationsPlugin fakeNotifications;
    late FakeLogger fakeLogger;
    late ISMSQueueService service;

    final methodCallLog = <MethodCall>[];
    var fakeQueue = <String>[];

    setUp(() async {
      fakeQueue = [];
      methodCallLog.clear();
      fakeProcessor = FakeSharedContentProcessor();
      fakeNotifications = FakeNotificationsPlugin();
      fakeLogger = FakeLogger();

      service = SMSQueueService(
        logger: fakeLogger,
        contentProcessor: fakeProcessor,
        notificationHelper: fakeNotifications,
        forceEnabled: true,
      );
      await service.initialize();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            methodCallLog.add(call);
            switch (call.method) {
              case 'readSMSQueue':
                return fakeQueue;
              case 'clearSMSQueue':
                fakeQueue.clear();
                return null;
              case 'replaceSMSQueue':
                fakeQueue = List<String>.from(call.arguments as List<Object?>);
                return null;
              default:
                throw MissingPluginException();
            }
          });
    });

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      await service.dispose();
    });

    // ── Task 6.1: drainQueue calls processContent once per entry ────────────

    group('drainQueue()', () {
      test('calls processContent for each SMS entry in queue', () async {
        fakeQueue = ['SMS text 1', 'SMS text 2'];
        fakeProcessor.resultToReturn = const TicketCreatedResult(
          pnrNumber: '12345',
          from: 'Chennai',
          to: 'Madurai',
          fare: '200',
          date: '2026-06-15',
        );

        await service.drainQueue();

        expect(fakeProcessor.callCount, 2);
        expect(
          fakeProcessor.receivedContents,
          containsAll(['SMS text 1', 'SMS text 2']),
        );
        expect(
          fakeProcessor.receivedTypes,
          everyElement(equals(SharedContentType.sms)),
        );
      });

      test('clears queue after successful processing', () async {
        fakeQueue = ['SMS text 1'];
        fakeProcessor.resultToReturn = const TicketCreatedResult(
          pnrNumber: '12345',
          from: 'A',
          to: 'B',
          fare: '100',
          date: '2026-06-15',
        );

        await service.drainQueue();

        final replaceCalls = methodCallLog
            .where((c) => c.method == 'replaceSMSQueue')
            .toList();
        expect(replaceCalls, hasLength(1));
        expect(fakeQueue, isEmpty);
      });

      test('does nothing when queue is empty', () async {
        fakeQueue = [];
        await service.drainQueue();

        expect(fakeProcessor.callCount, 0);
        expect(fakeNotifications.showCallCount, 0);
      });

      // ── Task 6.3: No notification when all entries fail to parse ─────────

      test(
        'does not post notification when all entries fail to parse',
        () async {
          fakeQueue = ['invalid SMS'];
          fakeProcessor.resultToReturn = const ProcessingErrorResult(
            message: 'Failed',
            error: 'No parser matched',
          );

          await service.drainQueue();

          expect(fakeNotifications.showCallCount, 0);
          expect(fakeQueue, ['invalid SMS']);
        },
      );

      test('preserves only failed entries after partial success', () async {
        fakeQueue = ['valid SMS', 'invalid SMS'];
        fakeProcessor.onProcessContent = (content, type) async {
          if (content == 'valid SMS') {
            return const TicketCreatedResult(
              pnrNumber: '99999',
              from: 'A',
              to: 'B',
              fare: '50',
              date: '2026-06-15',
            );
          }

          return const ProcessingErrorResult(
            message: 'Failed',
            error: 'No parser matched',
          );
        };

        await service.drainQueue();

        expect(fakeNotifications.showCallCount, 1);
        expect(fakeQueue, ['invalid SMS']);
      });

      test('posts notification when at least one entry succeeds', () async {
        fakeQueue = ['valid SMS'];
        fakeProcessor.resultToReturn = const TicketCreatedResult(
          pnrNumber: '99999',
          from: 'A',
          to: 'B',
          fare: '50',
          date: '2026-06-15',
        );

        await service.drainQueue();

        expect(fakeNotifications.showCallCount, 1);
        expect(fakeNotifications.lastBody, contains('1 new ticket'));
        expect(fakeNotifications.lastTitle, 'Namma Wallet');
      });
    });

    // ── Task 6.2: Concurrent drain is short-circuited ────────────────────

    test('second concurrent drainQueue() call is skipped', () async {
      fakeQueue = ['SMS 1', 'SMS 2'];
      final initialQueueLength = fakeQueue.length;
      // Artificially slow processor
      var callCount = 0;
      fakeProcessor.onProcessContent = (content, type) async {
        callCount++;
        // Simulate async work
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return const TicketCreatedResult(
          pnrNumber: '1',
          from: 'A',
          to: 'B',
          fare: '0',
          date: '2026-06-15',
        );
      };

      // Launch two concurrent drains — the first sets _isDraining = true,
      // so the second should be skipped entirely.
      final first = service.drainQueue();
      final second = service.drainQueue(); // should be a no-op
      await Future.wait([first, second]);

      // callCount must be exactly initialQueueLength (from first drain)
      // not 2 * initialQueueLength (double processing).
      expect(callCount, equals(initialQueueLength));
    });

    // ── Task 6.4: didChangeAppLifecycleState only drains on resumed ────────

    group('didChangeAppLifecycleState', () {
      test('calls drainQueue when state is resumed', () async {
        fakeQueue = ['SMS'];
        fakeProcessor.resultToReturn = const TicketCreatedResult(
          pnrNumber: '1',
          from: 'A',
          to: 'B',
          fare: '0',
          date: '2026-06-15',
        );

        // Use a Completer to know when the async drain finishes
        final completer = Completer<void>();
        fakeProcessor.onProcessContent = (content, type) async {
          final result = fakeProcessor.resultToReturn!;
          if (!completer.isCompleted) completer.complete();
          return result;
        };

        (service as SMSQueueService).didChangeAppLifecycleState(
          AppLifecycleState.resumed,
        );

        // Wait for the actual async operation to complete
        await completer.future;
        await Future<void>.delayed(Duration.zero);

        expect(fakeProcessor.callCount, greaterThan(0));
      });

      test('does not call drainQueue for paused state', () async {
        fakeQueue = ['SMS'];

        (service as SMSQueueService).didChangeAppLifecycleState(
          AppLifecycleState.paused,
        );

        await Future<void>.delayed(Duration.zero);

        expect(fakeProcessor.callCount, 0);
      });

      test('does not call drainQueue for inactive state', () async {
        fakeQueue = ['SMS'];

        (service as SMSQueueService).didChangeAppLifecycleState(
          AppLifecycleState.inactive,
        );

        await Future<void>.delayed(Duration.zero);

        expect(fakeProcessor.callCount, 0);
      });
    });
  });
}
