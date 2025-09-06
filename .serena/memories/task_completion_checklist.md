# Task Completion Checklist

## Before Completing Any Task

### Code Quality Checks
1. **Run Analysis**: `fvm flutter analyze`
   - Must pass without errors or warnings
   - Address any linting issues

2. **Test Execution**: `fvm flutter test` (when tests are available)
   - All existing tests must pass
   - Add tests for new functionality when appropriate

3. **Build Verification**: `fvm flutter build apk` or `fvm flutter build ios`
   - Ensure the app builds successfully for target platforms
   - No build errors or critical warnings

### Code Standards
4. **Follow Project Conventions**
   - Use feature-based architecture
   - Maintain presentation/application layer separation
   - Follow established naming conventions

5. **Dependencies**
   - Use `fvm flutter pub get` after adding new dependencies
   - Verify compatibility with existing dependencies

### Version Control
6. **Git Operations**
   - Commit changes with descriptive messages
   - Only commit when explicitly requested by user
   - Ensure no sensitive data is committed

## Important Notes
- **Always use `fvm flutter`** commands instead of plain `flutter`
- Verify FVM is using Flutter 3.35.2 as configured in .fvmrc
- No custom test runner or CI/CD scripts present
- Standard Flutter development workflow applies