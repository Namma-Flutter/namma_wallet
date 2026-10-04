## Why

Users often miss booking windows for TNSTC/IRCTC tickets. Normal booking opens 60 days before travel; IRCTC Tatkal opens 1 day before departure. Calendar view shows tickets but doesn't help users act proactively.

## What Changes

- Calendar view gets a "Remind to Book" option on ticket detail / date selection
- Calendar shows computed booking-open dates for TNSTC (60d pre-departure) and IRCTC (60d normal, 1d tatkal)
- Local notification fires on booking-open date
- Marker/indicator on calendar dates where a booking window opens
- Lightweight invitation to book — not a full booking integration

## Capabilities

### New Capabilities
- `booking-reminder-schedule`: Computes booking-open dates per service type and manages local notifications
- `calendar-booking-indicators`: Visual markers on calendar dates where a booking window opens
- `reminder-ui`: UI to add/edit/dismiss booking reminders from calendar view

### Modified Capabilities

<!-- No existing specs to modify -->

## Impact

- **New files**: `lib/src/features/calendar/application/booking_reminder_service.dart`, notification scheduling service
- **Modified files**: Calendar view, ticket detail model (add reminder metadata)
- **Dependencies**: `flutter_local_notifications` (already in pubspec? verify)
