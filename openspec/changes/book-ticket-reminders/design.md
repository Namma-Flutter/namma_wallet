## Context

Existing notification infrastructure uses `flutter_local_notifications` with `INotificationService` for journey reminders (X hours before departure). Calendar view (`TableCalendar`) shows tickets per day via `CalendarProvider`. Ticket model has `type` (bus/train/event/flight/metro) and `startTime`.

Booking window rules:
- TNSTC/SETC (bus): Normal booking opens 60 days before journey date
- IRCTC (train): Normal booking opens 60 days before departure from originating station
- IRCTC Tatkal: Opens 1 day before departure from originating station

No current mechanism computes booking-open dates or surfaces them in calendar.

## Goals / Non-Goals

**Goals:**
- Compute booking-open dates from existing ticket `startTime` and `type`
- Show visual indicators on calendar dates where a booking window opens
- Schedule local notification on booking-open date
- Provide UI to add/dismiss booking reminders from calendar view

**Non-Goals:**
- No actual booking integration (no webview, no IRCTC/TNSTC API calls)
- No OCR or SMS parsing changes
- No new data model migrations (use existing Ticket fields + in-memory computation)

## Decisions

1. **In-memory computation vs stored dates**: Compute booking-open dates from `startTime` + `type` at query time. No DB changes. Rationale: startTime rarely changes, and computation is trivial. Avoids migration overhead.

2. **Booking open date formula**:
   - `type == bus` → `startTime - 60 days`
   - `type == train` → two windows: `startTime - 60 days` (normal), `startTime - 1 day` (tatkal)
   - Only compute for tickets that have non-null `startTime`

3. **Notification scheduling**: Reuse `INotificationService.scheduleTicketReminder()`. Schedule notification at 8:00 AM on booking-open date (configurable later). Notification body: "Book your [bus/train] ticket today — booking opens for [route]".

4. **Calendar indicators**: Extend `CalendarProvider` with `getDatesWithBookingWindows() -> Set<DateTime>`. `ThemedDayCell` renders a dot/badge when day is in this set. Differentiate normal vs tatkal with color (blue = normal, orange = tatkal).

5. **New service**: `BookingReminderService` (singleton in GetIt) handles compute + schedule + cancel logic. Separate from existing reminder service because purpose is fundamentally different (booking window vs journey departure).

6. **Storage for reminders**: Use existing `IReminderPreferencesService` pattern but with a new `BookingReminderPreferences` model keyed by `ticketId`. Minimal — just stores which tickets have active booking reminders.

## Risks / Trade-offs

- **60-day rule is approximate**: Some buses/trains may deviate. Mitigation: make booking offset configurable per reminder (default 60d).
- **Tatkal only for originating station**: Current model doesn't store boarding station vs originating station. Tatkal rule is 1 day before departure from origin, not boarding point. Accept: use ticket `startTime` as approximation.
- **Notification at fixed 8 AM**: User may want different time. Mitigation: default to 8 AM, allow time picker in future iteration.
- **No timezone handling**: All times are local. Acceptable for current India-only scope.
