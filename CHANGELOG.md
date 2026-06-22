# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.6+12] - 2026-06-22

### Added

- SMS queue service for processing TNSTC SMS via App Group UserDefaults
- SMS queue processing via App Intent with notification handling
- RTK extension for command rewriting
- File type detection and compression logic for caveman-compress
- OpenSpec project configuration and artifact rules
- RTK usage guidelines and examples
- archivedAt field to Ticket model

### Fixed

- iOS shortcut automation bugs
- SwiftLint configuration with versioning improvements
- Import reordering and fakeQueue initialization in SMSQueueService test

### Changed

- Enhanced SMS queue processing with improved error handling in iOS
- Updated Ruby version to 3.3.10
- Improved code formatting in local_notification_helper and fake_shared_content_processor

### Removed

- Unused encodeSMSQueue helper function from sms_queue_service_test
- Obsolete cursor and settings files

### Chores

- Added node_modules to .gitignore
- Updated OpenSpec configuration

## [0.0.5+11] - 2026-06-08

### Added

- Ticket archiving system with archivedAt field and background maintenance service
- Push notification reminders for tickets with configurable time intervals
- Share tickets as images with screenshot capture functionality
- Security analysis scripts for Flutter projects
- Greenlight CI workflow for automated preflight scanning

### Fixed

- RenderFlex overflow errors in UI layouts
- iOS shortcut automation and notification handling
- Ticket sharing to use temporary directory with proper cleanup
- CI formatter comment handling in workflows
- Flutter SDK version constraints in GitHub Actions

### Changed

- Improved error logging with formatted stack traces using stack_trace package
- Enhanced UI layout alignment and safe area handling
- Streamlined PR comment handling in CI workflows
- Deferred archive maintenance to improve app startup performance

### Removed

- Unused Claude skills documentation and setup files
- Outdated SETUP.md documentation

### Chores

- Updated AGENTS.md with comprehensive architecture documentation
- Enhanced Fastlane release management with internal track and release candidate lanes
- Added App Store and Google Play badges to README

## [0.0.4+10] - 2026-02-24

### Added

- TNSTC ticket import by PNR with phone number verification
- TNSTCApiTicketParser for API-based ticket parsing
- Ticket change notification system for home view refresh
- Conductor call functionality in tickets
- OCR debug view for layout-based text extraction
- Layout-based text extraction replacing regex approach
- Contributors page with repository links
- SwiftLint configuration for iOS project

### Fixed

- Web platform support with web-specific services for deep links and widgets
- Ticket navigation to preserve back stack using go+push
- PKPass content processing and field extraction
- IRCTC and TNSTC parser improvements with nullable fields
- Multiple passenger details extraction from IRCTC tickets
- Seat number correction for OCR misreads (120B → 12UB)

### Changed

- Made ticket fields nullable (location, fare, primaryText, secondaryText, type, startTime)
- Database schema updated to v4 with nullable start_time
- Enhanced IRCTC parser with arrival time, distance, booking date, seat number
- Improved OCR layout extraction for inline key-value pairs and passenger tables
- Split large test fixtures into separate files

### Removed

- Sentinel values replaced with null for unavailable ticket data
- Mock OCR service and unused test files

### Chores

- Updated Flutter SDK version and dependencies
- Added Android Lint GitHub Actions workflow
- Configured edge-to-edge display for Android
- Updated fastlane metadata and screenshots

## [0.0.3+5] - 2026-01-17

### Added

- Android fastlane support with CI/CD automation
- Fastlane deployment lanes for testing and production

### Fixed

- Fastlane script bugs and configuration issues

### Changed

- Updated fastlane configuration and Ruby dependencies

## [0.0.2+8] - 2026-01-28

### Added

- Splash screen support for Android, iOS, and web
- iOS home screen widgets with ticket display
- Android home widget pin functionality
- PKPass file import support for Apple Wallet passes
- Deep link support for ticket widgets
- Share extension for receiving PDF intents on iOS
- SwiftLint CI workflow

### Fixed

- iOS PDF receiving via sharing intents
- Compile SDK version for Gemma AI integration
- TNSTC ticket parsing issues in PNR extraction
- Passenger pickup point extraction logic
- Launch mode to prevent duplicate instances when sharing on Android

### Changed

- Migrated to share_handler library for iOS sharing intents
- Updated deployment target to iOS 17.6
- Enhanced widget error handling and data display
- Improved PNR and trip code extraction from OCR text

### Removed

- Deprecated UIScene delegate methods

### Chores

- Updated Xcode project settings
- Configured compile SDK version
- Added FVM configuration (.fvmrc)

## [0.0.2+3] - 2025-12-19

### Added

- IRCTC train ticket SMS and PDF parser with station master data
- Station name resolution and train information extraction
- Web platform support with cross-platform file handling
- Web-specific services (OCRService, AIService, logging)
- GitHub Pages deployment workflow for Flutter web (WASM)
- Haptic feedback across import and ticket operations
- Calendar view redesign with date range filtering
- Custom snackbar widget with theme-aware colors
- Enhanced toast notifications with keyboard-aware positioning
- PDF support for TNSTC sharing intent
- All tickets view with navigation
- Unit tests for parsers, services, and providers

### Fixed

- FlutterGemma initialization error handling
- 16KB page alignment for flutter_gemma package
- Null-pointer exceptions in ticket.dart
- Dark mode toggle switch and upload PDF tap area
- Merge logic overwriting valid data with null values
- Wrap spacing calculation in itemWidth
- ProGuard rules for ML Kit text recognition

### Changed

- Feature-first Clean Architecture implementation
- Refactored to use GetIt dependency injection with interfaces
- Migrated all services to explicit DI with I-prefixed interfaces
- Consolidated travel parsing with IRCTC/SETC support
- Event and travel models with dart_mappable serialization
- Updated async patterns across codebase
- Improved error handling and date parsing across modules
- Enhanced OCR and PDF services with interface abstraction

### Removed

- Mocked data files and unused assets
- IRCTC and SETC parsers temporarily (consolidated to TNSTC)
- Travel from/to row widget
- Scanner view and SourceType enum entry

### Chores

- Release keystore configuration for Android
- Implemented keystore.properties for secure signing
- App icon configured for Android, iOS, and web
- Added very_good_analysis lint rules
- GitHub Actions for formatter checks and test coverage
- Codecov workflow integration
- Updated README with contributor guidelines

## [0.0.1+1] - 2025-11-18

### Added

- Initial release of Namma Wallet
- TNSTC bus ticket SMS and PDF parsing
- QR code and barcode scanning for tickets
- Ticket storage with SQLite database
- Calendar view for ticket timeline
- Home screen with ticket cards
- Import functionality (PDF, clipboard, QR)
- Share intent handling for tickets
- Theme support (light/dark mode)
- Google ML Kit OCR for text recognition
- Gemma AI fallback parser
- Ticket tagging and organization
- Export functionality

### Chores

- Project initialization and setup
- Flutter SDK and dependency configuration
- Android and iOS platform setup
- CI/CD pipeline setup
