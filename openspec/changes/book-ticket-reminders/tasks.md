## 1. BookingReminderService

- [x] 1.1 Create `BookingReminderPreferences` model (ticketId, bookingOpenDate, isTatkal, enabled)
- [x] 1.2 Create `IBookingReminderPreferencesService` interface with save/load/delete methods
- [x] 1.3 Create `BookingReminderPreferencesService` implementation using SharedPreferences
- [x] 1.4 Create `BookingReminderService` class with compute logic for booking-open dates
- [x] 1.5 Implement `computeBookingOpenDates(Ticket)` returning normal and/or tatkal dates
- [x] 1.6 Implement `scheduleBookingReminder(Ticket)` using `INotificationService.scheduleTicketReminder()`
- [x] 1.7 Implement `cancelBookingReminder(String ticketId)`
- [x] 1.8 Implement `loadActiveReminders()` and `rescheduleMissed()` on app start
- [x] 1.9 Register `BookingReminderService` and `IBookingReminderPreferencesService` in GetIt

## 2. CalendarProvider Booking Indicators

- [x] 2.1 Add `_bookingWindows` map field to `CalendarProvider`
- [x] 2.2 Implement `_computeBookingWindows()` iterating all tickets
- [x] 2.3 Call `_computeBookingWindows()` in `loadTickets()` after fetching tickets
- [x] 2.4 Expose `getDatesWithBookingWindows()` returning `Map<DateTime, List<Ticket>>`
- [x] 2.5 Expose `hasBookingWindowOnDay(DateTime)` and `getBookingWindowTicketsForDay(DateTime)`

## 3. Calendar Day Cell Indicators

- [x] 3.1 Update `ThemedDayCell` to accept booking window state
- [x] 3.2 Render blue dot for normal booking windows on day cell
- [x] 3.3 Render orange dot for tatkal booking windows on day cell
- [x] 3.4 Handle both normal + tatkal indicators on same day

## 4. Booking Reminder Popup UI

- [x] 4.1 Create `BookingReminderPopup` widget shown on tap of day with indicators
- [x] 4.2 List tickets with booking windows opening on that date
- [x] 4.3 Add toggle per ticket to enable/disable booking reminder
- [x] 4.4 Wire toggle to `BookingReminderService.scheduleBookingReminder()` / `cancelBookingReminder()`
- [x] 4.5 Show bell icon badge on ticket cards with active booking reminders

## 5. DI Registration & Wiring

- [x] 5.1 Register `BookingReminderService` and `IBookingReminderPreferencesService` in `locator.dart`
- [x] 5.2 Init `BookingReminderService` on app start for reschedule logic
- [x] 5.3 Wire calendar tap handler to `BookingReminderPopup`
