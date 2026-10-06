# Design

## Context

See proposal.md — Why. Current state before this change: all iOS plugins resolved through CocoaPods (`ios/Pods`, `Podfile`, `Podfile.lock`, `Runner.xcworkspace`), with `enable-swift-package-manager: true` set but not yet wired into the Runner project (`Runner.xcodeproj` had no package references; `FlutterGeneratedPluginSwiftPackage` was generated under `ios/Flutter/ephemeral` but unused).

## Goals / Non-Goals

**Goals:**
- Wire Flutter's SPM integration into the Runner project so SPM-compatible plugins resolve via SPM (faster, modern dependency graph).
- Establish a working SPM boundary: exactly the 13 plugins with `Package.swift` go SPM; the 4 pod-only plugins stay CocoaPods.
- Fix the CocoaPods toolchain failure (`.ruby-version` mismatch + old CocoaPods vs lockfile).
- Purge stale MediaPipe/TensorFlow pod residue from `ios/Pods`.

**Non-Goals:**
- Removing CocoaPods entirely (blocked: four plugins lack `Package.swift`).
- Google ML Kit being distributed via SPM (it is not, officially — investigated and abandoned).
- Switching OCR engine (Apple Vision) or re-tuning the layout parsers.
- `--split-per-abi` / APK size work (separate follow-up).

## Decisions

1. **Stay on CocoaPods for ML Kit/pdf/share plugins.**
   Alternatives considered: (a) community MLKit SPM mirrors; (b) vendoring a hand-written SPM wrapper around MLKit binaries. Rejected: MLKit has no official SPM artifact, and a third-party mirror/fork adds maintenance risk on the app's core OCR path with no verified accuracy wins. Chosen: keep GoogleMLKit via CocoaPods for iOS; preserve SPM packaging for the infrastructure plugins that already support it.

2. **Option C specifically (no `packages/` vendoring).**
   A local fork of `google_mlkit_text_recognition`/`google_mlkit_commons` with a `Package.swift` pointing at the non-existent `googlec2dm/mlkit-ios-sdk` could never resolve. The fork was removed and `pubspec.yaml` dependency_overrides reverted to only `background_downloader`; `google_mlkit_*` resolve to hosted pub.dev again.

3. **Fix the CocoaPods toolchain instead of replacing it.**
   `.ruby-version` was 3.3.7 while the environment ships rbenv 3.3.10/3.4.7/4.0.3; corrected to 3.3.10. `Podfile.lock` was generated with CocoaPods 1.17.0 while installed was 1.16.2; installed `cocoapods 1.17.0`. `pod install` now succeeds (17.7s). The CocoaPods "custom base configuration" warning is expected with Flutter projects and benign.

4. **Purge stale pods.**
   `ios/Pods/MediaPipeTasksGenAI`, `MediaPipeTasksGenAIC`, `TensorFlowLite*` remained from the removed `flutter_gemma` even though `Podfile.lock` no longer referenced them. Deleted from disk and reconciled with a fresh `pod install`; `ios/Pods` now contains only the 18 pods required by the current `Podfile.lock`.

## Risks / Trade-offs

- **Mixed SPM + CocoaPods linking** on the same Runner target requires both `Runner.xcodeproj` package wiring (SPM) and the existing `Pods-Runner` xcconfig includes (CocoaPods).→ Mitigated by running `flutter build ios --config-only` to generate both the SPM references and the CocoaPods xcconfig includes; a device/simulator build is still required to confirm the link order.
- **ML Kit stays on CocoaPods** means ML Kit frameworks are still pulled into the iOS build (no SPM size win for ML Kit itself).→ Accepted: there is no official ML Kit SPM artifact, so isolation is the pragmatic ceiling without replacing engines.
- **`.ruby-version` / CocoaPods version pin** must be honored on every machine used to build.→ Documented in proposal; any contributor with rbenv will need 3.3.10 + `gem install cocoapods -v 1.17.0`.
