import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service for managing push notifications, including scheduling
/// and displaying notifications.

class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<String> getLocalTimezoneId() async {
    final info = await FlutterTimezone.getLocalTimezone();
    return info.identifier;
  }

  Future<void> initTimezone() async {
    tz.initializeTimeZones();

    final timeZoneId = await getLocalTimezoneId();
    final location = tz.getLocation(timeZoneId);

    tz.setLocalLocation(location);
  }

  /// Initializes the notification service.

  Future<void> initialize({
    required void Function(String? payload) onSelectNotification,
  }) async {
    await initTimezone();
    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_notification_small',
    );
    if (Platform.isAndroid) {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted =
          await androidImpl?.requestNotificationsPermission() ?? false;
      debugPrint('Notification permission granted: $granted');
    }
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        onSelectNotification(details.payload);
      },
    );
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

  String _formatDateTimeForNotification(DateTime? dt) {
    if (dt == null) return '';
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
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    } on Exception catch (e, stackTrace) {
      debugPrint(
        'Error scheduling ticket reminders: $e\n$stackTrace',
      );
    }
  }

  Future<void> cancelTicketReminder(int id) async {
    await _plugin.cancel(id);
  }

  /// Schedules multiple reminders for a ticket at predefined intervals.

  Future<void> scheduleTicketReminderFor(Ticket ticket) async {
    try {
      final journeyTime = ticket.startTime ?? ticket.endTime ?? DateTime.now();
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

        final payload = jsonEncode(ticket.toJson());

        final formattedDateTime = _formatDateTimeForNotification(journeyTime);
        final bodyText = formattedDateTime.isNotEmpty
            ? '${ticket.location} • Starts - $formattedDateTime'
            : ticket.location;

        await NotificationService().scheduleTicketReminder(
          id: notificationId,
          dateTime: reminderTime,
          title: ticket.primaryText,
          body: bodyText,
          payload: payload,
        );
      }
    } on Exception catch (e, stackTrace) {
      // Log error scheduling reminders
      debugPrint(
        'Error scheduling ticket reminders: $e\n$stackTrace',
      );
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
