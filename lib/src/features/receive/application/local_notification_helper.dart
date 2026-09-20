import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Thin wrapper around [FlutterLocalNotificationsPlugin] to allow
/// injection and mocking in unit tests.
abstract interface class ILocalNotificationHelper {
  /// Initialises the notifications plugin.
  Future<void> initialize();

  /// Requests iOS notification permission.
  Future<void> requestPermissions();

  /// Shows a notification with the given [id], [title] and [body].
  Future<void> show(int id, String title, String body);
}

/// Default production implementation backed by
/// [FlutterLocalNotificationsPlugin].
class LocalNotificationHelper implements ILocalNotificationHelper {
  LocalNotificationHelper() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const _channelId = 'sms_queue_channel';
  static const _channelName = 'SMS Automation';

  @override
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings: settings);
  }

  @override
  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  @override
  Future<void> show(int id, String title, String body) async {
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}
