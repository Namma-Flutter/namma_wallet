## 1. iOS Native — MethodChannel & App Group Queue

- [x] 1.1 In `AppDelegate.swift`, register a `FlutterMethodChannel` named `com.nammaflutter.nammawallet/sms_queue` inside `application(_:didFinishLaunchingWithOptions:)` (or `didInitializeImplicitFlutterEngine`)
- [x] 1.2 Implement `readSMSQueue()` handler: read the `sms_queue` JSON array from `UserDefaults(suiteName: "group.com.nammaflutter.nammawallet")` and return it as a `[String]` to Flutter (return `[]` if nil)
- [x] 1.3 Implement `clearSMSQueue()` handler: remove the `sms_queue` key from the App Group `UserDefaults` and return success to Flutter
- [x] 1.4 Implement `enqueueSMS(text: String)` handler: read the current array, append the new text, and write it back to the App Group `UserDefaults`
- [x] 1.5 Verify all three handlers compile cleanly and the App Group suite name matches the existing entitlement (`group.com.nammaflutter.nammawallet`)

## 2. Flutter — SMS Queue Service Interface & Implementation

- [x] 2.1 Create `lib/src/features/receive/domain/sms_queue_service_interface.dart` defining `ISMSQueueService` with methods: `initialize()`, `drainQueue()`, and `dispose()`
- [x] 2.2 Create `lib/src/features/receive/application/sms_queue_service.dart` implementing `ISMSQueueService` and `WidgetsBindingObserver`
- [x] 2.3 In `SMSQueueService`, define the `MethodChannel` constant `com.nammaflutter.nammawallet/sms_queue` and implement `readSMSQueue()`, `clearSMSQueue()`, and `enqueueSMS()` thin wrappers around `MethodChannel.invokeMethod`
- [x] 2.4 Implement `drainQueue()`: call `readSMSQueue()`, skip if empty or `_isDraining` is true, set `_isDraining = true`, process each SMS via `SharedContentProcessor.processContent(sms, SharedContentType.sms)`, collect success count, call `clearSMSQueue()`, then reset `_isDraining = false`
- [x] 2.5 Implement `didChangeAppLifecycleState`: call `drainQueue()` when state is `AppLifecycleState.resumed`
- [x] 2.6 Guard against non-iOS platforms: wrap all MethodChannel calls in a `Platform.isIOS` check; on non-iOS the service is a no-op

## 3. Flutter — Local Notification on Successful Drain

- [x] 3.1 In `SMSQueueService`, initialise `FlutterLocalNotificationsPlugin` with `DarwinInitializationSettings` (request alert, badge, sound) and `AndroidInitializationSettings('@mipmap/ic_launcher')`
- [x] 3.2 Implement `_requestPermissionIfNeeded()`: call `resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, badge: true, sound: true)` once per app session
- [x] 3.3 Implement `_showSuccessNotification(int count)`: post a notification with id `9001`, title `"Namma Wallet"`, and body `"$count new ticket${count > 1 ? 's' : ''} added from TNSTC SMS automation"` using `DarwinNotificationDetails`
- [x] 3.4 After a successful drain (success count > 0), call `_requestPermissionIfNeeded()` then `_showSuccessNotification(successCount)`
- [x] 3.5 Ensure no notification is posted when success count is 0 (all entries failed or queue was empty)

## 4. Flutter — Dependency Injection & App Lifecycle Wiring

- [x] 4.1 In `lib/src/common/di/locator.dart`, register `SMSQueueService` as a lazy singleton under `ISMSQueueService`, injecting `ILogger`, `ISharedContentProcessor`, and `FlutterLocalNotificationsPlugin` (or construct plugin internally)
- [x] 4.2 In `lib/src/app.dart` (or the root widget's `State`), retrieve `locator<ISMSQueueService>()` and call `WidgetsBinding.instance.addObserver(smsQueueService)` in `initState`
- [x] 4.3 Call `smsQueueService.drainQueue()` in `initState` (after `addObserver`) to handle cold-start queued messages
- [x] 4.4 Call `WidgetsBinding.instance.removeObserver(smsQueueService)` in `dispose()`
- [x] 4.5 Run `fvm flutter analyze` and fix any lint errors introduced by the new files

## 5. iOS Shortcut — Updated Automation Guide

- [x] 5.1 Document the updated iOS Shortcut steps in `docs/ios-shortcut-sms-setup.md`: (1) Receive SMS text as input, (2) Use "Set Dictionary Value in App Group" action targeting `group.com.nammaflutter.nammawallet` key `sms_queue` as JSON array append, OR use a "Run Script" action calling `defaults write -g sms_queue` via the App Group
- [x] 5.2 Alternatively, add a `nammawallet://enqueue?sms=<text>` URL scheme handler in `AppDelegate.swift` that calls `enqueueSMS` so the Shortcut can use "Open URL" as a simpler one-step action; document this as the recommended approach for users without Scriptable

## 6. Testing

- [x] 6.1 Write a unit test for `SMSQueueService.drainQueue()` with a mock `MethodChannel` that returns a list of SMS strings; verify `SharedContentProcessor.processContent` is called once per entry
- [x] 6.2 Write a unit test verifying that a second concurrent call to `drainQueue()` while `_isDraining` is true returns immediately without re-processing
- [x] 6.3 Write a unit test verifying that no notification is posted when all queue entries fail to parse (processor returns `ProcessingErrorResult`)
- [x] 6.4 Write a unit test verifying that `didChangeAppLifecycleState` calls `drainQueue()` only for `AppLifecycleState.resumed` and not for other states
- [x] 6.5 Run `fvm flutter test` and confirm all new tests pass
