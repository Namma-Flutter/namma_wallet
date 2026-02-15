import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/routing/app_router.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service for managing push notifications, including scheduling
/// and displaying notifications.
///

class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal()
    : _logger = getIt.isRegistered<ILogger>() ? getIt<ILogger>() : null;
  static final NotificationService _instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final ILogger? _logger;

  Future<String> getLocalTimezoneId() async {
    final info = await FlutterTimezone.getLocalTimezone();
    return info.identifier;
  }

  /// Checks if the POST_NOTIFICATIONS permission is granted.
  /// On Android 13+, this permission is required to post notifications.
  /// On earlier Android versions and other platforms, returns true.
  Future<bool> _isNotificationPermissionGranted() async {
    if (!Platform.isAndroid) return true; // iOS handles this differently

    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Requests POST_NOTIFICATIONS permission on Android 13+.
  /// Returns true if permission is granted or not needed, false if denied.
  /// Note: On Android < 13, this returns true automatically as the permission
  /// is not required.
  Future<bool> _requestNotificationPermission() async {
    if (!Platform.isAndroid) return true;

    final status = await Permission.notification.request();

    if (_logger != null) {
      _logger.info(
        'Notification permission status: ${status.isDenied
            ? 'denied'
            : status.isGranted
            ? 'granted'
            : 'pending'}',
      );
    } else {
      debugPrint(
        'Notification permission status: ${status.isDenied
            ? 'denied'
            : status.isGranted
            ? 'granted'
            : 'pending'}',
      );
    }

    return status.isGranted;
  }

  Future<void> initTimezone() async {
    tz.initializeTimeZones();

    final timeZoneId = await getLocalTimezoneId();
    final location = tz.getLocation(timeZoneId);

    tz.setLocalLocation(location);
  }

  /// Initializes the notification service.

  String? _initialNotificationPayload;

  Future<void> initialize() async {
    await initTimezone();
    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_notification_small',
    );
    if (Platform.isAndroid) {
      // Request POST_NOTIFICATIONS permission on Android 13+
      final permissionGranted = await _requestNotificationPermission();
      if (!permissionGranted) {
        if (_logger != null) {
          _logger.info('Notification permission denied by user');
        } else {
          debugPrint('Notification permission denied by user');
        }
      }
    }
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;
        if (payload == null || payload.isEmpty) {
          if (_logger != null) {
            _logger.error('Notification payload missing; skipping navigation.');
          } else {
            debugPrint('Notification payload missing; skipping navigation.');
          }
          return;
        }
        if (rootNavigatorKey.currentContext != null) {
          rootNavigatorKey.currentContext?.goNamed(
            AppRoute.ticketView.name,
            pathParameters: {'id': payload},
          );
        }
      },
    );

    // Check whether the app was launched by tapping a notification when the
    // app was terminated. Store the payload so it can be handled once the
    // UI (navigator) is ready.
    try {
      final launchDetails = await _plugin.getNotificationAppLaunchDetails();
      final didLaunch = launchDetails?.didNotificationLaunchApp ?? false;
      if (didLaunch) {
        final payload = launchDetails?.notificationResponse?.payload;
        if (payload != null && payload.isNotEmpty) {
          _initialNotificationPayload = payload;
          if (_logger != null) {
            _logger.info(
              'App launched from notification with payload: $payload',
            );
          } else {
            debugPrint('App launched from notification with payload: $payload');
          }
        }
      }
    } on Exception catch (e, st) {
      if (_logger != null) {
        _logger.error('Error checking notification launch details', e, st);
      } else {
        debugPrint('Error checking notification launch details: $e\n$st');
      }
    }
  }

  /// If the app was launched from a terminated state by tapping a
  /// notification, navigate to the appropriate page once the UI is ready.
  Future<void> handleInitialNotification() async {
    final payload = _initialNotificationPayload;
    if (payload == null || payload.isEmpty) return;

    // Try immediate navigation if context is ready
    if (rootNavigatorKey.currentContext != null) {
      rootNavigatorKey.currentContext?.goNamed(
        AppRoute.ticketView.name,
        pathParameters: {'id': payload},
      );
      _initialNotificationPayload = null;
      return;
    }

    // Otherwise, poll briefly for the navigator to become available.
    var attempts = 0;
    Timer.periodic(const Duration(milliseconds: 200), (t) {
      attempts++;
      if (rootNavigatorKey.currentContext != null) {
        rootNavigatorKey.currentContext?.goNamed(
          AppRoute.ticketView.name,
          pathParameters: {'id': payload},
        );
        _initialNotificationPayload = null;
        t.cancel();
      } else if (attempts > 25) {
        // Give up after ~5 seconds
        t.cancel();
      }
    });
  }

  Future<NotificationDetails> notificatioDetails() async {
    const androidDetails = AndroidNotificationDetails(
      'ticket_channel',
      'Ticket Reminders',
      channelDescription: 'Reminders for upcoming travel tickets',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  String _formatTime12(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _formatDateTimeForNotification(DateTime dt) {
    final now = DateTime.now();
    final nowDate = DateTime(now.year, now.month, now.day);
    final dtDate = DateTime(dt.year, dt.month, dt.day);
    final diffDays = dtDate.difference(nowDate).inDays;
    final time = _formatTime12(dt);

    if (diffDays == 0) return time;
    if (diffDays == 1) return 'Tomorrow $time';

    return '${dt.day}/${dt.month}/${dt.year} $time';
  }

  /// Schedules a ticket reminder notification.

  Future<void> scheduleTicketReminder({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
    required String payload,
  }) async {
    // Check permission before scheduling
    final permissionGranted = await _isNotificationPermissionGranted();
    if (!permissionGranted) {
      if (_logger != null) {
        _logger.info(
          '''
          POST_NOTIFICATIONS permission not granted; skipping notification scheduling.''',
        );
      } else {
        debugPrint(
          '''
          POST_NOTIFICATIONS permission not granted; skipping notification scheduling.''',
        );
      }
      return;
    }

    final details = await notificatioDetails();

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(dateTime, tz.local),
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } on Exception catch (e, stackTrace) {
      if (_logger != null) {
        _logger.error('Error scheduling ticket reminders', e, stackTrace);
      } else {
        debugPrint(
          'Error scheduling ticket reminders: $e\n$stackTrace',
        );
      }
    }
  }

  Future<void> cancelTicketReminder(int id) async {
    await _plugin.cancel(id);
  }

  /// Schedules multiple reminders for a ticket at predefined intervals.

  Future<void> scheduleTicketReminderFor(Ticket ticket) async {
    try {
      // Request permission before attempting to schedule
      final permissionGranted = await _requestNotificationPermission();
      if (!permissionGranted) {
        if (_logger != null) {
          _logger.info(
            'POST_NOTIFICATIONS permission denied; cannot schedule reminders.',
          );
        } else {
          debugPrint(
            'POST_NOTIFICATIONS permission denied; cannot schedule reminders.',
          );
        }
        return;
      }

      void logSkip(String message) {
        if (_logger != null) {
          _logger.error(message);
        } else {
          debugPrint(message);
        }
      }

      final journeyTime = ticket.startTime ?? ticket.endTime;
      if (journeyTime == null) {
        logSkip('Ticket has no journey time; skipping reminders.');
        return;
      }

      final payload = ticket.ticketId;
      if (payload == null || payload.isEmpty) {
        logSkip('Ticket ID missing; skipping reminders.');
        return;
      }

      final title = ticket.primaryText;
      if (title == null || title.isEmpty) {
        logSkip('Ticket title missing; skipping reminders.');
        return;
      }

      final location = ticket.location;
      if (location == null || location.isEmpty) {
        logSkip('Ticket location missing; skipping reminders.');
        return;
      }

      final now = DateTime.now();

      final reminders = [
        const Duration(hours: 24),
        const Duration(hours: 4),
        const Duration(hours: 2),
      ];

      for (var i = 0; i < reminders.length; i++) {
        final reminderTime = journeyTime.subtract(reminders[i]);

        // Skip if already passed
        if (reminderTime.isBefore(now)) continue;

        // Unique ID for each reminder (ticketId + reminder index)
        // Ensure the ID fits in signed 32-bit integer range required by
        // FlutterLocalNotifications ([-2^31, 2^31 - 1]).
        final baseHash =
            ticket.ticketId?.hashCode ?? ticket.primaryText.hashCode;
        const maxInt32 = 0x7FFFFFFF; // 2147483647
        // Reserve space for multiplying by 100 (reminder index multiplier)
        const maxBase = maxInt32 ~/ 100; // 21474836
        final safeBase = baseHash.abs() % maxBase;
        final notificationId = safeBase * 100 + i;

        final formattedDateTime = _formatDateTimeForNotification(journeyTime);
        final bodyText = formattedDateTime.isNotEmpty
            ? '$location • Starts - $formattedDateTime'
            : location;

        await NotificationService().scheduleTicketReminder(
          id: notificationId,
          dateTime: reminderTime,
          title: title,
          body: bodyText,
          payload: payload,
        );
      }
    } on Exception catch (e, stackTrace) {
      // Log error scheduling reminders
      if (_logger != null) {
        _logger.error('Error scheduling ticket reminders', e, stackTrace);
      } else {
        debugPrint(
          'Error scheduling ticket reminders: $e\n$stackTrace',
        );
      }
    }
  }

  /// Shows a ticket notification immediately.
  /// Used for testing or immediate alerts.

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    required String payload, // your serialized Ticket JSON
  }) async {
    // Check permission before showing notification
    final permissionGranted = await _isNotificationPermissionGranted();
    if (!permissionGranted) {
      if (_logger != null) {
        _logger.info(
          'POST_NOTIFICATIONS permission not granted;cannot show notification.',
        );
      } else {
        debugPrint(
          'POST_NOTIFICATIONS permission not granted;cannot show notification.',
        );
      }
      return;
    }

    final details = await notificatioDetails();

    await _plugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }
}
