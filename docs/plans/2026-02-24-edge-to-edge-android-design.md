# Edge-to-Edge Android Support — Design

**Date:** 2026-02-24
**Branch:** feature/support-for-edge-to-edge-in-android
**Status:** Approved

## Problem

Google Play Console (Release 9 / 0.0.3) flags two issues:

1. **Edge-to-edge not enforced** — apps targeting SDK 35+ must display edge-to-edge by default
2. **Deprecated APIs in use** — `Window.setStatusBarColor`, `Window.setNavigationBarColor`,
   `Window.setNavigationBarDividerColor` are deprecated in Android 15 and triggered by current theme attributes

Source of calls: `io.flutter.plugin.platform.f.r` (Flutter platform layer) and obfuscated app code (`a2.g.q`).

## Context

- `targetSdk = 36`, `compileSdk = 36` — above the SDK 35 edge-to-edge threshold
- Flutter 3.35.2 — natively handles edge-to-edge since 3.22; calls equivalent of `enableEdgeToEdge()` internally
- `main.dart` already calls `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)`
- App already uses `SafeArea` widgets — no content overlap risk after changes

## Approach: Theme Cleanup Only

Minimal change: remove the deprecated window bar attributes from Android theme XML files.
No Kotlin, no Flutter Dart changes required.

## Files Changed

### `android/app/src/main/res/values/styles.xml` — LaunchTheme (light)
Remove:
- `android:windowFullscreen` — conflicts with edge-to-edge
- `android:windowDrawsSystemBarBackgrounds` — deprecated

Change:
- `android:windowLayoutInDisplayCutoutMode`: `shortEdges` → `always`

### `android/app/src/main/res/values-night/styles.xml` — LaunchTheme (dark, API default)
Same removals/change as above.

### `android/app/src/main/res/values-night-v31/styles.xml` — LaunchTheme (dark, API 31+)
Same removals/change as above.

## Files Not Changed

| File | Reason |
|---|---|
| `values-v21/styles.xml` | Widget styles only, no window bar attributes |
| `values-v31/styles.xml` | Widget styles only, no window bar attributes |
| `values/themes.xml` | App widget themes only |
| `values-v31/themes.xml` | App widget themes only |
| `values-night-v31/themes.xml` | App widget themes only |
| `MainActivity.kt` | Stays as plain `FlutterActivity()` |
| `main.dart` | `setEnabledSystemUIMode(edgeToEdge)` stays, no changes needed |
| `AndroidManifest.xml` | No changes needed |
| `build.gradle.kts` | `targetSdk = 36` stays |

## Why This Fixes the Warnings

The deprecated `Window.setStatusBarColor()` / `setNavigationBarColor()` / `setNavigationBarDividerColor()`
are invoked when Flutter's platform layer detects `android:windowFullscreen=true` or
`android:windowDrawsSystemBarBackgrounds=true` in the active theme and adjusts bar
colors using the old API. Removing these attributes eliminates those code paths.

`windowLayoutInDisplayCutoutMode = always` ensures display cutouts (notches, punch-holes)
are rendered edge-to-edge rather than only on short edges.

## Success Criteria

- Google Play Console no longer reports the two edge-to-edge issues on next release
- App renders correctly on Android 15+ devices (status bar and navigation bar transparent, content behind bars with SafeArea insets)
- No visual regressions on Android 12–14 (API 31–34)
- No visual regressions on Android 8–11 (API 26–30)
