import 'package:namma_wallet/src/features/receive/application/local_notification_helper.dart';

/// Fake implementation of [ILocalNotificationHelper] for testing.
class FakeNotificationsPlugin implements ILocalNotificationHelper {
  int showCallCount = 0;
  String? lastTitle;
  String? lastBody;
  bool initializeCalled = false;

  @override
  Future<void> initialize() async {
    initializeCalled = true;
  }

  @override
  Future<void> requestPermissions() async {}

  @override
  Future<void> show(int id, String title, String body) async {
    showCallCount++;
    lastTitle = title;
    lastBody = body;
  }
}
