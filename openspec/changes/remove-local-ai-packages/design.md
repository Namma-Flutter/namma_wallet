# Design

## Context

See proposal.md — Why. Current state: `IAIService`/`GemmaService`/`WebGemmaService` are registered lazily and initialized once in `main.dart`, but the interface is never referenced by any parser or import path. The model is gated behind an environment token that is never set, so nothing is ever downloaded or run. All ticket parsing is deterministic (regex + layout geometry + ML Kit OCR).

## Goals / Non-Goals

**Goals:**
- Excise every AI package and its native support code.
- Leave the app building and analyzing clean with no dangling `IAIService`, `flutter_gemma`, or `AIServiceStatus` references.
- Correct user-facing docs (AGENTS.md, privacy policy) to describe the real offline, deterministic pipeline.
- Produce a measurable binary-size reduction.

**Non-Goals:**
- Adding `--split-per-abi` or any other APK/ABI optimization (separate follow-up).
- Reworking any parser, OCR, PDF, or PKPass logic.
- Archiving the lost `llm-ticket-parsing` branch work (the merge already dropped it; it is abandoned).
- Changing CHANGELOG.md (historical release notes stay immutable).

## Decisions

1. **Delete the seam, don't leave an extension point.**
   Alternatives considered: (a) keep `IAIService` as an empty interface for a future LLM attempt; (b) delete it. Chosen (b) — the codebase already has `import`/`travel`/`clipboard` paths that choose parsers via `TravelParserService` strategy; adding an LLM later means re-adding intent-specific code, so retaining an unused abstraction buys nothing.

2. **`skip_specs: true`.**
   No spec-level behavior changes (deterministic parsing is unchanged); adding capability specs would invent requirements. Chose skip.

3. **Do not hand-edit generated/registered files.**
   `pubspec.lock`, `ios/Podfile.lock`, and `GeneratedPluginRegistrant.*` are regenerated via `flutter pub get` after YAML/config edits. Hand-editing risks drift.

4. **Rewrite §1.4 and remove LLM claims together.**
   The privacy policy currently asserts LLM parsing in five places and mis-describes network use. Replacing them in one pass keeps the document internally consistent; splitting it would leave a self-contradictory published policy.

5. **Delete the Podfile MediaPipe scrub lines wholesale.**
   Lines 88–107 exist only to strip `MediaPipeTasksGenAIC`/TensorFlow/flutter_gemma from the Share Extension xcconfig. With the packages gone, those edits are no-ops; keeping them is misleading.

## Risks / Trade-offs

- **Removing ProGuard keeps might surface R8 errors for another package.**→ Mitigate with `fvm flutter build apk --release` + `--split-per-abi` spot-check and full `flutter analyze`. The kept MediaPipe/Protobuf classes belong only to flutter_gemma, so this is low risk.
- **Deleting Podfile scrub could break the Share Extension if a transitive MediaPipe dep remains.** → Verified: MediaPipe arrives only via `flutter_gemma`; after `pub get` the Pods list drops `MediaPipeTasksGenAI*`/`TensorFlowLite*` entirely.
- **Real binary-size reduction may differ from the 37 MB archive figure** due to dead-stripping. → Mitigate by measuring before/after APK + IPA rather than trusting archive sizes.
- **Privacy policy wording must be legally accurate.** → The rewrite leans on verified facts only (offline parsing; network limited to TNSTC PNR, contributors, remote `.pkpass`). Confirm with maintainers before publishing.
