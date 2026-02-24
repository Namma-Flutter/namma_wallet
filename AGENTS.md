# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository. Never run the app. Tell the user to run it. You don't need to listen to logs. let the user do it. Use dart mcp as much as possible.

## Development Commands

Always use `fvm flutter` instead of `flutter` commands.

### Essential Commands

```bash
# Install dependencies
fvm flutter pub get

# Run the app (use -d to specify device)
fvm flutter run

# Build for release
fvm flutter build apk
fvm flutter build ios

# Analyze code
fvm flutter analyze

# Run SwiftLint for iOS
cd ios && swiftlint

# Run tests (when available)
fvm flutter test
```

### Analyzer

Always use dart mcp server to analyze code.

### Development Setup

- Flutter SDK: 3.35.2 (managed via FVM)
- Minimum requirements: Android Studio/Xcode, Flutter SDK
- XCode version: 16.4.0

## Architecture Overview

This is a Flutter mobile application for managing digital tickets and passes. The codebase follows a feature-based architecture:

### Project Structure

```text
lib/
├── main.dart                    # App entry point
├── src/
    ├── app.dart                # Main app widget with bottom navigation
    ├── common/                 # Shared code across features
    │   ├── database/           # Database DAOs and interfaces
    │   ├── di/                 # Dependency injection setup
    │   ├── domain/             # Shared domain models
    │   │   └── models/         # Core models (Ticket, User, etc.)
    │   ├── enums/              # Shared enumerations
    │   ├── helper/             # Utility helpers
    │   ├── routing/            # App routing configuration
    │   ├── services/           # Core services (PDF, OCR, Logger)
    │   ├── theme/              # App theming
    │   └── widgets/            # Reusable UI widgets
    └── features/               # Feature modules
        ├── ai/                 # AI-powered parsing
        │   └── fallback_parser/ # Fallback AI parser for unsupported formats
        ├── bottom_navigation/  # App navigation bar
        ├── calendar/           # Calendar view for tickets
        ├── clipboard/          # Clipboard ticket import
        ├── events/             # Event ticket support
        ├── export/             # Wallet export functionality
        ├── home/               # Main home page
        ├── import/             # Import tickets from various sources
        ├── irctc/              # IRCTC train ticket support
        ├── pdf_extract/        # PDF parsing services
        ├── profile/            # User profile
        ├── receive/            # Share intent handling
        ├── tnstc/              # TNSTC bus ticket support
        └── travel/             # Generic travel ticket parsing
```

### Key Features

- **Ticket Management**: Save and organize tickets from various sources (SMS, PDF, manual entry)
- **PDF Processing**: Uses Syncfusion PDF library for ticket extraction
- **Multi-source Support**: TNSTC, SETC, buses, trains, general tickets

### Architecture Patterns

- **Feature-first architecture**: Each feature is a self-contained module with its own domain, application, and presentation layers
- **Clean Architecture**: Clear separation between domain (models, interfaces), application (services, use cases), data (repositories), and presentation (views, widgets)
- **Shared kernel**: Common domain models (Ticket, User) live in `common/domain/models/` to avoid circular dependencies
- **Interface-based design**: All services and repositories implement interfaces for testability and flexibility
- **Dependency injection**: GetIt service locator pattern used throughout the app
- **Service-oriented architecture**: Core services (PDF, OCR, Logger) are shared across features
- Bottom navigation with three main sections: Home, Calendar, Profile

### Dependencies

Key packages:

- `syncfusion_flutter_pdf`: PDF processing
- `file_picker`: File selection
- `uuid`: Unique identifier generation

### Code Style

- Uses `flutter_lints` for linting rules
- Standard Flutter/Dart conventions
- Analysis options configured in `analysis_options.yaml`

### Naming Conventions

- **Views**: Use "view" suffix for main/page widgets (e.g., `HomeView`, `TicketListView`)
  - File naming: `home_view.dart`, `ticket_list_view.dart`
  - Class naming: `class HomeView extends StatefulWidget`
- **Widgets**: Use "widget" suffix for smaller reusable components (e.g., `TicketCardWidget`, `ButtonWidget`)
  - File naming: `ticket_card_widget.dart`, `button_widget.dart`
  - Class naming: `class TicketCardWidget extends StatelessWidget`

### Error Handling and Parsing Rules

### CRITICAL: Never Fall Back to Default Values

- **Never use fallback/default values** when parsing fails
- **Always return `null`** if parsing, extraction, or validation fails
- **Never silently substitute** with current date, empty strings, or placeholder values
- **Explicit failure is better than implicit incorrect data**

Examples:
- ❌ Bad: Date parsing fails → fallback to `DateTime.now()`
- ✅ Good: Date parsing fails → return `null`
- ❌ Bad: PNR extraction fails → use `"Unknown"`
- ✅ Good: PNR extraction fails → return `null` or empty string `""`
- ❌ Bad: Malformed data → substitute with default value
- ✅ Good: Malformed data → return `null`

**Why?**
- Prevents silent data corruption
- Makes errors visible and debuggable
- Allows callers to handle missing data appropriately
- Maintains data integrity

### OCR and Layout-Based Extraction

#### Handling Multiple Key-Value Pairs in Single OCR Blocks

When OCR extracts text from PDFs, sometimes multiple key-value pairs appear
in a single text block on the same line. The `LayoutExtractor` has been
enhanced to handle this:

**Problem:**
```
OCR Block text: "Passenger Pickup Point : CHENNAI Passenger Pickup Time: 21:00"
```

**Solution:**
The `_extractInlineValue` method now detects when multiple key-value pairs
exist in the same block and extracts only the value for the requested key,
stopping at the next key.

**Example:**
- Input block: `"Passenger Pickup Point : CHENNAI Passenger Pickup Time: 21:00"`
- `findValueForKey('Passenger Pickup Point')` returns: `"CHENNAI"`
- `findValueForKey('Passenger Pickup Time')` returns: `"21:00"`

**Implementation:**
- Finds the specific key position in the text
- Extracts text after the colon following that key
- Uses regex pattern to detect the start of the next key (pattern: word(s) followed by `:`)
- Truncates the value at the next key boundary

This prevents extraction errors where one field's value incorrectly includes
the next field's label and value.

### Passenger Table Extraction with Missing Columns

When extracting passenger information from tables, some rows may have missing
columns (e.g., missing Gender value). The parser now uses column alignment
based on header positions instead of simple array indexing.

**Problem:**
```
Row 1: [Name, Age, Type, Gender, Seat]  // 5 columns
Row 2: [Name, Age, Type, Gender, Seat]  // 5 columns
Row 3: [Name, Age, Type, Seat]          // 4 columns (missing Gender)
```

Old behavior with array indexing:
- Row 3: row[3] = "Seat Number" → incorrectly assigned as gender

**Solution:**
The `_extractPassengers` method now:
1. Identifies header row and records X-coordinate positions for each column
2. For data rows, assigns each block to its column based on X-position proximity
3. Missing columns don't cause misalignment of other columns

**Example:**
- Row 3 with missing Gender: correctly assigns Seat to seatNumber field
- All three passengers extracted with correct seat numbers

### OCR Error Correction for Seat Numbers

Common OCR errors in seat numbers are automatically corrected:

**Problem:** OCR misreads characters in seat numbers
- "U" (letter U) is read as "0" (zero)
- Example: Actual seat "12UB" is read as "120B"

**Solution:** Automatic pattern-based correction
- Pattern `\d+0B$` → corrected to end with "UB"
- Pattern `\d+0L$` → corrected to end with "UL"

**Examples:**
- `120B` → `12UB` ✓
- `30B` → `3UB` ✓
- `150L` → `15UL` ✓

This correction is applied during passenger extraction, ensuring seat numbers
are displayed correctly even when OCR misreads them.
