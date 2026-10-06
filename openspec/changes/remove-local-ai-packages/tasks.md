# Tasks

## 1. Delete orphaned AI code

- [x] 1.1 Delete the AI feature directory `lib/src/features/ai/` (gemma_service.dart, web_gemma_service.dart, ai_service_interface.dart) and the AI settings files `lib/src/features/settings/application/ai_service_status.dart` and `lib/src/features/settings/presentation/ai_status_widget.dart`, and the test `test/src/features/settings/application/ai_service_status_test.dart`; verify with `git status` that those files are gone.

## 2. Remove AI wiring from Dart source

- [x] 2.1 Remove `FlutterGemma.initialize()` and the AI init block from `lib/main.dart` (drop the flutter_gemma import and the IAIService import); verify `flutter analyze` reports no errors in main.dart.
- [x] 2.2 Remove `AIServiceStatus` and `IAIService` registrations plus their imports from `lib/src/common/di/locator.dart`; verify `flutter analyze` is clean for locator.dart.
- [x] 2.3 Remove the `AIStatusWidget` import and usage from `lib/src/features/settings/presentation/settings_view.dart`; verify `flutter analyze` is clean for settings_view.dart.

## 3. Remove native package and build config

- [x] 3.1 Remove `flutter_gemma: ^1.1.0` from `pubspec.yaml`; verify the line is gone.
- [x] 3.2 Delete the MediaPipe/TensorFlow `post_install` scrub block (lines 88-107) from `ios/Podfile`; verify `grep -i mediapipe ios/Podfile` finds nothing.
- [x] 3.3 Remove the MediaPipe/Protobuf/AutoValue and flutter_gemma keep rules from `android/app/proguard-rules.pro`; verify `grep -i mediapipe android/app/proguard-rules.pro` finds nothing.
- [x] 3.4 Remove `HUGGINGFACE` and `mediapipe` from the cSpell dictionary in `.vscode/settings.json`; verify `grep -E 'HUGGINGFACE|mediapipe' .vscode/settings.json` finds nothing.

## 4. Update documentation

- [x] 4.1 Update `AGENTS.md`: remove the `ai/` tree entry, the `IAIService` DI row, and the `flutter_gemma` dependency-table row; verify `grep -i gemma AGENTS.md` finds nothing.
- [x] 4.2 Correct `docs/privacy_policy_android.md`: remove the five on-device-LLM claims (L5, L15, L31, L32, L40) and rewrite §1.4 to state offline parsing plus network used only for TNSTC PNR, contributors, and remote .pkpass; verify `grep -i 'llm\|ai model' docs/privacy_policy_android.md` finds nothing.

## 5. Regenerate and verify

- [x] 5.1 Run `fvm flutter pub get`; verify `pubspec.lock` no longer lists `flutter_gemma`, and `ios/Pods` drops `MediaPipeTasksGenAIC`/`TensorFlowLite*` (by inspecting the updated `ios/Podfile.lock`).
- [x] 5.2 Run `fvm flutter analyze`; verify zero errors.
- [x] 5.3 Run `fvm flutter test`; verify tests pass.
