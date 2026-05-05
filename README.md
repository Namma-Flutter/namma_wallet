# 👜 Namma Wallet

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-10-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

**Namma Wallet** is an open-source Flutter mobile application for managing digital travel tickets and passes. The app provides a unified interface to save, organise, and view tickets from multiple sources, including SMS, PDFs, QR codes, and clipboard text. It features intelligent parsing for Indian transport providers and generates beautiful digital ticket designs.

Unlike Apple Wallet or Google Wallet, which support only specific formats, **Namma Wallet** is a flexible, community-driven solution that works with any ticket type and format.

[![Get it on Google Play](assets/badges/google_play_badge.svg)](https://play.google.com/store/apps/details?id=com.nammaflutter.nammawallet) [![Download on the App Store](assets/badges/app_store_badge.svg)](https://apps.apple.com/in/app/namma-wallet/id6757295408)

---

## ✨ Features

### 📱 **Multi-Source Ticket Management**

* **SMS Parsing** – Automatically extract tickets from TNSTC, IRCTC, and SETC SMS messages
* **PDF Processing** – Parse TNSTC bus tickets from PDF files using Syncfusion PDF library
* **QR Code Scanning** – Scan IRCTC train ticket QR codes with full metadata extraction
* **Clipboard Processing** – Read and parse travel ticket text from the clipboard

### 🎫 **Supported Ticket Types**

* **Bus Tickets** – TNSTC (Tamil Nadu State Transport), SETC (State Express Transport)
* **Train Tickets** – IRCTC with complete QR code support and PNR lookup
* **Event Tickets** – Concert, movie, and general event passes
* **Flight/Metro** – Model support for future implementations

### 🍎 **Apple Wallet Pass (.pkpass) Support**

Namma Wallet can import and display `.pkpass` files — the standard format used by Apple Wallet for boarding passes, event tickets, coupons, and store cards.

**Supported pass types:**

| Pass type | Examples |
| --- | --- |
| Boarding Pass | Flights, trains, buses |
| Event Ticket | Concerts, conferences, sports |
| Coupon | Discount and loyalty passes |
| Store Card | Membership and reward cards |
| Generic | Any other pass format |

**How to import a `.pkpass` file:**

* **Share** — Open a `.pkpass` file from Mail, Safari, Files, or any app and share it to Namma Wallet
* **File picker** — Use the import screen to pick a `.pkpass` file directly
* **Deep link** — Open a `.pkpass` file with Namma Wallet set as the default handler

**What gets extracted:**

* Ticket ID, PNR, or confirmation number (from barcode or pass fields)
* Origin → Destination or event name
* Date, time, and relevant location
* Gate, seat, platform, or venue details
* Pass thumbnail or logo image
* Provider/organisation name

**Pass updates:**

Passes that include a `webServiceURL` (e.g. Luma event passes) are automatically refreshed from the provider's server using the standard Apple Pass web service protocol.

---

## 📸 Screenshots

| Home | All Tickets | Ticket View |
| --- | --- | --- |
| ![Home](assets/screenshots/home.png) | ![All Tickets](assets/screenshots/all_tickets.png) | ![Ticket View](assets/screenshots/ticket_view.png) |

| Import | Calendar | Settings |
| --- | --- | --- |
| ![Import](assets/screenshots/import.png) | ![Calendar](assets/screenshots/calendar.png) | ![Settings](assets/screenshots/settings.png) |

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

# Run SwiftLint for iOS
cd ios && swiftlint

# Run tests (when available)
fvm flutter test
```

---

## 🏗️ Building the App

**⚠️ IMPORTANT: Always use the Makefile for building releases. Never use `flutter build` commands directly.**

The project includes a `Makefile` that handles all necessary build steps, including critical optimizations like WASM module removal. By default, it uses FVM (`fvm flutter` and `fvm dart`), but you can override this behaviour.

### Available Targets

**Utility Commands:**

```bash
make help       # Display all available commands
make clean      # Clean the project
make get        # Get dependencies
make codegen    # Run code generation
```

**Release Builds (ALWAYS USE THESE):**

```bash
make release-apk        # Build Android release APK
make release-appbundle  # Build Android release App Bundle
make release-ipa        # Build iOS release IPA
```

### Why Use Makefile?

All release builds automatically:

1. Get dependencies (`fvm flutter pub get`)
2. Run code generation (`build_runner`)
3. **Remove WASM modules** (via `dart run pdfrx:remove_wasm_modules`) - **Required for pdfrx package**
4. Build the release version

**Skipping the Makefile will result in bloated app sizes and potential build issues.**

### Using Without FVM

If you're not using FVM, override the `FLUTTER` and `DART` variables:

```bash
# Build with regular Flutter/Dart
FLUTTER=flutter DART=dart make release-apk

# Or export them for the session
export FLUTTER=flutter
export DART=dart
make release-apk
```

### Fastlane Integration

Our fastlane scripts use the Makefile internally to ensure consistent builds across all environments.

---

## 🚢 Deployment

Deployments are managed via Fastlane. Each platform has three lanes that mirror the same release pipeline.

### Release Pipeline

```text
Beta (closed testing) → Release Candidate (open/external testing) → Production
```

| Stage | Android track | iOS destination |
| --- | --- | --- |
| Beta | `namma-flutter-int-track` | TestFlight |
| Release Candidate | Open Testing (`beta`) | NammaFlutter + External groups |
| Production | Production | App Store |

### Fastlane Setup

Install Fastlane bundle dependencies before running any lane:

```bash
cd android && bundle install && cd ..
cd ios && bundle install && cd ..
```

Each platform requires a `.env.local` file in its `fastlane/` directory with the required credentials. See `.env.local.example` for the required keys.

### Commands

Deploy both platforms together:

```bash
make deploy-beta               # Build and upload to beta tracks
make deploy-release-candidate  # Promote beta → RC on both platforms
make deploy-production         # Promote RC → production on both platforms
```

Or deploy a single platform:

```bash
# Android
make android-beta
make android-release-candidate
make android-production

# iOS
make ios-beta
make ios-release-candidate
make ios-production
```

### What each lane does

**`beta`** — Reads version from `pubspec.yaml`, validates no duplicate build exists, builds the app via `make release-appbundle` / `make release-ipa`, and uploads to the beta track.

**`release-candidate`** — Promotes the current `pubspec.yaml` build from the beta track to the RC track/groups. No rebuild required.

**`production`** — Promotes the current `pubspec.yaml` build to production.

### CI/CD Integration

The release workflow in `.github/workflows/build_and_release.yml` uses the Makefile for all release builds to maintain consistency.

---

## 🛠 Development Notes

### Code Style & Conventions

* Uses `very_good_analysis` for consistent code linting
* Uses `dart format .` for code formatting
* **Views** use "view" suffix for main/page widgets (e.g., `HomeView`)
* **Widgets** use "widget" suffix for reusable components (e.g., `TicketCardWidget`)
* Follows standard Flutter/Dart conventions with analysis options configured

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

## 📄 License

This project is licensed under the **MIT License** – see the [LICENSE](LICENSE) file for details.

---

## ❤️ Acknowledgements

* Inspired by **Apple Wallet** & **Google Wallet**, but built for Indian transport systems and community needs
* **Flutter** team for the amazing cross-platform framework
* **Open source community** for continuous support and contributions

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
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/prasanna6801"><img src="https://avatars.githubusercontent.com/u/59863680?v=4?s=100" width="100px;" alt="Soma Prasanna M"/><br /><sub><b>Soma Prasanna M</b></sub></a><br /><a href="https://github.com/Namma-Flutter/namma_wallet/commits?author=prasanna6801" title="Code">💻</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!

## Android Release Signing File Structure

android/
├── key.properties          ✅ (DO NOT COMMIT)
├── app/
│   ├── namma-wallet.keystore  ✅ (DO NOT COMMIT)
│   └── build.gradle.kts
