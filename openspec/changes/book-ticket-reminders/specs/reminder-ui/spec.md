## ADDED Requirements

### Requirement: Add booking reminder from ticket detail
Users SHALL be able to enable/disable a booking reminder from the ticket detail view or calendar context menu.

#### Scenario: Enable booking reminder from calendar popup
- **WHEN** user taps a day cell with booking indicators
- **THEN** a popup SHALL list tickets whose booking windows open on that date
- **THEN** each ticket SHALL show a "Remind me to book" toggle

#### Scenario: Toggle booking reminder on
- **WHEN** user enables the toggle for a ticket
- **THEN** the system SHALL schedule a notification for the booking-open date
- **THEN** the system SHALL persist the reminder preference

#### Scenario: Toggle booking reminder off
- **WHEN** user disables the toggle for a ticket
- **THEN** the system SHALL cancel the scheduled notification for that ticket
- **THEN** the system SHALL remove the persisted reminder preference

#### Scenario: Already-enabled reminder shows active state
- **WHEN** user opens the booking reminder popup for a ticket that already has a reminder
- **THEN** the toggle SHALL show as enabled

### Requirement: Show booking reminder status on ticket card
The calendar ticket list SHALL show whether a booking reminder is active.

#### Scenario: Ticket card shows bell icon
- **WHEN** a ticket has an active booking reminder
- **THEN** the ticket card in the calendar list SHALL display a bell icon badge

#### Scenario: Ticket card without reminder shows no icon
- **WHEN** a ticket does not have an active booking reminder
- **THEN** the ticket card SHALL display no reminder-related badge
