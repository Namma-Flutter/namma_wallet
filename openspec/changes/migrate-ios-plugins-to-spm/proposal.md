# Proposal

## Why

iOS plugins were split between CocoaPods (all plugins) and Flutter's newer Swift Package Manager (SPM) integration, which Flutter enables by default (`enable-swift-package-manager: true`). A full CocoaPods → SPM move is the goal, but several required plugins publish only a `.podspec` and no `Package.swift`. This change records the resulting mixed setup: SPM for the compatible plugins, CocoaPods retained for the rest.

## What Changes

- **Enable SPM integration in the iOS project**: `Runner.xcodeproj` now references the local `FlutterGeneratedPluginSwiftPackage` (wired into the Frameworks build phase and project), which resolves the 13 SPM-compatible plugins via local SPM packages.
- **Keep CocoaPods for CocoaPods-only plugins** (`google_mlkit_commons`, `google_mlkit_text_recognition` + their `GoogleMLKit` pods, `share_handler_ios`, `pdf_barcode_decoder`). `google_mlkit_commons`'s iOS plugin registration was dropped from the local vendored copy; ML Kit iOS remains via the Google `GoogleMLKit` CocoaPod.
- **Vendor/purge the failed MLKit-SPM fork** (option c): removed `packages/google_mlkit_*` (`pubspec.yaml` dependency_overrides for the two mlkit packages removed). Google ML Kit has no official SPM distribution, so ML Kit iOS stays on CocoaPods.
- **Fix the CocoaPods toolchain**: `ios/.ruby-version` corrected `3.3.7 → 3.3.10` (the only Installed rbenv ruby that matches), and `cocoapods 1.17.0` installed to match `Podfile.lock`; `pod install` now succeeds end-to-end.
- **Remove stale pods from `ios/Pods`**: delete `MediaPipeTasksGenAI`, `MediaPipeTasksGenAIC`, and `TensorFlowLite*` residue left by the already-removed `flutter_gemma`; `ios/Pods` is now 18 pods.
- **Generated files regenerated** via `flutter pub get` (resolved mlkit packages reverted to hosted pub.dev 0.13.0 / 0.17.1; generated SPM package has no external URL dependencies and no google_mlkit entries).

## Capabilities

- New Capabilities: none.
- Modified Capabilities: none.

This change does not alter user-facing behavior; it changes only how iOS plugin native code is packaged and linked. `skip_specs: true`.

## Impact

- **Build tooling iOS:** Swift Package Manager now provides the ~13 compatible plugins; `flutter_gemma`'s MediaPipe/TensorFlow pods are gone, cutting iOS pod graph and build dependencies. CocoaPods remains as build system for the four CocoaPods-only plugins.
- **`ios/Pods`:** now 18 pods (GoogleMLKit, MLKit, MLImage, SDWebImage, SwiftyGif, DK*, share extension deps, GoogleUtilities/GTMSessionFetcher, nanopb, PromisesObjC).
- **Toolchain:** `.ruby-version` fixed; a `pod install` is required after checkout (`make release-ipa` / `flutter build ios` handles it); `cocoapods 1.17.0` expected.
- **No outer behavior change:** identical Dart/plugin surface to before; `flutter analyze` shows no MLKit issues.
