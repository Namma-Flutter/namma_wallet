## ADDED Requirements

### Requirement: Local notification shown after successful SMS queue drain
The system SHALL display a local notification to the user after successfully processing one or more SMS entries from the queue. The notification SHALL summarise the number of tickets processed and SHALL NOT be shown if the queue was empty or if all entries failed to parse.

#### Scenario: One ticket parsed from queue
- **WHEN** exactly one SMS entry is processed successfully from the queue
- **THEN** a local notification SHALL be shown with title "Namma Wallet" and body "1 new ticket added from TNSTC SMS automation"

#### Scenario: Multiple tickets parsed from queue
- **WHEN** two or more SMS entries are processed successfully from the queue
- **THEN** a local notification SHALL be shown with body "N new tickets added from TNSTC SMS automation" (where N is the count)

#### Scenario: No tickets parsed successfully
- **WHEN** all SMS entries in the queue fail to parse (parser returns null or error)
- **THEN** no notification SHALL be shown

#### Scenario: Notification permission not granted
- **WHEN** the user has not granted notification permission
- **AND** the queue drain succeeds
- **THEN** the processing SHALL complete successfully and no crash or error SHALL occur; the notification is silently skipped

### Requirement: Notification uses a dedicated channel
The system SHALL initialise `flutter_local_notifications` with a dedicated Android notification channel named `sms_queue_channel` (for Android compatibility) and a corresponding iOS configuration using the default alert, badge, and sound settings.

#### Scenario: Notification channel is initialised on first drain
- **WHEN** `SMSQueueService` is constructed and `initialize()` is called
- **THEN** `flutter_local_notifications` SHALL be initialised with iOS and Android settings before any notification is posted

### Requirement: Notification permission is requested before first notification
The system SHALL request notification permission from the user (iOS) before posting the first success notification. Permission is requested at most once per app install.

#### Scenario: Permission requested on first successful drain
- **WHEN** `SMSQueueService` processes a queue successfully for the first time
- **AND** notification permission has not previously been granted or denied
- **THEN** the system SHALL call `requestPermissions()` on the iOS implementation before posting the notification

#### Scenario: Permission already granted
- **WHEN** notification permission was previously granted
- **THEN** the system SHALL post the notification without requesting permission again
