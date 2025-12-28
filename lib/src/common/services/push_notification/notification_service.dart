import 'dart:convert';

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

  /// Schedules a ticket reminder notification.

  Future<void> scheduleTicketReminder({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
    required String payload,
  }) async {
    final details = await notificatioDetails();

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> cancelTicketReminder(int id) async {
    await _plugin.cancel(id);
  }


  /// Schedules multiple reminders for a ticket at predefined intervals.

  Future<void> scheduleTicketReminderFor(Ticket ticket) async {
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
      final notificationId =
          (ticket.ticketId?.hashCode ?? ticket.primaryText.hashCode) * 100 + i;

      final payload = jsonEncode(ticket.toJson());

      await NotificationService().scheduleTicketReminder(
        id: notificationId,
        dateTime: reminderTime,
        title: ticket.primaryText,
        body: '${ticket.secondaryText} • ${ticket.location}',
        payload: payload,
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
