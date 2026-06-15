## ADDED Requirements

### Requirement: SMS queue stored in App Group UserDefaults
The system SHALL maintain a persistent JSON-encoded queue of raw SMS text strings under the key `sms_queue` in `UserDefaults` with suite name `group.com.nammaflutter.nammawallet`. The queue SHALL survive app termination and SHALL support multiple entries without data loss.

#### Scenario: Shortcut enqueues one SMS
- **WHEN** the iOS Shortcut writes a TNSTC SMS text to the App Group UserDefaults queue key
- **THEN** the SMS text SHALL be appended to the existing array (not overwrite it)

#### Scenario: Multiple SMS messages are queued before app opens
- **WHEN** two or more SMS texts are appended to the queue before the app is opened
- **THEN** all entries SHALL be present in the queue and none SHALL be lost

#### Scenario: Queue is cleared after processing
- **WHEN** all queued entries have been successfully processed by the app
- **THEN** `clearSMSQueue()` SHALL remove all entries from the queue key in UserDefaults

### Requirement: MethodChannel exposes queue operations to Flutter
The system SHALL expose a `FlutterMethodChannel` named `com.nammaflutter.nammawallet/sms_queue` in `AppDelegate.swift` providing three methods: `readSMSQueue`, `clearSMSQueue`, and `enqueueSMS`.

#### Scenario: Flutter reads the SMS queue
- **WHEN** Flutter calls `readSMSQueue` on the MethodChannel
- **THEN** the native layer SHALL return a `List<String>` of all queued SMS texts from the App Group UserDefaults

#### Scenario: Flutter clears the SMS queue
- **WHEN** Flutter calls `clearSMSQueue` on the MethodChannel
- **THEN** the native layer SHALL delete the `sms_queue` key from the App Group UserDefaults and return success

#### Scenario: Flutter enqueues an SMS text
- **WHEN** Flutter calls `enqueueSMS` with a String argument on the MethodChannel
- **THEN** the native layer SHALL append the text to the existing queue array in App Group UserDefaults

#### Scenario: Queue is empty
- **WHEN** Flutter calls `readSMSQueue` and no entries exist
- **THEN** the native layer SHALL return an empty list (not null)
