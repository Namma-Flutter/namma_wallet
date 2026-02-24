# Design: Auto-Navigate to Ticket View on Successful Import

**Date:** 2026-02-24

## Problem

After a ticket is successfully imported (via PDF, QR scan, clipboard, or share intent), the app shows a success snackbar and leaves the user on the import screen. The user has to manually navigate to find the newly imported ticket.

## Goal

Immediately open the ticket in the Ticket View after any successful import. Remove the success snackbar.

## Scope

All four import sources:
- PDF upload
- QR code scan
- Clipboard paste
- Share intent (SMS / PDF via OS share sheet)

Errors and the clipboard "update" case (conductor details added to existing ticket — no new ticket ID) retain their existing snackbar feedback.

## Approach

Use `context.pushReplacementNamed` (for in-app import flows) and `router.go` (for the share handler) so that pressing back from the ticket view returns the user to wherever they were before importing, not back to the import screen.

## Changes

### 1. `lib/src/features/import/presentation/import_view.dart`

**`_handlePDFPick`**
Replace:
```dart
showSnackbar(context, 'PDF ticket imported successfully!');
```
With:
```dart
context.pushReplacementNamed(
  AppRoute.ticketView.name,
  pathParameters: {'id': ticket.ticketId!},
);
```

**`_handleQRCodeScan`**
Replace:
```dart
showSnackbar(context, 'QR ticket imported successfully!');
```
With:
```dart
context.pushReplacementNamed(
  AppRoute.ticketView.name,
  pathParameters: {'id': ticket.ticketId!},
);
```

**`_handleClipboardRead`**
Replace the `ClipboardResultHandler.showResultMessage(context, result)` call with:
```dart
final ticketId = result.ticket?.ticketId;
if (result.isSuccess && ticketId != null) {
  context.pushReplacementNamed(
    AppRoute.ticketView.name,
    pathParameters: {'id': ticketId},
  );
} else {
  ClipboardResultHandler.showResultMessage(context, result);
}
```

### 2. `lib/src/features/receive/domain/shared_content_result.dart`

Add `ticketId` field to `TicketCreatedResult`:
```dart
class TicketCreatedResult extends SharedContentResult {
  const TicketCreatedResult({
    this.ticketId,       // <-- new field
    required this.pnrNumber,
    ...
  });

  final String? ticketId;
  ...
}
```

### 3. `lib/src/features/receive/application/shared_content_processor.dart`

In both `TicketCreatedResult(...)` constructions, add:
```dart
ticketId: ticket.ticketId,
```

### 4. `lib/src/features/receive/presentation/share_handler.dart`

In the `TicketCreatedResult` case, replace:
```dart
router.go(AppRoute.shareSuccess.path, extra: {...});
```
With:
```dart
if (result.ticketId != null) {
  router.go('/ticket/${result.ticketId}');
} else {
  router.go(AppRoute.home.path);
}
```

### 5. Regenerate dart_mappable mapper

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

## Out of Scope

- Removing the now-unused `share_success_view.dart` and `AppRoute.shareSuccess` route (follow-up cleanup)
- The clipboard "ticket updated" case — no ticket ID is available, snackbar retained

## Back-Stack Behavior

| Import source | Navigation call | Back button goes to |
|---|---|---|
| PDF / QR / Clipboard | `pushReplacementNamed` | Home (or wherever user was before import) |
| Share intent | `router.go('/ticket/:id')` | Home (root) |
