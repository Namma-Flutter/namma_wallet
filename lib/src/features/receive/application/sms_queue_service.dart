// coverage:ignore-file
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/receive/application/local_notification_helper.dart';
import 'package:namma_wallet/src/features/receive/application/shared_content_processor_interface.dart';
import 'package:namma_wallet/src/features/receive/domain/shared_content_result.dart';
import 'package:namma_wallet/src/features/receive/domain/shared_content_type.dart';
import 'package:namma_wallet/src/features/receive/domain/sms_queue_service_interface.dart';

/// Flutter-side service that drains the iOS App Group SMS queue on cold start
/// and on every [AppLifecycleState.resumed] event.
///
/// The native iOS layer (AppDelegate.swift) writes raw TNSTC SMS texts into
/// `UserDefaults(suiteName: "group.com.nammaflutter.nammawallet")` under the
/// key `sms_queue` as a JSON-encoded `[String]` array. This service reads
/// that queue via a [MethodChannel], processes each entry through
/// [ISharedContentProcessor], and posts a local notification summarising
/// how many tickets were parsed.
class SMSQueueService extends ISMSQueueService with WidgetsBindingObserver {
  SMSQueueService({
    required this._logger,
    required this._contentProcessor,
    ILocalNotificationHelper? notificationHelper,
    // Set to true in tests to bypass Platform.isIOS check
    bool forceEnabled = false,
  }) : _notificationHelper = notificationHelper ?? LocalNotificationHelper(),
       _isEnabled = forceEnabled || (!kIsWeb && Platform.isIOS);

  // ── Channel ───────────────────────────────────────────────────────────────

  static const _channel = MethodChannel(
    'com.nammaflutter.nammawallet/sms_queue',
  );

  static const _notificationId = 9001;

  // ── Dependencies ──────────────────────────────────────────────────────────

  final ILogger _logger;
  final ISharedContentProcessor _contentProcessor;
  final ILocalNotificationHelper _notificationHelper;
  final bool _isEnabled;

  // ── State ─────────────────────────────────────────────────────────────────

  bool _isDraining = false;
  final ValueNotifier<bool> _isParsing = ValueNotifier(false);
  bool _notificationsInitialized = false;

  // ── ISMSQueueService ──────────────────────────────────────────────────────

  @override
  ValueNotifier<bool> get isParsing => _isParsing;

  @override
  Future<void> initialize() async {
    if (!_isEnabled) return;
    await _initNotifications();
  }

  @override
  Future<void> drainQueue() async {
    if (!_isEnabled) return;
    if (_isDraining) {
      _logger.debug('SMSQueueService: drain already in progress, skipping');
      return;
    }

    _isDraining = true;
    try {
      final queue = await _readSMSQueue();
      if (queue.isEmpty) {
        _logger.debug('SMSQueueService: queue is empty, nothing to drain');
        return;
      }

      _logger.info(
        'SMSQueueService: draining ${queue.length} SMS entry(ies)',
      );
      _isParsing.value = true;
      var successCount = 0;
      final failedEntries = <String>[];

      for (final smsText in queue) {
        try {
          final result = await _contentProcessor.processContent(
            smsText,
            SharedContentType.sms,
          );
          if (result is! ProcessingErrorResult) {
            successCount++;
            _logger.info('SMSQueueService: processed entry successfully');
          } else {
            failedEntries.add(smsText);
            _logger.warning(
              'SMSQueueService: entry failed — ${result.error}',
            );
          }
        } on Object catch (e, st) {
          failedEntries.add(smsText);
          _logger.error('SMSQueueService: error processing entry', e, st);
        }
      }

      // Replace queue with only failed entries so successfully processed
      // entries are not re-processed on next drain. Failures must be fatal
      // to prevent duplicate SMS imports.
      await _replaceSMSQueue(failedEntries);

      if (successCount > 0) {
        await _showSuccessNotification(successCount);
      }

      _logger.info(
        'SMSQueueService: drain complete '
        '— $successCount/${queue.length} parsed',
      );
      if (failedEntries.isNotEmpty) {
        _logger.warning(
          'SMSQueueService: preserved ${failedEntries.length} failed '
          'SMS entry(ies) in queue',
        );
      }
    } on Object catch (e, st) {
      _logger.error('SMSQueueService: unexpected error during drain', e, st);
    } finally {
      _isDraining = false;
      _isParsing.value = false;
    }
  }

  @override
  Future<void> dispose() async {
    _logger.info('SMSQueueService: disposed');
    _isParsing.dispose();
  }

  // ── WidgetsBindingObserver ────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _logger.debug('SMSQueueService: app resumed — triggering drain');
      // Deliberately not awaited; drainQueue guards itself with _isDraining.
      drainQueue().ignore();
    }
  }

  // ── MethodChannel wrappers ────────────────────────────────────────────────

  /// Returns all pending SMS texts from the App Group queue.
  /// Returns an empty list if the queue is empty or unreadable.
  Future<List<String>> _readSMSQueue() async {
    try {
      _logger.debug('SMSQueueService: invoking readSMSQueue via MethodChannel');
      final result = await _channel.invokeListMethod<String>('readSMSQueue');
      return result ?? const [];
    } on PlatformException catch (e, st) {
      _logger.error('SMSQueueService: readSMSQueue failed', e, st);
      return const [];
    }
  }

  /// Replaces App Group queue with [entries].
  /// Throws on failure to prevent duplicate SMS imports on next drain.
  Future<void> _replaceSMSQueue(List<String> entries) async {
    _logger.debug(
      'SMSQueueService: invoking replaceSMSQueue via MethodChannel',
    );
    await _channel.invokeMethod<void>('replaceSMSQueue', entries);
  }

  // ── Notification helpers ──────────────────────────────────────────────────

  Future<void> _initNotifications() async {
    if (_notificationsInitialized) return;
    await _notificationHelper.initialize();
    _notificationsInitialized = true;
    _logger.debug('SMSQueueService: notifications initialised');
  }

  Future<void> _showSuccessNotification(int count) async {
    final plural = count > 1 ? 's' : '';
    final body = '$count new ticket$plural added from TNSTC SMS automation';
    try {
      await _notificationHelper.show(
        _notificationId,
        'Namma Wallet',
        body,
      );
      _logger.info('SMSQueueService: success notification posted ($body)');
    } on Object catch (e, st) {
      _logger.error(
        'SMSQueueService: failed to post success notification',
        e,
        st,
      );
    }
  }
}
