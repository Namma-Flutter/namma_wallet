# Tasks

## 1. SPM wiring in iOS project

- [x] 1.1 Add the FlutterGeneratedPluginSwiftPackage local package reference to Runner.xcodeproj (via `fvm flutter build ios --config-only`), and verify `grep -c "FlutterGeneratedPluginSwiftPackage" ios/Runner.xcodeproj/project.pbxproj` is > 0.

## 2. CocoaPods toolchain fixes

- [x] 2.1 Correct `ios/.ruby-version` from 3.3.7 to 3.3.10 and verify `pod --version` works in the ios directory.
- [x] 2.2 Install `cocoapods 1.17.0` to match the lockfile and verify `pod install` completes without the "specs repository too out-of-date" error.

## 3. Purge stale pods and reconcile

- [x] 3.1 Remove `ios/Pods/MediaPipeTasksGenAI`, `MediaPipeTasksGenAIC`, `TensorFlowLite*` leftovers and verify `ios/Pods` contains only the 18 locked pods.
- [x] 3.2 Run `pod install` and verify it reports success and the project keeps ML Kit via `GoogleMLKit` pods.

## 4. Revert the failed MLKit-SPM fork

- [x] 4.1 Remove the `packages/` vendored google_mlkit_* copies and revert `pubspec.yaml` dependency_overrides; verify `git status` no longer lists `packages/` and `pubspec.lock` resolves `google_mlkit_commons`/`google_mlkit_text_recognition` as hosted.
- [x] 4.2 Confirm the generated `FlutterGeneratedPluginSwiftPackage/Package.swift` has no external URL dependencies and no `google_mlkit` entries.

## 5. Verification

- [x] 5.1 `flutter analyze` reports no google_mlkit errors.
- [x] 5.2 `git status` is clean after committing; working tree matches `HEAD` (`.ruby-version`, `Podfile.lock`, Runner.xcodeproj, Runner.xcscheme, pubspec.lock).
