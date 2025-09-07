# Code Style and Conventions

## Linting and Analysis
- Uses **flutter_lints** package version ^4.0.0
- Analysis options configured to include `package:flutter_lints/flutter.yaml`
- Standard Flutter/Dart conventions followed throughout

## Naming Conventions
- **Classes**: PascalCase (e.g., `NammaWalletApp`, `HomePage`)
- **Files**: snake_case (e.g., `home_page.dart`, `pdf_service.dart`)
- **Variables**: camelCase (e.g., `currentPageIndex`, `extractedText`)
- **Constants**: camelCase or UPPER_SNAKE_CASE for compile-time constants

## File Organization
- Feature-based structure with `presentation/` and `application/` folders
- Service classes end with `Service` (e.g., `PDFService`, `SMSService`)
- Page classes end with `Page` (e.g., `HomePage`, `CalendarPage`)
- Stateful widgets follow Flutter conventions with separate State classes

## Import Style
- Flutter imports first
- Package imports second
- Local project imports last
- Relative imports used for project files

## Widget Structure
- Stateful widgets for pages with navigation and state management
- Const constructors used where possible
- Material Design components throughout
- Bottom navigation pattern for main app structure

## Code Quality
- No custom linting rules defined (uses flutter_lints defaults)
- Standard Dart formatting expected
- Comments minimal but descriptive when present