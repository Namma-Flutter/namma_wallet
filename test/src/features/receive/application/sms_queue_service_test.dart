import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/receive/application/sms_queue_service.dart';
import 'package:namma_wallet/src/features/receive/domain/shared_content_result.dart';
import 'package:namma_wallet/src/features/receive/domain/shared_content_type.dart';
import 'package:namma_wallet/src/features/receive/domain/sms_queue_service_interface.dart';

import '../../../../helpers/fake_logger.dart';
import 'mock_shared_content_processor.dart';
import 'mock_notifications_plugin.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.nammaflutter.nammawallet/sms_queue');

  group('SMSQueueService', () {
    late MockSharedContentProcessor mockProcessor;
    late MockNotificationsPlugin mockNotifications;
    late FakeLogger fakeLogger;
    late ISMSQueueService service;

    // Tracks the list of method calls received by the mock channel
    final methodCallLog = <MethodCall>[];
    // Backing queue used by the mock channel
    List<String> fakeQueue = [];

    setUp(() async {
      fakeQueue = [];
      methodCallLog.clear();
      mockProcessor = MockSharedContentProcessor();
      mockNotifications = MockNotificationsPlugin();
      fakeLogger = FakeLogger();

      service = SMSQueueService(
        logger: fakeLogger,
        contentProcessor: mockProcessor,
        notificationHelper: mockNotifications,
        forceEnabled: true,
      );
      // Initialize notifications so _notificationsInitialized=true
      await service.initialize();

      // Set up mock MethodChannel handler
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
        mockProcessor.resultToReturn = const TicketCreatedResult(
          pnrNumber: '12345',
          from: 'Chennai',
          to: 'Madurai',
          fare: '200',
          date: '2026-06-15',
        );

        await service.drainQueue();

        expect(mockProcessor.callCount, 2);
        expect(
          mockProcessor.receivedContents,
          containsAll(['SMS text 1', 'SMS text 2']),
        );
        expect(
          mockProcessor.receivedTypes,
          everyElement(equals(SharedContentType.sms)),
        );
      });

      test('clears queue after successful processing', () async {
        fakeQueue = ['SMS text 1'];
        mockProcessor.resultToReturn = const TicketCreatedResult(
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

        expect(mockProcessor.callCount, 0);
        expect(mockNotifications.showCallCount, 0);
      });

      // ── Task 6.3: No notification when all entries fail to parse ─────────

      test(
        'does not post notification when all entries fail to parse',
        () async {
          fakeQueue = ['invalid SMS'];
          mockProcessor.resultToReturn = const ProcessingErrorResult(
            message: 'Failed',
            error: 'No parser matched',
          );

          await service.drainQueue();

          expect(mockNotifications.showCallCount, 0);
          expect(fakeQueue, ['invalid SMS']);
        },
      );

      test('preserves only failed entries after partial success', () async {
        fakeQueue = ['valid SMS', 'invalid SMS'];
        mockProcessor.onProcessContent = (content, type) async {
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

        expect(mockNotifications.showCallCount, 1);
        expect(fakeQueue, ['invalid SMS']);
      });

      test('posts notification when at least one entry succeeds', () async {
        fakeQueue = ['valid SMS'];
        mockProcessor.resultToReturn = const TicketCreatedResult(
          pnrNumber: '99999',
          from: 'A',
          to: 'B',
          fare: '50',
          date: '2026-06-15',
        );

        await service.drainQueue();

        expect(mockNotifications.showCallCount, 1);
        expect(mockNotifications.lastBody, contains('1 new ticket'));
        expect(mockNotifications.lastTitle, 'Namma Wallet');
      });
    });

    // ── Task 6.2: Concurrent drain is short-circuited ────────────────────

    test('second concurrent drainQueue() call is skipped', () async {
      fakeQueue = ['SMS 1', 'SMS 2'];
      final initialQueueLength = fakeQueue.length;
      // Artificially slow processor
      var callCount = 0;
      mockProcessor.onProcessContent = (content, type) async {
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
        mockProcessor.resultToReturn = const TicketCreatedResult(
          pnrNumber: '1',
          from: 'A',
          to: 'B',
          fare: '0',
          date: '2026-06-15',
        );

        (service as SMSQueueService).didChangeAppLifecycleState(
          AppLifecycleState.resumed,
        );

        // Allow the async drain to complete
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(mockProcessor.callCount, greaterThan(0));
      });

      test('does not call drainQueue for paused state', () async {
        fakeQueue = ['SMS'];

        (service as SMSQueueService).didChangeAppLifecycleState(
          AppLifecycleState.paused,
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(mockProcessor.callCount, 0);
      });

      test('does not call drainQueue for inactive state', () async {
        fakeQueue = ['SMS'];

        (service as SMSQueueService).didChangeAppLifecycleState(
          AppLifecycleState.inactive,
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(mockProcessor.callCount, 0);
      });
    });
  });
}

// ── Helpers ──────────────────────────────────────────────────────────────────

/// Helper to encode a list of SMS strings the same way Swift does,
/// for low-level channel testing if needed.
String encodeSMSQueue(List<String> entries) => jsonEncode(entries);
