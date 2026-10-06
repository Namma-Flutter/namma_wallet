# Proposal

## Why

The on-device AI (Gemma / MediaPipe) integration in this app is dead scaffolding: it is never wired into any parsing path, its model is never downloaded (`HUGGINGFACE_TOKEN` is set nowhere), and there is no inference code. Yet it ships every build — a `-force_load`d 37 MB static archive on iOS and a ~26 MB per-ABI `libllm_inference_engine_jni.so` on Android — and it forced a 20-line MediaPipe/TFLite workaround into the Podfile plus 8 ProGuard keep rules. Removing it shrinks binaries, simplifies native build config, and corrects a published privacy policy that currently claims (inaccurately) that tickets are parsed by an on-device LLM.

## What Changes

- **Remove** the `lib/src/features/ai/` feature and all of its services (`IAIService`, `GemmaService`, `WebGemmaService`), the `AIServiceStatus` notifier, and the `AIStatusWidget` (including its usage in the Settings view and its test).
- **Remove** the `IAIService` registration and `AIServiceStatus` notifier registration from the DI locator (`lib/src/common/di/locator.dart`).
- **Remove** `FlutterGemma.initialize()` and the AI-service init block from `lib/main.dart`.
- **Remove** `flutter_gemma` from `pubspec.yaml`; regenerate `pubspec.lock` and iOS Pod metadata via `flutter pub get`.
- **Remove** the MediaPipe/TensorFlow scrubbing `post_install` block from `ios/Podfile` (lines 88–107).
- **Remove** MediaPipe/Protobuf/AutoValue/flutter_gemma keep rules from `android/app/proguard-rules.pro`.
- **Update** `AGENTS.md` (project-structure tree, DI list, dependency table) to drop AI references.
- **Correct** `docs/privacy_policy_android.md`: replace the five on-device-LLM claims and reword §1.4 "Internet Access" to describe actual usage (offline extraction; network only for TNSTC PNR lookups, contributors list, remote `.pkpass` fetches).
- **Clean** `.vscode/settings.json` cSpell dictionary of the `HUGGINGFACE` and `mediapipe` entries.

## Capabilities

- New Capabilities: none.
- Modified Capabilities: none.

This change does not alter any user-observable behavior; ticket parsing remains fully deterministic (regex + layout geometry + ML Kit OCR), exactly as it is today. No spec-level delta is required, so no `specs/` files are created.

## Impact

- **Binary size:** removes the force-loaded `libMediaPipeTasksGenAIC_device.a` (37 MB archive) from iOS and both ABIs' `libllm_inference_engine_jni.so` (~55 MB total in the fat APK) from Android.
- **Build time:** drops MediaPipe/TFLite compile and link work and the Share-Extension xcconfig scrub.
- **Native config:** Podfile `post_install` shrinks; `proguard-rules.pro` drops from 33 to 25 lines.
- **Docs:** AGENTS.md and the privacy policy now describe the real (offline, deterministic) pipeline.
- **No functional change** to ticket parsing, OCR, PDF, or PKPass flows.
