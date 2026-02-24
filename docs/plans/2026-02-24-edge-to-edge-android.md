# Edge-to-Edge Android Support Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Remove deprecated Android window bar attributes from theme XML files to resolve Google Play Console edge-to-edge warnings on SDK 35+.

**Architecture:** Pure Android resource change — remove `android:windowFullscreen`, `android:windowDrawsSystemBarBackgrounds` from all `LaunchTheme` variants and change `android:windowLayoutInDisplayCutoutMode` from `shortEdges` to `always`. Flutter 3.35.2 handles edge-to-edge natively; SafeArea widgets already protect content.

**Tech Stack:** Android XML resources, `fvm flutter analyze` for static check, manual device test for visual verification.

---

### Task 1: Update light LaunchTheme (`values/styles.xml`)

**Files:**
- Modify: `android/app/src/main/res/values/styles.xml`

**Step 1: Read the current file**

Open `android/app/src/main/res/values/styles.xml` and confirm it contains:
```xml
<item name="android:windowFullscreen">true</item>
<item name="android:windowDrawsSystemBarBackgrounds">true</item>
<item name="android:windowLayoutInDisplayCutoutMode">shortEdges</item>
```

**Step 2: Apply the change**

Replace the entire `LaunchTheme` style block with:
```xml
<style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
    <!-- Show a splash screen on the activity. Automatically removed when
         the Flutter engine draws its first frame -->
    <item name="android:windowBackground">@drawable/launch_background</item>
    <item name="android:forceDarkAllowed">false</item>
    <item name="android:windowLayoutInDisplayCutoutMode">always</item>
</style>
```

Removed: `android:windowFullscreen`, `android:windowDrawsSystemBarBackgrounds`
Changed: `android:windowLayoutInDisplayCutoutMode` → `always`

**Step 3: Run Flutter analyze**

```bash
fvm flutter analyze
```
Expected: No new errors or warnings.

**Step 4: Commit**

```bash
git add android/app/src/main/res/values/styles.xml
git commit -m "fix(android): remove deprecated window bar attrs from light LaunchTheme"
```

---

### Task 2: Update dark LaunchTheme (`values-night/styles.xml`)

**Files:**
- Modify: `android/app/src/main/res/values-night/styles.xml`

**Step 1: Read the current file**

Open `android/app/src/main/res/values-night/styles.xml` and confirm it contains the same three deprecated attributes in `LaunchTheme`.

**Step 2: Apply the change**

Replace the entire `LaunchTheme` style block with:
```xml
<style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
    <!-- Show a splash screen on the activity. Automatically removed when
         the Flutter engine draws its first frame -->
    <item name="android:windowBackground">@drawable/launch_background</item>
    <item name="android:forceDarkAllowed">false</item>
    <item name="android:windowLayoutInDisplayCutoutMode">always</item>
</style>
```

**Step 3: Commit**

```bash
git add android/app/src/main/res/values-night/styles.xml
git commit -m "fix(android): remove deprecated window bar attrs from dark LaunchTheme"
```

---

### Task 3: Update API 31+ dark LaunchTheme (`values-night-v31/styles.xml`)

**Files:**
- Modify: `android/app/src/main/res/values-night-v31/styles.xml`

**Step 1: Read the current file**

Open `android/app/src/main/res/values-night-v31/styles.xml` and confirm the `LaunchTheme` has:
```xml
<item name="android:windowFullscreen">true</item>
<item name="android:windowDrawsSystemBarBackgrounds">true</item>
<item name="android:windowLayoutInDisplayCutoutMode">shortEdges</item>
```
Note: this file also has `windowSplashScreenBackground` and `windowSplashScreenAnimatedIcon` — keep those.

**Step 2: Apply the change**

Replace the entire `LaunchTheme` style block with:
```xml
<style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
    <item name="android:forceDarkAllowed">false</item>
    <item name="android:windowLayoutInDisplayCutoutMode">always</item>
    <item name="android:windowSplashScreenBackground">#000000</item>
    <item name="android:windowSplashScreenAnimatedIcon">@drawable/android12splash</item>
</style>
```

Removed: `android:windowFullscreen`, `android:windowDrawsSystemBarBackgrounds`
Changed: `android:windowLayoutInDisplayCutoutMode` → `always`
Kept: `windowSplashScreenBackground`, `windowSplashScreenAnimatedIcon`

**Step 3: Run Flutter analyze**

```bash
fvm flutter analyze
```
Expected: No new errors or warnings.

**Step 4: Commit**

```bash
git add android/app/src/main/res/values-night-v31/styles.xml
git commit -m "fix(android): remove deprecated window bar attrs from API 31+ dark LaunchTheme"
```

---

### Task 4: Verify on device (manual)

**Ask the user to run the app** — do NOT run it yourself per project rules.

Tell the user:
> "Please run `fvm flutter run` on an Android device or emulator and check:
> 1. Splash screen appears correctly (no black bar flashes)
> 2. Main app UI is not hidden behind the status or navigation bar
> 3. Bottom navigation bar is fully visible with correct SafeArea insets
> 4. Test on both light and dark mode"

**Step 1: Confirm with user**

Wait for the user to confirm there are no visual regressions before proceeding.

---

### Task 5: Final commit and branch cleanup

**Step 1: Verify git status is clean**

```bash
git status
```
Expected: clean working tree.

**Step 2: Summarise changes for PR description**

The three style file changes remove:
- `android:windowFullscreen` — was triggering `Window.setStatusBarColor()` calls in Flutter's platform layer
- `android:windowDrawsSystemBarBackgrounds` — was triggering `Window.setNavigationBarColor()` / `setNavigationBarDividerColor()` calls

And update:
- `android:windowLayoutInDisplayCutoutMode`: `shortEdges` → `always` for proper notch/cutout handling in edge-to-edge mode

These resolve the two Play Console warnings:
1. "Edge-to-edge may not display for all users"
2. "Your app uses deprecated APIs or parameters for edge-to-edge"
