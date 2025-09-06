# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository. Read Serena's initial Instructions for more details.

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

# Run tests (when available)
fvm flutter test
```

### Development Setup
- Flutter SDK: 3.35.2 (managed via FVM)
- Minimum requirements: Android Studio/Xcode, Flutter SDK
- XCode version: 16.4.0

## Architecture Overview

This is a Flutter mobile application for managing digital tickets and passes. The codebase follows a feature-based architecture:

### Project Structure
```
lib/
├── main.dart                    # App entry point
├── src/
    ├── app.dart                # Main app widget with bottom navigation
    └── features/               # Feature modules
        ├── calendar/           # Calendar view for tickets
        ├── export/             # Wallet export functionality  
        ├── home/               # Main home page
        ├── pdf_extract/        # PDF parsing services
        ├── profile/            # User profile
        ├── sms_extract/        # SMS ticket extraction
        └── ticket_parser/      # Ticket parsing logic
```

### Key Features
- **Ticket Management**: Save and organize tickets from various sources (SMS, PDF, manual entry)
- **PDF Processing**: Uses Syncfusion PDF library for ticket extraction
- **Google Wallet Integration**: Export tickets using add_to_google_wallet package
- **Multi-source Support**: TNSTC, SETC, buses, trains, general tickets

### Architecture Patterns
- Feature-based folder structure with `presentation/` and `application/` layers
- Service-oriented architecture for core functionality (PDF, SMS, file picker services)
- Bottom navigation with three main sections: Home, Calendar, Profile

### Dependencies
Key packages:
- `syncfusion_flutter_pdf`: PDF processing
- `add_to_google_wallet`: Wallet integration  
- `file_picker`: File selection
- `uuid`: Unique identifier generation

### Code Style
- Uses `flutter_lints` for linting rules
- Standard Flutter/Dart conventions
- Analysis options configured in `analysis_options.yaml`