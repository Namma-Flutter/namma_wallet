# Setup Guide

This guide will help you set up the development environment for Namma Wallet.

## Prerequisites

### Required Software
- Flutter SDK 3.35.2
- VSCode and Android Studio(for Android development)
- Xcode 16.4.0 (for iOS development on macOS)
- Git

### Install Bun (JavaScript Runtime)
```bash
curl -fsSL https://bun.sh/install | bash
```

### Install UVX to install MCP servers
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Install Flutter Version Management (FVM)
```bash
# Install FVM globally
dart pub global activate fvm

# Or install via Homebrew (macOS)
brew tap leoafarias/fvm
brew install fvm
```

## Project Setup

### 1. Clone the Repository
```bash
git clone https://github.com/<your-username>/namma_wallet.git
cd namma_wallet
```

### 2. Install Flutter Version
```bash
# Install and use Flutter 3.35.2 via FVM
fvm install 3.35.2
fvm use 3.35.2
```

### 3. Install Dependencies
```bash
# Get Flutter dependencies
fvm flutter pub get
```

### 4. Verify Setup
```bash
# Check Flutter setup
fvm flutter doctor

# Verify available devices
fvm flutter devices

# Run code analysis
fvm flutter analyze
```

## Running the App

### Development
```bash
# Run on connected device
fvm flutter run

# Run on specific device
fvm flutter run -d <device-id>

# Run with hot reload enabled (default)
fvm flutter run --hot
```

### Building
```bash
# Build Android APK
fvm flutter build apk

# Build iOS (requires macOS and Xcode)
fvm flutter build ios
```

## Development Commands

### Code Quality
```bash
# Analyze code
fvm flutter analyze

# Run tests
fvm flutter test

# Clean build artifacts
fvm flutter clean
```

### Dependency Management
```bash
# Update dependencies
fvm flutter pub upgrade

# Add new dependency
fvm flutter pub add <package_name>

# Remove dependency
fvm flutter pub remove <package_name>
```

## Troubleshooting

### Common Issues
1. **Flutter version mismatch**: Ensure you're using `fvm flutter` commands
2. **Missing dependencies**: Run `fvm flutter pub get`
3. **Build issues**: Try `fvm flutter clean` then `fvm flutter pub get`
4. **Device not detected**: Check `fvm flutter devices` and ensure device is connected

### Platform-Specific Setup
- **Android**: Ensure Android Studio and SDK are properly configured
- **iOS**: Requires Xcode 16.4.0 and macOS for development
- **Simulators**: Use iOS Simulator or Android Emulator for testing

## Serena MCP Installation

For AI-assisted development with Claude Code:

### Install Serena MCP Server
```bash
# install via uvx
uvx --from git+https://github.com/oraios/serena serena start-mcp-server
```

### Configure MCP in Claude Code
Add to your `.mcp.json` configuration file:
```json
"serena": {
    "type": "stdio",
    "command": "uvx",
    "args": [
        "--from",
        "git+https://github.com/oraios/serena",
        "serena",
        "start-mcp-server",
        "--context",
        "ide-assistant",
        "--project",
        "/Users/harish/Developer/flutter/namma_wallet"
    ],
    "env": {}
}
```

## Development Environment
- This project uses Flutter 3.35.2 managed via FVM
- Follow feature-based architecture when adding new functionality
- Adhere to flutter_lints coding standards
- Serena MCP provides intelligent code analysis and editing capabilities