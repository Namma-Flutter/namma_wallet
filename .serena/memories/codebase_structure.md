# Codebase Structure

## Project Layout
```
lib/
├── main.dart                    # App entry point
├── src/
    ├── app.dart                # Main app widget with bottom navigation
    └── features/               # Feature-based organization
        ├── calendar/           # Calendar view for tickets
        │   └── presentation/   # Calendar UI components
        ├── export/             # Wallet export functionality
        │   ├── application/    # Export services
        │   └── presentation/   # Export UI components
        ├── home/               # Main home page
        │   ├── application/    # Home business logic
        │   └── presentation/   # Home UI components
        ├── pdf_extract/        # PDF parsing services
        │   └── application/    # PDF processing logic
        ├── profile/            # User profile
        │   └── presentation/   # Profile UI components
        ├── sms_extract/        # SMS ticket extraction
        │   └── application/    # SMS processing logic
        └── ticket_parser/      # Ticket parsing logic
            └── application/    # Parsing business logic
```

## Architecture Patterns
- **Feature-based folder structure** with clear separation of concerns
- **Presentation/Application layer separation** within each feature
- **Service-oriented architecture** for core functionality
- **Stateful widgets** with bottom navigation for main app flow

## Key Files
- `lib/main.dart`: Application entry point
- `lib/src/app.dart`: Main app structure with NavigationBar
- `pubspec.yaml`: Project configuration and dependencies
- `analysis_options.yaml`: Code analysis rules
- `.fvmrc`: Flutter version management configuration

## Feature Organization
Each feature follows a consistent structure:
- `presentation/`: UI components and pages
- `application/`: Business logic and services
- Services include: PDF processing, SMS extraction, file picking, wallet integration