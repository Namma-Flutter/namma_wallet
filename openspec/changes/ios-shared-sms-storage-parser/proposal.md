## Why

The current iOS Shortcuts-based approach for forwarding TNSTC SMS data to Namma Wallet is unreliable — it depends on the user manually triggering a shortcut and requires the app to be in the foreground or respond instantly to a share intent, leading to missed or dropped SMS data. We need a robust, asynchronous mechanism using iOS App Groups shared storage so that automation tools (Shortcuts, Focus Filters, etc.) can write SMS text to a shared container, and the app reliably parses it the next time it is opened or foregrounded.

## What Changes

- **New iOS Shortcut integration target**: Replace share-intent SMS delivery with direct `UserDefaults` (App Group) writes from Shortcuts via a MethodChannel bridge or via a dedicated iOS extension endpoint.
- **New shared SMS queue in App Group storage**: iOS Shortcuts writes raw TNSTC SMS text into `UserDefaults` under the app group `group.com.nammaflutter.nammawallet`, using a JSON array queue so multiple SMS messages are not overwritten.
- **New `SMSQueueService`**: A Flutter-side service that reads, processes, and clears the SMS queue from App Group storage on app open and app resume.
- **App lifecycle hook**: On `AppLifecycleState.resumed` and on cold start, the `SMSQueueService` drains the queue, parses each entry via the existing `SharedContentProcessor`, and saves tickets to the database.
- **Local notification on success**: When the app processes queued SMS data successfully, a local push notification is shown to confirm the automation stored data for parsing. Uses `flutter_local_notifications`.
- **New `SMSQueueMethodChannel` (Swift)**: Native iOS side that exposes `readSMSQueue()` and `clearSMSQueue()` methods to Flutter, reading from/writing to the shared `UserDefaults` App Group container.

## Capabilities

### New Capabilities

- `ios-sms-queue-storage`: iOS App Group shared `UserDefaults` queue that stores raw TNSTC SMS text written by iOS Shortcuts automation; supports enqueueing multiple messages without data loss.
- `sms-queue-drain-service`: Flutter `SMSQueueService` that polls the queue on cold start and `AppLifecycleState.resumed`, drains all pending SMS entries through `SharedContentProcessor`, and clears processed entries.
- `sms-automation-notification`: Local notification triggered after successful queue drain to inform the user that automation has stored and parsed new ticket data.

### Modified Capabilities

*(none — existing share intent and parser pipelines are unchanged)*

## Impact

- **iOS native (Swift)**: `AppDelegate.swift` — add new MethodChannel handler for `com.nammaflutter.nammawallet/sms_queue`. New method implementations: `readSMSQueue`, `clearSMSQueue`, `enqueueSMS` (called by Shortcuts via URL scheme or direct UserDefaults write).
- **Flutter**: New `lib/src/features/receive/application/sms_queue_service.dart` and its interface. Updated `locator.dart` for DI registration. Updated app lifecycle observer (likely in `app.dart` or root widget).
- **iOS Shortcuts**: User updates their Shortcut action to write SMS text to `UserDefaults` App Group key instead of using the Share Sheet.
- **Dependencies**: `flutter_local_notifications` (already referenced in pubspec or to be added) for local push notifications.
- **Info.plist**: No new URL schemes needed — Shortcuts writes directly to App Group `UserDefaults` container.
- **App Group**: Reuses existing `group.com.nammaflutter.nammawallet` entitlement.
