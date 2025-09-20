# 👜 Namma Wallet

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

```
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

Please check our [CONTRIBUTING.md](CONTRIBUTING.md) (coming soon) for detailed guidelines.

---

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
