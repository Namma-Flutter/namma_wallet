---
name: release-updater
description: Automates bumping the app version, updating the technical CHANGELOG.md, and updating the App Store & Play Store release notes in a user-friendly way. Make sure to use this skill whenever the user mentions releasing a new version, bumping the app version, updating changelogs, or preparing metadata files for App Store/Play Store.
---

# Release Updater

This skill guides the agent through bumping the version and updating all release metadata files in the project.

## Workflow

### 1. Identify the Current Version and Commits
- Locate the current version in [pubspec.yaml](file:///Users/harishanbalagan/Developer/flutter/rewardive-mobile/pubspec.yaml).
- Identify the last released version. This is usually the latest version header documented in [CHANGELOG.md](file:///Users/harishanbalagan/Developer/flutter/rewardive-mobile/CHANGELOG.md) (e.g., `[0.3.3+9]`).
- Run `git log <last-version-commit>..HEAD` (or scan from the commit that last bumped the version, e.g. finding the commit where version was changed, or using git log tags) to get all commits that have occurred since the last release.

### 2. Bump the App Version
- Update `pubspec.yaml` to bump the version.
- Determine the new version number (e.g., increment the patch/minor version and the build number, like `0.3.4+10` -> `0.3.5+11`).

### 3. Update the Technical Changelog
- Open [CHANGELOG.md](file:///Users/harishanbalagan/Developer/flutter/rewardive-mobile/CHANGELOG.md).
- Insert a new section for the bumped version right under `## [Unreleased]`.
- Format the version header as `## [version] - YYYY-MM-DD` (e.g. `## [0.3.5+11] - 2026-06-22`).
- Group the scanned commits into standard changelog sections:
  - `### Added` for new features.
  - `### Fixed` for bug fixes.
  - `### Changed` for refactors/changes to existing features.
  - `### Removed` for deprecated/removed features.
  - `### Chores` for dependency bumps, configuration updates, and workspace housekeeping.
- Keep the descriptions technical, concise, and accurate to the commits.

### 4. Update App Store and Play Store Release Notes
- Locate the platform release notes:
  - Play Store: [default.txt](file:///Users/harishanbalagan/Developer/flutter/rewardive-mobile/android/fastlane/metadata/android/en-US/changelogs/default.txt)
  - App Store: [release_notes.txt](file:///Users/harishanbalagan/Developer/flutter/rewardive-mobile/ios/fastlane/metadata/en-US/release_notes.txt)
- **IMPORTANT**: Release notes must be user-friendly and non-technical. Avoid technical jargon, implementation details, internal field names, or developer-specific terms.
- Summarize the new version changes in a non-technical, user-friendly way that focuses on user-visible improvements and benefits.
- Maintain a strict limit of under 500 characters to fit Play Store limitations.
- Keep the styling consistent with standard "What's New" bullet points.

### 5. Validate the Workspace
- Run the project's data policy script to check for violations:
  ```bash
  bash scripts/check_no_default_values.sh
  ```
- Run Flutter static analysis to ensure no compiling issues exist:
  ```bash
  rtk fvm flutter analyze
  ```
