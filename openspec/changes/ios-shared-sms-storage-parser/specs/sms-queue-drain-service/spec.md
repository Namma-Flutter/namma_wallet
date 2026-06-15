## ADDED Requirements

### Requirement: SMS queue is drained on cold start
The system SHALL read the SMS queue from App Group UserDefaults on every cold start (before the user interacts with the app) and process each entry through the existing `SharedContentProcessor`.

#### Scenario: App launched with pending SMS in queue
- **WHEN** the app is launched cold (not resumed from background)
- **AND** one or more SMS texts are present in the App Group queue
- **THEN** `SMSQueueService` SHALL read all entries, process each through `SharedContentProcessor`, and call `clearSMSQueue` after all entries are processed

#### Scenario: App launched with empty queue
- **WHEN** the app is launched cold and the queue is empty
- **THEN** `SMSQueueService` SHALL perform no processing and no notification SHALL be shown

### Requirement: SMS queue is drained on app resume
The system SHALL read and drain the SMS queue every time `AppLifecycleState.resumed` is triggered (i.e., app comes to foreground from background).

#### Scenario: App resumes with new SMS in queue
- **WHEN** the app transitions from background to foreground (`AppLifecycleState.resumed`)
- **AND** one or more SMS texts have been added to the queue since the last drain
- **THEN** `SMSQueueService` SHALL process all new entries and clear the queue

#### Scenario: Concurrent resume events do not trigger double processing
- **WHEN** `AppLifecycleState.resumed` fires multiple times in rapid succession
- **AND** a drain is already in progress
- **THEN** the second drain call SHALL be skipped (guarded by `_isDraining` flag)

### Requirement: SMSQueueService implements WidgetsBindingObserver
The `SMSQueueService` SHALL implement `WidgetsBindingObserver` and be registered as an observer via `WidgetsBinding.instance.addObserver()` in the root app widget. It SHALL be removed as an observer on dispose.

#### Scenario: Observer attached on app init
- **WHEN** the root app widget's `initState` is called
- **THEN** `SMSQueueService` SHALL be added as a `WidgetsBindingObserver`

#### Scenario: Observer removed on app dispose
- **WHEN** the root app widget's `dispose` is called
- **THEN** `SMSQueueService` SHALL be removed as a `WidgetsBindingObserver`

### Requirement: SMSQueueService is registered in GetIt
The `SMSQueueService` and its interface `ISMSQueueService` SHALL be registered in `locator.dart` as a lazy singleton.

#### Scenario: Service resolved from locator
- **WHEN** any component calls `locator<ISMSQueueService>()`
- **THEN** the same singleton instance of `SMSQueueService` SHALL be returned
