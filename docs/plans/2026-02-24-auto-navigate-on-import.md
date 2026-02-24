# Auto-Navigate to Ticket View on Import — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** After any successful ticket import (PDF, QR, clipboard, or share intent), automatically open the ticket in the Ticket View and remove the success snackbar.

**Architecture:** Replace every success snackbar at each import entry point with `context.pushReplacementNamed` (in-app import) or `router.go('/ticket/:id')` (share intent handler). The share intent path requires adding a `ticketId` field to `TicketCreatedResult` so the ticket ID reaches the navigation layer. The `dart_mappable`-generated mapper is regenerated after that change.

**Tech Stack:** Flutter, GoRouter (`context.pushReplacementNamed` / `router.go`), dart_mappable, fvm flutter test, fvm dart run build_runner

---

### Task 1: Add `ticketId` to `TicketCreatedResult`

**Files:**
- Modify: `lib/src/features/receive/domain/shared_content_result.dart`
- Modify (auto-generated, regenerated in Step 4): `lib/src/features/receive/domain/shared_content_result.mapper.dart`
- Test: `test/src/common/services/shared_content_processor_test.dart`

**Step 1: Write the failing test**

Add this test inside the existing `'processContent - Result Types'` group in `test/src/common/services/shared_content_processor_test.dart`:

```dart
test(
  'Given TicketCreatedResult with ticketId, When checking fields, '
  'Then ticketId is accessible',
  () {
    // Arrange (Given)
    const result = TicketCreatedResult(
      ticketId: 'T12345678',
      pnrNumber: 'T12345678',
      from: 'Chennai',
      to: 'Bangalore',
      fare: '500.00',
      date: '2024-12-15',
    );

    // Assert (Then)
    expect(result.ticketId, equals('T12345678'));
  },
);
```

**Step 2: Run test to verify it fails**

```bash
fvm flutter test test/src/common/services/shared_content_processor_test.dart --name "ticketId is accessible"
```

Expected: FAIL — `The named parameter 'ticketId' isn't defined.`

**Step 3: Add `ticketId` field to `TicketCreatedResult`**

In `lib/src/features/receive/domain/shared_content_result.dart`, update `TicketCreatedResult`:

```dart
@MappableClass()
class TicketCreatedResult extends SharedContentResult
    with TicketCreatedResultMappable {
  const TicketCreatedResult({
    this.ticketId,
    required this.pnrNumber,
    required this.from,
    required this.to,
    required this.fare,
    required this.date,
    this.warning,
  });

  final String? ticketId;
  final String? pnrNumber;
  final String? from;
  final String? to;
  final String? fare;
  final String? date;
  final String? warning;
}
```

**Step 4: Regenerate the dart_mappable mapper**

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

Expected: Exits with code 0. `shared_content_result.mapper.dart` is updated.

**Step 5: Run the test to verify it passes**

```bash
fvm flutter test test/src/common/services/shared_content_processor_test.dart
```

Expected: All tests PASS.

**Step 6: Commit**

```bash
git add lib/src/features/receive/domain/shared_content_result.dart \
        lib/src/features/receive/domain/shared_content_result.mapper.dart \
        test/src/common/services/shared_content_processor_test.dart
git commit -m "feat: add ticketId field to TicketCreatedResult"
```

---

### Task 2: Populate `ticketId` in `SharedContentProcessor`

**Files:**
- Modify: `lib/src/features/receive/application/shared_content_processor.dart`
- Test: `test/src/common/services/shared_content_processor_test.dart`

**Step 1: Write the failing test**

Add this test inside the `'processContent - New Ticket Creation'` group:

```dart
test(
  'Given valid SMS content, When processing content, '
  'Then TicketCreatedResult includes ticketId from parsed ticket',
  () async {
    // Arrange (Given)
    final logger = getIt<ILogger>();
    final processor = SharedContentProcessor(
      logger: logger,
      travelParser: MockTravelParserService(logger: logger),
      ticketDao: MockTicketDAO(),
      importService: MockImportService(),
    );

    // The MockTravelParserService extracts 'T12345678' and sets it as ticketId
    const smsContent = '''
      Corporation : SETC, From : CHENNAI To BANGALORE
      PNR NO. : T12345678, Trip Code : Trip123
      Journey Date : 15/12/2024, Time : 14:30
    ''';

    // Act (When)
    final result = await processor.processContent(
      smsContent,
      SharedContentType.sms,
    );

    // Assert (Then)
    expect(result, isA<TicketCreatedResult>());
    final ticketResult = result as TicketCreatedResult;
    expect(ticketResult.ticketId, equals('T12345678'));
  },
);
```

**Step 2: Run test to verify it fails**

```bash
fvm flutter test test/src/common/services/shared_content_processor_test.dart --name "TicketCreatedResult includes ticketId"
```

Expected: FAIL — `ticketId` is `null` because the processor doesn't set it yet.

**Step 3: Update `SharedContentProcessor` to pass `ticketId`**

In `lib/src/features/receive/application/shared_content_processor.dart`, find the two places that construct `TicketCreatedResult` and add `ticketId: ticket.ticketId`:

**PKPass flow** (around line 58):
```dart
return TicketCreatedResult(
  ticketId: ticket.ticketId,   // <-- add this line
  pnrNumber: ticket.pnrOrId,
  from: ticket.fromLocation,
  to: ticket.toLocation,
  fare: ticket.fare,
  date: ticket.date,
  warning: result.warning,
);
```

**SMS/PDF flow** (around line 167):
```dart
return TicketCreatedResult(
  ticketId: ticket.ticketId,   // <-- add this line
  pnrNumber: ticket.pnrOrId,
  from: ticket.fromLocation,
  to: ticket.toLocation,
  fare: ticket.fare,
  date: ticket.date,
);
```

**Step 4: Run the test to verify it passes**

```bash
fvm flutter test test/src/common/services/shared_content_processor_test.dart
```

Expected: All tests PASS.

**Step 5: Commit**

```bash
git add lib/src/features/receive/application/shared_content_processor.dart \
        test/src/common/services/shared_content_processor_test.dart
git commit -m "feat: populate ticketId in TicketCreatedResult from SharedContentProcessor"
```

---

### Task 3: Update `ShareHandler` to navigate to ticket view

**Files:**
- Create: `test/src/features/receive/presentation/share_handler_test.dart`
- Modify: `lib/src/features/receive/presentation/share_handler.dart`

**Step 1: Create the test file with a failing test**

Create `test/src/features/receive/presentation/share_handler_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:namma_wallet/src/features/receive/domain/shared_content_result.dart';
import 'package:namma_wallet/src/features/receive/presentation/share_handler.dart';

import '../../../../helpers/fake_go_router.dart';

void main() {
  group('ShareHandler', () {
    late FakeGoRouter fakeRouter;
    late GlobalKey<ScaffoldMessengerState> scaffoldKey;
    late ShareHandler handler;

    setUp(() {
      fakeRouter = FakeGoRouter();
      scaffoldKey = GlobalKey<ScaffoldMessengerState>();
      handler = ShareHandler(
        router: fakeRouter,
        scaffoldMessengerKey: scaffoldKey,
      );
    });

    group('handleResult - TicketCreatedResult', () {
      test(
        'Given TicketCreatedResult with ticketId, When handleResult called, '
        'Then navigates to ticket view path',
        () {
          // Arrange (Given)
          const result = TicketCreatedResult(
            ticketId: 'T12345678',
            pnrNumber: 'T12345678',
            from: 'Chennai',
            to: 'Bangalore',
            fare: '500',
            date: '15/12/2024',
          );

          // Act (When)
          handler.handleResult(result);

          // Assert (Then)
          verify(fakeRouter.go('/ticket/T12345678')).called(1);
        },
      );

      test(
        'Given TicketCreatedResult with null ticketId, When handleResult called, '
        'Then navigates to home',
        () {
          // Arrange (Given)
          const result = TicketCreatedResult(
            ticketId: null,
            pnrNumber: 'T12345678',
            from: 'Chennai',
            to: 'Bangalore',
            fare: '500',
            date: '15/12/2024',
          );

          // Act (When)
          handler.handleResult(result);

          // Assert (Then)
          verify(fakeRouter.go('/')).called(1);
        },
      );

      test(
        'Given TicketCreatedResult with warning, When handleResult called, '
        'Then does NOT navigate to share success',
        () {
          // Arrange (Given)
          const result = TicketCreatedResult(
            ticketId: 'T12345678',
            pnrNumber: 'T12345678',
            from: 'Chennai',
            to: 'Bangalore',
            fare: '500',
            date: '15/12/2024',
            warning: 'Some warning',
          );

          // Act (When)
          handler.handleResult(result);

          // Assert (Then)
          verify(fakeRouter.go('/ticket/T12345678')).called(1);
          verifyNever(fakeRouter.go('/share-success'));
        },
      );
    });
  });
}
```

**Step 2: Run test to verify it fails**

```bash
fvm flutter test test/src/features/receive/presentation/share_handler_test.dart
```

Expected: FAIL — `ShareHandler` still navigates to `/share-success`, not `/ticket/T12345678`.

**Step 3: Update `ShareHandler.handleResult`**

In `lib/src/features/receive/presentation/share_handler.dart`, replace the `TicketCreatedResult` case:

```dart
case TicketCreatedResult(:final ticketId, :final warning):
  if (warning != null) {
    handleWarning(warning);
  }
  if (ticketId != null) {
    router.go('/ticket/$ticketId');
  } else {
    router.go(AppRoute.home.path);
  }
```

Remove the unused `pnrNumber`, `from`, `to`, `fare`, `date` destructuring from the case pattern since we no longer need them.

**Step 4: Run the tests to verify they pass**

```bash
fvm flutter test test/src/features/receive/presentation/share_handler_test.dart
```

Expected: All tests PASS.

**Step 5: Analyze**

```bash
fvm flutter analyze lib/src/features/receive/presentation/share_handler.dart
```

Expected: No issues.

**Step 6: Commit**

```bash
git add lib/src/features/receive/presentation/share_handler.dart \
        test/src/features/receive/presentation/share_handler_test.dart
git commit -m "feat: navigate to ticket view after successful share import"
```

---

### Task 4: Update PDF and QR import handlers in `ImportView`

**Files:**
- Modify: `lib/src/features/import/presentation/import_view.dart`

**Step 1: Update `_handlePDFPick`**

In `lib/src/features/import/presentation/import_view.dart`, find the `if (ticket != null)` block inside `_handlePDFPick` (around line 141) and replace:

```dart
// BEFORE
if (ticket != null) {
  showSnackbar(context, 'PDF ticket imported successfully!');
}
```

With:

```dart
// AFTER
if (ticket != null) {
  context.pushReplacementNamed(
    AppRoute.ticketView.name,
    pathParameters: {'id': ticket.ticketId!},
  );
}
```

**Step 2: Update `_handleQRCodeScan`**

Find the `if (ticket != null)` block inside `_handleQRCodeScan` (around line 50) and replace:

```dart
// BEFORE
if (ticket != null) {
  showSnackbar(
    context,
    'QR ticket imported successfully!',
  );
}
```

With:

```dart
// AFTER
if (ticket != null) {
  context.pushReplacementNamed(
    AppRoute.ticketView.name,
    pathParameters: {'id': ticket.ticketId!},
  );
}
```

**Step 3: Analyze**

```bash
fvm flutter analyze lib/src/features/import/presentation/import_view.dart
```

Expected: No issues.

**Step 4: Commit**

```bash
git add lib/src/features/import/presentation/import_view.dart
git commit -m "feat: navigate to ticket view after PDF and QR import"
```

---

### Task 5: Update clipboard import handler in `ImportView`

**Files:**
- Modify: `lib/src/features/import/presentation/import_view.dart`

**Step 1: Update `_handleClipboardRead`**

In `_handleClipboardRead`, find the line that calls `ClipboardResultHandler.showResultMessage(context, result)` (around line 189) and replace it:

```dart
// BEFORE
ClipboardResultHandler.showResultMessage(context, result);
```

With:

```dart
// AFTER
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

This keeps the existing snackbar for:
- Errors (`result.isSuccess == false`)
- Conductor-detail updates where a new ticket was not created (`result.ticket == null`)

**Step 2: Analyze**

```bash
fvm flutter analyze lib/src/features/import/presentation/import_view.dart
```

Expected: No issues.

**Step 3: Commit**

```bash
git add lib/src/features/import/presentation/import_view.dart
git commit -m "feat: navigate to ticket view after clipboard import"
```

---

### Task 6: Final verification

**Step 1: Run full test suite**

```bash
fvm flutter test
```

Expected: All tests PASS with no failures.

**Step 2: Run full analyzer**

```bash
fvm flutter analyze
```

Expected: No issues found.

**Step 3: Tell the user to test manually**

The automated tests cover unit behavior. Ask the user to run the app and verify:
- Upload a PDF → ticket view opens automatically
- Scan a QR code → ticket view opens automatically
- Read clipboard with ticket content → ticket view opens automatically
- Share a PDF/SMS into the app → ticket view opens automatically
- In all cases: pressing back returns to the home screen (not the import screen)
- Error cases still show snackbars (unsupported PDF, invalid QR, etc.)
