import 'package:namma_wallet/src/features/receive/application/local_notification_helper.dart';

/// A lightweight mock for [ILocalNotificationHelper] used in unit tests.
///
/// Records calls to [show] so tests can assert on notification behaviour
/// without touching the system notification stack.
class MockNotificationsPlugin implements ILocalNotificationHelper {
  int showCallCount = 0;
  String? lastTitle;
  String? lastBody;
  int? lastId;
  bool initializeCalled = false;
  bool requestPermissionsCalled = false;

  @override
  Future<void> initialize() async {
    initializeCalled = true;
  }

  @override
  Future<void> requestPermissions() async {
    requestPermissionsCalled = true;
  }

  @override
  Future<void> show(int id, String title, String body) async {
    showCallCount++;
    lastId = id;
    lastTitle = title;
    lastBody = body;
  }
}
