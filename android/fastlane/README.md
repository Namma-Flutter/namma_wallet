# Android Fastlane Setup

Automates building and deploying the Android app to the Google Play Store.

## Prerequisites

- [Fastlane](https://docs.fastlane.tools/#installing-fastlane) installed
- A Google Play **Service Account JSON** key file ([how to create one](https://docs.fastlane.tools/actions/supply/#setup))
- App signing configured with `key.properties` and your keystore

## Setup

1. Place `key.properties` in the `android/` directory.
2. Place the keystore file (`.jks`) in the `android/app/` directory.
3. Place the Google Play Service Account JSON key in `android/fastlane/`.
4. Create `android/fastlane/.env.local` from the example:

   ```sh
   cp .env.local.example .env.local
   ```

5. Fill in the values in `.env.local`:

   ```dotenv
   PACKAGE_NAME=com.example.app
   PLAY_STORE_JSON_PATH=fastlane-android.json
   ```

## Directory Structure

```
android/fastlane/
├── .env.local              # Environment variables (git-ignored)
├── .env.local.example      # Template for .env.local
├── Appfile                  # Play Store package name & JSON key config
├── Fastfile                 # Lane definitions (beta, production)
├── fastlane-android.json    # Google Play service account key (git-ignored)
├── metadata/
│   └── android/en-US/
│       ├── title.txt              # App title
│       ├── short_description.txt  # Short description
│       ├── full_description.txt   # Full description
│       └── changelogs/            # Per-version changelogs
└── setup.md                 # Detailed setup guide
```

## Available Lanes

### `beta` — Build & Upload to Internal Testing

Builds a release AAB and uploads it to the Play Store **Internal Testing** track.

```sh
bundle exec fastlane android beta
```

**What it does:**

1. Reads version & build number from `pubspec.yaml`
2. Validates the build number doesn't already exist on the Internal track
3. Builds the release AAB via `make release-appbundle`
4. Prepares the changelog from `metadata/en-US/release_notes.txt`
5. Uploads the AAB + metadata to the Internal Testing track

---

### `production` — Promote to Production

Promotes an existing Internal Testing build to **Production**.

```sh
bundle exec fastlane android production
```

Or with explicit version parameters:

```sh
bundle exec fastlane android production version:"1.2.0" build:42
```

**What it does:**

1. Reads version from `pubspec.yaml` (or uses provided parameters)
2. Verifies the build exists on the Internal track
3. Promotes it to the Production track

## Updating Release Notes

Before running the `beta` lane, update the release notes file:

```
metadata/en-US/release_notes.txt
```

If this file is missing, a default message (`Beta build vX.Y.Z (build_number)`) is used.

## Versioning

Version and build number are read from **`pubspec.yaml`** in the format:

```yaml
version: 1.2.0+42   # version_name + build_number
```

> **Important:** Always increment the build number (`+N`) before running the `beta` lane. Duplicate build numbers will be rejected.
