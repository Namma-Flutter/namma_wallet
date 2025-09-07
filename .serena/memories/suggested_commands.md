# Development Commands

## Essential Commands (Always use `fvm flutter` instead of `flutter`)

### Setup and Dependencies
```bash
# Install dependencies
fvm flutter pub get

# Run the app (use -d to specify device)
fvm flutter run

# Run with specific device
fvm flutter run -d <device-id>
```

### Building
```bash
# Build for Android release
fvm flutter build apk

# Build for iOS release
fvm flutter build ios
```

### Code Quality and Analysis
```bash
# Analyze code for issues
fvm flutter analyze

# Run tests (when available)
fvm flutter test
```

### Development Tools
```bash
# Clean build artifacts
fvm flutter clean

# Update dependencies
fvm flutter pub upgrade

# Get dependencies after pubspec changes
fvm flutter pub get

# Check available devices
fvm flutter devices
```

### System Commands (macOS/Darwin)
- `ls`: List files and directories
- `cd`: Change directory
- `grep` or `rg`: Search text in files (rg is preferred - ripgrep)
- `find`: Find files and directories
- `git`: Version control operations

## Important Notes
- **Always use `fvm flutter`** instead of just `flutter` due to FVM setup
- Flutter version is pinned to 3.35.2 via .fvmrc file
- No custom build scripts or Makefile present
- Standard Flutter project structure