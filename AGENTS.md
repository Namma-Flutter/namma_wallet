# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository. Never run the app. Tell the user to run it.
You don't need to listen to logs. Let the user do it. Use dart mcp as
much as possible.

## Development Commands

Always use `fvm flutter` instead of `flutter` commands.

```bash
# Install dependencies
fvm flutter pub get

# Analyze code (prefer dart mcp server)
fvm flutter analyze

# Run tests
fvm flutter test

# Code generation (after changing models)
fvm dart run build_runner build --delete-conflicting-outputs

# Release builds (always use Makefile)
make release-apk
make release-appbundle
make release-ipa
```

Always use dart mcp server to analyze code.

### Development Setup

- Flutter SDK: 3.38.6 (managed via FVM, Dart SDK 3.10.7)
- Xcode: 16.4.0
- Minimum requirements: Android Studio / Xcode, FVM

## Architecture

Feature-based Clean Architecture with GetIt for DI,
GoRouter for navigation, and Provider for theme state.

### Project Structure

```text
lib/src/
├── app.dart                     # Main app widget
├── common/                      # Shared code
│   ├── database/                # SQLite DAOs (sqflite)
│   ├── di/locator.dart          # GetIt service registration
│   ├── domain/models/           # Ticket, User, ExtrasModel
│   ├── enums/                   # TicketType, etc.
│   ├── routing/                 # GoRouter + AppRoute enum
│   ├── services/                # Logger, OCR, PDF, Haptic, Widget
│   ├── theme/                   # Material 3 light/dark themes
│   └── widgets/                 # Shared UI components
└── features/
    ├── ai/                      # Gemma AI fallback parser
    ├── bottom_navigation/       # Navigation bar
    ├── calendar/                # Calendar view (TableCalendar)
    ├── clipboard/               # Clipboard ticket parsing
    ├── common/generated/        # flutter_gen output
    ├── events/                  # Event ticket support
    ├── export/                  # Export functionality
    ├── home/                    # Home screen + ticket cards
    ├── import/                  # File import (PDF, PKPass)
    ├── irctc/                   # IRCTC train tickets
    ├── receive/                 # Share intent / deep link handling
    ├── settings/                # Settings, DB viewer, OCR debug
    ├── tnstc/                   # TNSTC/SETC bus tickets
    └── travel/                  # Travel parser orchestration + PKPass
```

### Layer Convention (per feature)

Each feature follows this internal structure:

- `application/` - Services, use cases, business logic
- `domain/` - Models (with `@MappableClass()`)
- `presentation/` - Views and widgets
- `data/` - Repositories, remote/local data sources

### Key Design Patterns

- **Strategy**: `TravelParserService` dispatches to TNSTC/SETC/IRCTC parsers
- **DAO**: Database abstraction (`ITicketDAO`, `IUserDAO`)
- **Service Locator**: GetIt singleton/lazy-singleton registration
- **Interface Segregation**: All services have `I`-prefixed interfaces
- **Facade**: `ImportService` coordinates PDF, OCR, parser, and DB services
- **Observer**: `TicketChangeNotifier` for reactive ticket list updates

### Dependency Injection (locator.dart)

All services registered in `lib/src/common/di/locator.dart` via GetIt.
Platform-specific implementations selected with `kIsWeb`:

- `ILogger` → `NammaLogger` (Talker)
- `IWalletDatabase` → `WalletDatabase` (sqflite)
- `IOCRService` → `GoogleMLKitOCR` / `WebOCRService`
- `IPDFService` → `PDFService` (Syncfusion + OCR fallback)
- `IAIService` → `GemmaService` / `WebGemmaService`
- `IHapticService` → `HapticService`
- `IWidgetService` → `HomeWidgetService` / `WebWidgetService`
- Parsers: `ITravelParser`, `IPKPassParser`, `IIRCTCParser`

### Database

SQLite via sqflite. Database: `namma_wallet.db`, version 4.

**tickets table**: id, ticket_id (unique), primary_text,
secondary_text, type, start_time, end_time (nullable),
location, tags (JSON), extras (JSON), image_path,
directions_url, created_at, updated_at.

DAO methods: `handleTicket()` (upsert), `getAllTickets()`,
`getTicketById()`, `updateTicket()`, `deleteTicket()`.

### Routing

GoRouter with `AppRoute` enum. Deep link scheme: `nammawallet://`.
Shell route wraps Home, Import, Calendar with bottom navigation.

### Serialization

`dart_mappable` with `@MappableClass()`. Generated `.mapper.dart`
files provide `toMap()`, `toJson()`, `fromMap()`, `fromJson()`.
Run `make codegen` after changing models.

## Naming Conventions

| Type | Convention | Example |
| --- | --- | --- |
| Views (pages) | `*View` | `HomeView`, `CalendarView` |
| Widgets (reusable) | `*Widget` | `TicketCardWidget` |
| Interfaces | `I*` prefix | `ILogger`, `ITicketDAO` |
| Services | `*Service` | `ImportService`, `PDFService` |
| Providers | `*Provider` | `ThemeProvider`, `CalendarProvider` |
| Models | `*Model` | `TNSTCTicketModel`, `EventModel` |
| Files | snake_case | `home_view.dart`, `locator.dart` |
| Classes | PascalCase | `TravelParserService` |
| Enums | PascalCase | `TicketType`, `AppRoute` |

## Code Style

- Linting: `very_good_analysis` (strict)
- Generated files (`*.mapper.dart`, `*.gen.dart`) excluded from lint
- `public_member_api_docs` rule is disabled
- Logging: Talker in debug, disabled in production (no PII)

## Error Handling

### CRITICAL: Never Fall Back to Default Values

- **Never use fallback/default values** when parsing fails
- **Always return `null`** if parsing, extraction, or validation fails
- **Never silently substitute** with current date, empty strings,
  or placeholder values
- **Explicit failure is better than implicit incorrect data**

Examples:

- Bad: Date parsing fails → fallback to `DateTime.now()`
- Good: Date parsing fails → return `null`
- Bad: PNR extraction fails → use `"Unknown"`
- Good: PNR extraction fails → return `null`

## Parser System

### Travel Parser Strategy

`TravelParserService` routes to the correct parser based on input:

```text
Input (SMS/PDF/QR)
  → TravelParserService.canParse() / isSMSFormat()
    → TNSTCBusParser   (TNSTC + SETC buses)
    → IRCTCTrainParser (Indian Railways)
    → PKPassParser     (Apple Wallet .pkpass files)
```

Each parser implements:

- `canParse(String)` → bool
- `parseTicket(String)` → Ticket (SMS)
- `parseTicketFromBlocks(List<OCRBlock>)` → Ticket (PDF)
- `isSMSFormat(String)` → bool
- `parseUpdate(String)` → TicketUpdateInfo? (updates)

### OCR and Layout-Based Extraction

**Inline key-value splitting**: When OCR extracts multiple key-value
pairs in one text block, `_extractInlineValue` splits by detecting
the next key (pattern: words followed by `:`).

**Column-aligned table parsing**: Passenger tables with missing
columns use header X-coordinate positions instead of array indexing
to avoid column misalignment.

**OCR error correction**: Seat number patterns like `120B` are
auto-corrected to `12UB` (OCR misreads `U` as `0`).
Patterns: `\d+0B$` → `UB`, `\d+0L$` → `UL`.

## Deployment

Three-stage pipeline via Makefile + Fastlane:

```text
Beta → Release Candidate → Production
```

| Stage | Android | iOS |
| --- | --- | --- |
| Beta | `make android-beta` | `make ios-beta` |
| RC | `make android-release-candidate` | `make ios-release-candidate` |
| Production | `make android-production` | `make ios-production` |

Combined: `make deploy-beta`, `make deploy-release-candidate`,
`make deploy-production`.

All versions read from `pubspec.yaml`. Never build directly
with `flutter build` — always use Makefile targets.

## Testing

Test structure mirrors `lib/src/`:

```text
test/
├── src/features/          # Feature tests
├── fixtures/              # SMS/layout test data
└── helpers/               # Test utilities
```

- Unit tests: Parser logic, service methods
- Widget tests: Provider state, UI interactions
- Mocking: `mockito` for service interfaces
- Fixtures: Real SMS and PDF layout data
- Coverage: `make coverage` (excludes `*.g.dart`)

## Key Dependencies

| Package | Purpose |
| --- | --- |
| `get_it` | Dependency injection |
| `go_router` | Navigation and deep links |
| `provider` | Theme state management |
| `sqflite` | SQLite database |
| `dart_mappable` | JSON serialization (code-gen) |
| `syncfusion_flutter_pdf` | PDF text extraction |
| `google_mlkit_text_recognition` | OCR (mobile) |
| `pkpass` | Apple Wallet pass parsing |
| `flutter_gemma` | On-device AI model |
| `table_calendar` | Calendar widget |
| `talker_flutter` | Logging framework |
| `home_widget` | Home screen widget |
| `share_handler` | Share intent handling |
| `ai_barcode_scanner` | QR/barcode scanning |

## Platform-Specific Notes

### iOS

- Deep links via `AppDelegate.swift` (MethodChannel)
- Home widget via WidgetKit (iOS 17+)
- App group: `group.com.nammaflutter.nammawallet`
- Share extension for .pkpass files

### Android

- Home screen widget (`TicketListWidgetProvider`)
- Background tasks via WorkManager
- App shortcuts support
- Signing via keystore (managed by Fastlane)
