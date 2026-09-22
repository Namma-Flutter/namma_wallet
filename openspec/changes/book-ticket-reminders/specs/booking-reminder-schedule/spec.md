## ADDED Requirements

### Requirement: Compute booking-open dates from ticket metadata
The system SHALL compute booking-open dates based on ticket type.

#### Scenario: TNSTC bus normal booking window
- **WHEN** a ticket has `type == TicketType.bus` and `startTime` is non-null
- **THEN** the booking-open date SHALL be `startTime - 60 days`

#### Scenario: IRCTC train normal booking window
- **WHEN** a ticket has `type == TicketType.train` and `startTime` is non-null
- **THEN** the normal booking-open date SHALL be `startTime - 60 days`

#### Scenario: IRCTC train tatkal booking window
- **WHEN** a ticket has `type == TicketType.train` and `startTime` is non-null
- **THEN** the tatkal booking-open date SHALL be `startTime - 1 day`

#### Scenario: Ticket with null startTime
- **WHEN** a ticket has `startTime == null`
- **THEN** the system SHALL NOT compute any booking-open date

#### Scenario: Non-bus/train ticket type
- **WHEN** a ticket has `type == TicketType.event` or `TicketType.flight` or `TicketType.metro`
- **THEN** the system SHALL NOT compute any booking-open date

### Requirement: Schedule local notification on booking-open date
The system SHALL schedule a local notification to fire on the booking-open date.

#### Scenario: Schedule notification at 8 AM on booking-open date
- **WHEN** a booking reminder is created for a ticket
- **THEN** the system SHALL schedule a notification at 08:00 local time on the computed booking-open date
- **THEN** the notification SHALL include the ticket route (`primaryText`) in the body

#### Scenario: Skip notification in the past
- **WHEN** the computed booking-open date is in the past
- **THEN** the system SHALL NOT schedule a notification
- **THEN** the system MAY notify the user that the booking window has already opened

#### Scenario: Cancel existing booking reminder
- **WHEN** a user cancels a booking reminder for a ticket
- **THEN** the system SHALL cancel the scheduled notification for that ticket

### Requirement: Persist booking reminder state
The system SHALL persist which tickets have active booking reminders.

#### Scenario: Save reminder preferences per ticket
- **WHEN** a user enables a booking reminder for a ticket
- **THEN** the system SHALL persist the ticketId and booking-open date

#### Scenario: Load reminder preferences on app start
- **WHEN** the app starts
- **THEN** the system SHALL load persisted booking reminder preferences
- **THEN** the system SHALL reschedule any notifications that were missed
