# Workflow Optimization Plan

## Summary

Optimize `.github/workflows/release.yml` to cut total pipeline time from ~35min to ~15-20min using 8 new techniques.

## Changes

### 1. CocoaPods Cache (iOS job)

Add `actions/cache` for `ios/Pods/` and `~/Library/Caches/CocoaPods` keyed on `ios/Podfile.lock`.

```yaml
# In ios job, before flutter-action
- uses: actions/cache@v4
  with:
    path: |
      ios/Pods
      ~/Library/Caches/CocoaPods
    key: ${{ runner.os }}-pods-${{ hashFiles('ios/Podfile.lock') }}
    restore-keys: |
      ${{ runner.os }}-pods-
```

**Saves:** 3-8 min on iOS.

### 2. Larger macOS Runner (iOS job)

Change `runs-on: macos-latest` → `runs-on: macos-latest-xlarge` (6 cores vs 3).

**Saves:** 5-10 min on iOS.

### 3. Concurrency Groups (workflow-level)

Add concurrency block to cancel superseded PR runs:

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}
```

**Saves:** 2-5 min waste per superseded run.

### 4. Path Filtering (new `changes` job)

Add a `changes` job using `dorny/paths-filter@v4` to detect code changes. Gate/android/ios jobs depend on it and skip when only docs/CI config changed.

```yaml
changes:
  runs-on: ubuntu-latest
  permissions:
    pull-requests: read
  outputs:
    code: ${{ steps.filter.outputs.code }}
  steps:
    - uses: actions/checkout@v5
    - uses: dorny/paths-filter@v4
      id: filter
      with:
        filters: |
          code:
            - 'lib/**'
            - 'android/**'
            - 'ios/**'
            - 'pubspec.yaml'
            - 'pubspec.lock'
            - '.github/workflows/**'
```

Each build job gets: `needs: [changes, gate]` + `if: needs.changes.outputs.code == 'true'`.

Add `ci-ok` aggregation job for branch protection:

```yaml
ci-ok:
  if: always()
  needs: [changes, gate, android, ios]
  runs-on: ubuntu-latest
  steps:
    - if: contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled')
      run: exit 1
    - run: echo "All checks passed or were skipped"
```

**Saves:** 5-35 min for docs-only PRs.

### 5. Gradle Parallel + Daemon (gradle.properties)

Add to `android/gradle.properties`:

```properties
org.gradle.parallel=true
org.gradle.configureondemand=true
org.gradle.daemon=false
```

**Saves:** 1-3 min on Android.

### 6. Gradle Configuration Cache (gradle.properties)

Change `org.gradle.configuration-cache=warn` → `org.gradle.configuration-cache=true`.

**Saves:** 2-5 min on Android. May need to revert if plugins break.

### 7. Warm Cache on Main (new job)

Add a job that runs on pushes to `main` to pre-populate caches:

```yaml
warm-cache:
  if: github.ref == 'refs/heads/main'
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v5
    - uses: actions/cache@v4
      with:
        path: |
          ~/.pub-cache
          .dart_tool
          build
        key: gate-${{ runner.os }}-${{ hashFiles('pubspec.lock') }}
    - uses: subosito/flutter-action@v2
      with:
        channel: stable
        flutter-version-file: pubspec.yaml
        cache: true
    - run: flutter pub get
    - run: dart run build_runner build --delete-conflicting-outputs
```

**Saves:** 1-3 min per PR (warm cache restore).

### 8. Artifact Retention (android + ios jobs)

Add `retention-days: 7` to both `upload-artifact` steps. Artifacts are consumed by `github-release` job in the same workflow, so 7 days is sufficient.

**Saves:** Storage (85-97% reduction in artifact storage).

## Files to Modify

| File | Change |
|------|--------|
| `.github/workflows/release.yml` | Techniques 1-4, 7-8 |
| `android/gradle.properties` | Techniques 5-6 |

## Expected Result

| Metric | Before | After |
|--------|--------|-------|
| Total pipeline time | ~35 min | ~15-20 min |
| iOS build time | ~25 min | ~12-15 min |
| Android build time | ~15 min | ~10-12 min |
| Docs-only PR time | ~35 min | ~2 min (changes job only) |
| Artifact storage | 90 days | 7 days |
