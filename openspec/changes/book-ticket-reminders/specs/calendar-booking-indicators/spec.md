## ADDED Requirements

### Requirement: Show booking-open date markers on calendar
The calendar SHALL display visual indicators on dates where a booking window opens.

#### Scenario: Day cell shows dot for normal booking window
- **WHEN** a date has one or more normal booking windows opening (60-day rule)
- **THEN** the day cell SHALL display a blue dot or badge

#### Scenario: Day cell shows dot for tatkal booking window
- **WHEN** a date has one or more tatkal booking windows opening (1-day rule)
- **THEN** the day cell SHALL display an orange dot or badge

#### Scenario: Both normal and tatkal on same day
- **WHEN** a date has both normal and tatkal booking windows opening
- **THEN** the day cell SHALL display both blue and orange indicators

#### Scenario: No booking windows on date
- **WHEN** a date has no booking windows opening
- **THEN** the day cell SHALL display no booking-related indicators

#### Scenario: Tap on indicator shows tooltip
- **WHEN** a user taps a day cell that has booking indicators
- **THEN** the system SHALL show a tooltip or popup listing the tickets whose booking windows open on that date

### Requirement: Compute booking indicators in CalendarProvider
The CalendarProvider SHALL expose booking window dates.

#### Scenario: getDatesWithBookingWindows returns computed dates
- **WHEN** tickets are loaded
- **THEN** `CalendarProvider.getDatesWithBookingWindows()` SHALL return a `Map<DateTime, List<Ticket>>` mapping each booking-open date to the tickets whose windows open then

#### Scenario: Indicators update on ticket load
- **WHEN** tickets are (re)loaded via `loadTickets()`
- **THEN** booking window indicators SHALL be recalculated
