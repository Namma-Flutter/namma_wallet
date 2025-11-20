# 👜 Namma Wallet
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-9-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

**Namma Wallet** is an open-source Flutter mobile application for managing digital travel tickets and passes. The app provides a unified interface to save, organize, and view tickets from multiple sources including SMS, PDFs, QR codes, and clipboard text. It features intelligent parsing for Indian transport providers and generates beautiful digital ticket designs.

Unlike Apple Wallet or Google Wallet, which support only specific formats, **Namma Wallet** is a flexible, community-driven solution that works with any ticket type and format.

---

## ✨ Features

### 📱 **Multi-Source Ticket Management**

* **SMS Parsing** – Automatically extract tickets from TNSTC, IRCTC, and SETC SMS messages
* **PDF Processing** – Parse TNSTC bus tickets from PDF files using Syncfusion PDF library
* **QR Code Scanning** – Scan IRCTC train ticket QR codes with full metadata extraction
* **Clipboard Processing** – Read and parse travel ticket text from clipboard
* **Manual Entry** – Direct ticket input with form validation

### 🎫 **Supported Ticket Types**

* **Bus Tickets** – TNSTC (Tamil Nadu State Transport), SETC (State Express Transport)
* **Train Tickets** – IRCTC with complete QR code support and PNR lookup
* **Event Tickets** – Concert, movie, and general event passes
* **Flight/Metro** – Model support for future implementations

### 💾 **Data Management**

* **SQLite Database** – Local storage with comprehensive ticket metadata
* **Duplicate Prevention** – Smart detection based on PNR/booking references
* **Export Functionality** – Data export capabilities for backup
* **Share Integration** – Handle PDF files shared from other applications

### 🗂 **Organization & Navigation**

* **Bottom Navigation** – Three-tab layout (Home, Scanner, Calendar)
* **Filtering & Search** – Organize tickets by date, provider, and type
* **State Management** – Persistent navigation and data state

---

## 🚀 Getting Started

### Prerequisites

* **Flutter SDK** - 3.35.2 (managed via FVM)
* **Android Studio** / **Xcode** - For mobile app development
* **Xcode** - 16.4.0 (for iOS development)
* **FVM** - Flutter Version Management (recommended)

### Project Architecture

This app follows a **feature-based architecture** with clean separation of concerns:

```text
lib/src/
├── app.dart                    # Main app widget with navigation
├── common/                     # Shared utilities and services
│   ├── helper/                 # Helper functions and utilities
│   ├── routing/                # Go Router configuration
│   ├── services/               # Core services (database, sharing)
│   ├── theme/                  # App theming and styles
│   └── widgets/                # Shared UI components
└── features/                   # Feature modules
    ├── bottom_navigation/      # Navigation bar implementation
    ├── calendar/               # Calendar view with events
    ├── clipboard/              # Clipboard text processing
    ├── events/                 # Event management
    ├── export/                 # Data export functionality
    ├── home/                   # Main home page with ticket cards
    ├── irctc/                  # IRCTC train ticket support
    ├── pdf_extract/            # PDF parsing services
    ├── profile/                # User profile and settings
    ├── scanner/                # QR/PDF scanning interface
    ├── sms_extract/            # SMS ticket extraction
    ├── tnstc/                  # TNSTC bus ticket support
    └── travel/                 # Travel ticket display
```

### Setup & Installation

```bash
# Clone the repository
git clone https://github.com/<your-username>/namma_wallet.git
cd namma_wallet

# Install FVM (if not already installed)
dart pub global activate fvm

# Use Flutter 3.35.2 via FVM
fvm use 3.35.2

# Get dependencies
fvm flutter pub get

# Run the app (specify device with -d flag)
fvm flutter run

# For specific device
fvm flutter run -d <device-id>
```

### Development Commands

```bash

# Analyze code
fvm flutter analyze

# Run tests (when available)
fvm flutter test

# Build for release
fvm flutter build apk          # Android APK
fvm flutter build ios          # iOS IPA
```

### Build Commands with Makefile

The project includes a `Makefile` for streamlined build processes. By default, it uses FVM (`fvm flutter` and `fvm dart`), but you can override this behavior.

#### Available Targets

**Utility Commands:**

```bash
make help       # Display all available commands
make clean      # Clean the project
make get        # Get dependencies
make codegen    # Run code generation
```

**Release Builds:**

```bash
make release-apk        # Build Android release APK
make release-appbundle  # Build Android release App Bundle
make release-ipa        # Build iOS release IPA
```

All release builds automatically:

1. Get dependencies
2. Run code generation
3. Remove WASM modules (via `dart run pdfrx:remove_wasm_modules`) to reduce app size
4. Build the release version

#### Using Without FVM

If you're not using FVM, override the `FLUTTER` and `DART` variables:

```bash
# Build with regular Flutter/Dart
FLUTTER=flutter DART=dart make release-apk

# Or export them for the session
export FLUTTER=flutter
export DART=dart
make release-apk
```

#### CI/CD Integration

The release workflow in `.github/workflows/build_and_release.yml` automatically removes WASM modules before building releases for optimal app size.

---

## 🛠 Development Notes

### Code Style & Conventions

* Uses `flutter_lints` for consistent code formatting
* **Views** use "view" suffix for main/page widgets (e.g., `HomeView`)
* **Widgets** use "widget" suffix for reusable components (e.g., `TicketCardWidget`)
* Follows standard Flutter/Dart conventions with analysis options configured

### Testing

* Unit tests for parsing services and data models
* Widget tests for UI components
* Integration tests for full user workflows

### Database Schema

* Single `travel_tickets` table supporting all ticket types
* Generic schema with enum mapping for type safety
* Migration support for schema updates
* Optimized indexing for user, date, and type queries

---

## 🤝 Contributing

We welcome contributions from the community! 🚀

### How to Contribute

1. **Fork** this repository
2. Create a **feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. Open a **Pull Request**

### Development Guidelines

* Follow the existing code style and architecture patterns
* Add tests for new features and bug fixes
* Update documentation for significant changes
* Use conventional commit messages
* Ensure all CI checks pass before submitting PR

### 🧩 Commit & Branch Naming Guidelines

To maintain a clean and consistent Git history, **Namma Wallet** follows the [**Conventional Commits**](https://www.conventionalcommits.org/en/v1.0.0/) specification and a structured **branch naming convention**.

#### ✅ **Commit Message Format**

Each commit message should follow this pattern:

```text
<type>(<scope>): <short summary>
```

**Examples:**

```text
feat: add TNSTC SMS parsing support
fix: resolve PNR extraction issue in QR scan
chore: update flutter_lints version
docs: add installation guide
```

**Common Commit Types:**

| Type       | Description                                       |
| ---------- | ------------------------------------------------- |
| `feat`     | Introduces a new feature                          |
| `fix`      | Fixes a bug                                       |
| `docs`     | Documentation-only changes                        |
| `style`    | Formatting changes (no logic change)              |
| `refactor` | Code restructuring without changing functionality |
| `perf`     | Performance improvement                           |
| `test`     | Adding or updating tests                          |
| `build`    | Changes to build tools or dependencies            |
| `chore`    | Routine tasks or maintenance work                 |

> 🔹 Keep commit summaries under **72 characters** and start with a **lowercase** verb.
> 🔹 Use the **imperative mood** — e.g., “add” instead of “added” or “adds”.

---

#### 🌿 **Branch Naming Convention**

Branch names should follow this format:

```text
<type>/<short-description>
```

**Examples:**

```text
feature/pdf-parsing
fix/calendar-event-display
docs/update-readme
refactor/database-schema
```

**Allowed Branch Prefixes:**

| Prefix      | Purpose                      |
| ----------- | ---------------------------- |
| `feature/`     | For new features             |
| `fix/`      | For bug fixes                |
| `hotfix/`   | For urgent production fixes  |
| `refactor/` | For code restructuring       |
| `docs/`     | For documentation updates    |
| `chore/`    | For non-functional tasks     |
| `test/`     | For testing-related branches |

> 💡 Keep branch names **short**, use **kebab-case**, and avoid personal prefixes like `harish-` unless collaborating on shared experimental branches.

## 🏗 Technical Implementation

### Key Dependencies

#### Core Libraries

* **`syncfusion_flutter_pdf`** - PDF text extraction and processing
* **`ai_barcode_scanner`** - QR code scanning functionality
* **`sqflite`** - Local SQLite database storage
* **`go_router`** - Declarative navigation and routing
* **`dart_mappable`** - Type-safe serialization/deserialization

#### UI/UX Libraries

* **`card_stack_widget`** - Swipeable card stack for ticket display
* **`table_calendar`** - Calendar view implementation
* **`google_fonts`** - Typography and font management
* **`flutter_svg`** - SVG asset support

#### Integration Libraries

* **`file_picker`** - PDF file selection
* **`shared_preferences`** - Local settings storage
* **`listen_sharing_intent`** - Handle shared files from other apps
* **`provider`** - State management for calendar features

### Architecture Pattern

* **Feature-Based Organization** - Each feature module contains domain, application, and presentation layers

---

## 📌 Roadmap

### ✅ Completed Features

* [x] SMS ticket parsing (TNSTC, IRCTC, SETC)
* [x] PDF ticket extraction (TNSTC)
* [x] QR code scanning (IRCTC)
* [x] Clipboard text processing
* [x] SQLite database with migration support
* [x] Card stack UI with swipe functionality
* [x] Calendar view for events and travel
* [x] Bottom navigation with three main sections
* [x] Duplicate ticket prevention
* [x] Share intent handling for PDFs

### 🚧 In Progress

* [ ] Enhanced error handling and user feedback
* [ ] Performance optimizations for large datasets
* [ ] Additional transport provider support

### 📅 Future Plans

* [ ] Cloud backup & synchronization
* [ ] Ticket sharing with friends and family
* [ ] Home screen widgets for quick access
* [ ] Offline ticket access and storage
* [ ] Push notifications for travel reminders
* [ ] Multi-language support (Tamil, Hindi, etc.)
* [ ] Dark mode theme support
* [ ] Advanced filtering and search capabilities

---

## 📄 License

This project is licensed under the **MIT License** – see the [LICENSE](LICENSE) file for details.

---

## ❤️ Acknowledgements

* Inspired by **Apple Wallet** & **Google Wallet**, but built for Indian transport systems and community needs
* **Syncfusion** for providing excellent PDF processing capabilities
* **Flutter** team for the amazing cross-platform framework
* **Open source community** for continuous support and contributions
* **Indian transport providers** (TNSTC, IRCTC, SETC) for standardized ticket formats

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/jolan94"><img src="https://avatars.githubusercontent.com/u/61643920?v=4?s=100" width="100px;" alt="Joe Jeyaseelan"/><br /><sub><b>Joe Jeyaseelan</b></sub></a><br /><a href="https://github.com/Namma-Flutter/namma_wallet/commits?author=jolan94" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Harishwarrior"><img src="https://avatars.githubusercontent.com/u/38380040?v=4?s=100" width="100px;" alt="Harish Anbalagan"/><br /><sub><b>Harish Anbalagan</b></sub></a><br /><a href="https://github.com/Namma-Flutter/namma_wallet/commits?author=Harishwarrior" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://mageshportfolio.netlify.app/"><img src="https://avatars.githubusercontent.com/u/127011222?v=4?s=100" width="100px;" alt="Magesh K"/><br /><sub><b>Magesh K</b></sub></a><br /><a href="https://github.com/Namma-Flutter/namma_wallet/commits?author=Magesh-kanna" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/kumaran-flutter"><img src="https://avatars.githubusercontent.com/u/117720053?v=4?s=100" width="100px;" alt="Kumaran"/><br /><sub><b>Kumaran</b></sub></a><br /><a href="https://github.com/Namma-Flutter/namma_wallet/commits?author=kumaran-flutter" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://srinivasanr.me"><img src="https://avatars.githubusercontent.com/u/92676627?v=4?s=100" width="100px;" alt="Srinivasan R"/><br /><sub><b>Srinivasan R</b></sub></a><br /><a href="https://github.com/Namma-Flutter/namma_wallet/commits?author=Srinivasan8888" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/imsarkie"><img src="https://avatars.githubusercontent.com/u/119160091?v=4?s=100" width="100px;" alt="Saravana"/><br /><sub><b>Saravana</b></sub></a><br /><a href="https://github.com/Namma-Flutter/namma_wallet/commits?author=imsarkie" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/AkashProfessionalCoder"><img src="https://avatars.githubusercontent.com/u/115221061?v=4?s=100" width="100px;" alt="Akash Senthil"/><br /><sub><b>Akash Senthil</b></sub></a><br /><a href="https://github.com/Namma-Flutter/namma_wallet/commits?author=AkashProfessionalCoder" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/rengapraveenx"><img src="https://avatars.githubusercontent.com/u/70749271?v=4?s=100" width="100px;" alt="Renga Praveen Kumar"/><br /><sub><b>Renga Praveen Kumar</b></sub></a><br /><a href="https://github.com/Namma-Flutter/namma_wallet/commits?author=rengapraveenx" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/KeerthiVasan-ai"><img src="https://avatars.githubusercontent.com/u/97495357?v=4?s=100" width="100px;" alt="Keerthivasan S"/><br /><sub><b>Keerthivasan S</b></sub></a><br /><a href="https://github.com/Namma-Flutter/namma_wallet/commits?author=KeerthiVasan-ai" title="Code">💻</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
