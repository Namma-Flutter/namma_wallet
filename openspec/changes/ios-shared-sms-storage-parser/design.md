## Context

Namma Wallet currently receives TNSTC SMS data on iOS via the `share_handler` package, which requires the iOS Shortcuts app to open the Share Sheet and route text to the app. This mechanism is fragile: the Share Sheet can time out, the app must respond immediately, and any background-state restrictions cause silent failures. The app already has an App Group (`group.com.nammaflutter.nammawallet`) shared between the Runner, Share Extension, and TicketWidget targets, and has `flutter_local_notifications` (v19.5.0) available.

The existing parsing pipeline (`SharedContentProcessor` → `TravelParserService` → DAO) is solid and should not be changed. The goal is to replace the unreliable delivery path, not the parsing logic.

## Goals / Non-Goals

**Goals:**
- Provide a reliable, asynchronous SMS delivery path from iOS Shortcuts to Namma Wallet via App Group `UserDefaults`.
- Drain the SMS queue automatically on cold start and every time the app resumes from background.
- Show a local notification informing the user that queued SMS data was processed successfully.
- Reuse the existing `SharedContentProcessor` for all parsing — no new parser logic.
- Keep the Shortcut as simple as possible: one "Set Dictionary" + "Set UserDefaults" action.

**Non-Goals:**
- Replacing or modifying the existing Share Extension or share_handler integration.
- Implementing background fetch or silent push notifications.
- Parsing SMS on Android (Android has direct SMS read access; this feature is iOS-only).
- Changing the TNSTC or IRCTC parser internals.

## Decisions

### D1: App Group `UserDefaults` as the shared queue

**Decision**: Store pending SMS texts as a JSON-encoded `List<String>` under key `sms_queue` in `UserDefaults(suiteName: "group.com.nammaflutter.nammawallet")`.

**Rationale**: This is the only IPC mechanism that works reliably between an iOS Shortcut (which can write UserDefaults via the "Set Variable in App Group" action or via a URL scheme) and a Flutter app without any Extension target. It survives app termination, requires no network, and is instantly available on next app open.

**Alternatives considered**:
- *File in shared container*: More complex to implement, requires file coordination, no advantage.
- *URL scheme with SMS as query param*: URL length limits; unreliable if app is not running.
- *Silent push notification*: Requires APNS server infrastructure; overkill.

### D2: MethodChannel bridge for queue read/clear/enqueue

**Decision**: Expose a `FlutterMethodChannel` named `com.nammaflutter.nammawallet/sms_queue` in `AppDelegate.swift` with three methods:
- `readSMSQueue() → List<String>` — returns all queued SMS texts
- `clearSMSQueue()` — removes all entries (called after successful processing)
- `enqueueSMS(String text)` — appends one SMS text to the queue (used from Shortcut via URL scheme if needed)

**Rationale**: MethodChannel is the canonical Flutter↔Swift bridge. Keeping queue management in native Swift ensures correct `UserDefaults` suite access without any plugin dependency.

### D3: Flutter `SMSQueueService` with `WidgetsBindingObserver`

**Decision**: Create `SMSQueueService` implementing `WidgetsBindingObserver`. It attaches itself as an observer in `app.dart` and calls `_drainQueue()` on:
1. `initState` (cold start)
2. `AppLifecycleState.resumed`

**Rationale**: `WidgetsBindingObserver` is the correct Flutter mechanism for lifecycle hooks. No third-party package needed. The service is registered in GetIt as a lazy singleton.

### D4: Local notification on successful drain

**Decision**: After all queued messages are processed, fire a single local notification summarising how many tickets were parsed (e.g., "1 new ticket added from TNSTC SMS"). Use `flutter_local_notifications` (already in pubspec) with a dedicated `sms_queue` channel.

**Rationale**: The user's Shortcut runs silently. Without a notification, they have no feedback that the automation worked. A single grouped notification (one per drain cycle, not per SMS) avoids notification spam.

**Alternatives considered**:
- *In-app snackbar*: Only visible if the user is actively looking at the app at that instant; misses background-to-foreground transitions where the user might be on a different screen.
- *Badge count*: Less informative, harder to clear correctly.

### D5: iOS Shortcut updated to use `UserDefaults` write

**Decision**: Update the iOS Shortcut to use the **"Set Value in App Group"** action (or `defaults write` via Run Script) writing to the `sms_queue` key in `group.com.nammaflutter.nammawallet`.

**Rationale**: Removes the dependency on the Share Sheet entirely. The user simply receives an SMS, the Shortcut fires via automation, appends the text, and the app does the rest on next open.

## Risks / Trade-offs

| Risk | Mitigation |
|---|---|
| UserDefaults size limit (~1 MB) | Each TNSTC SMS is ~500 chars; queue cleared after processing; limit is effectively never hit |
| Race condition if app is opened while Shortcut is writing | `UserDefaults` writes are atomic; `readSMSQueue` + `clearSMSQueue` are called serially on the main thread |
| User forgets to update their Shortcut | Proposal documents the required Shortcut change; existing share intent path remains functional |
| Notification permission not granted | Service checks permission before posting; if denied, processing still completes silently (no crash) |
| Multiple resume events fire rapid drain calls | Debounce with a `_isDraining` boolean flag; second call short-circuits immediately |

## Migration Plan

1. Add Swift MethodChannel handler to `AppDelegate.swift` (no Podfile changes needed).
2. Add `SMSQueueService` to Flutter, register in `locator.dart`.
3. Attach `SMSQueueService` as `WidgetsBindingObserver` in `app.dart`.
4. Request local notification permission on first drain (using `flutter_local_notifications` initialisation).
5. Update the iOS Shortcut (user action — documented in release notes).
6. The old share-intent path continues to work in parallel; no migration of existing data required.

**Rollback**: Remove the `SMSQueueService` observer attachment in `app.dart` and the MethodChannel handler in `AppDelegate.swift`. No database or stored data is affected.

## Open Questions

- Should the Shortcut append to the queue (so multiple SMS messages are not lost) or overwrite? → **Decision: append** (see D1), using a JSON array.
- Should `enqueueSMS` also be callable via URL scheme for power users? → Deferred to a future change; MethodChannel is sufficient for now.
