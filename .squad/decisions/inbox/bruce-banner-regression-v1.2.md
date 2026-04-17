# Regression Test Results — v1.2 (April 2026)

**Tester:** Bruce Banner  
**Date:** 2026-04-17  
**Release Verdict:** ⚠️ **BLOCKED** — Critical and blocking issues found

---

## Summary

Performed the mandatory 7-point regression checklist on v1.2. Found **2 BLOCKING issues** and **1 WARNING**.

---

## BLOCKING Issues

### 1. ❌ **CRITICAL: Blind Spy theme has NO word data**

- **File:** `ios/FamilyGame/FamilyGame/Resources/themes.json`
- **Problem:** The "Blind Spy" theme (displayed as "Blind Spy" in the UI, mapped to `Theme.random` in code) is **missing from themes.json entirely**. There are only 7 themes defined (Place, Country, Things, Jobs, Animal, Hollywood, Bollywood), but the UI shows 8 theme buttons including "Blind Spy."
- **Impact:** If a user selects "Blind Spy" theme, the game will crash or show no cards because there's no data to load.
- **Checklist Item:** Theme selection (Item 3) — FAILED
- **Required Fix:** Either add a "Blind Spy" theme entry to themes.json with word data, or remove the button from the UI. The code seems to expect "Blind Spy" to be a special mode that randomizes from other themes, so verify the game logic handles this correctly.

### 2. ❌ **CRITICAL: Excessive debug print() statements in production code**

- **Files:**
  - `GameScreenView.swift` lines 61, 108, 187, 195, 198, 202, 206, 208, 212, 216, 219, 233, 256
  - `CardView.swift` lines 29, 31, 35, 38
  - `AppState.swift` lines 44, 50, 56, 61, 69, 74
  - `SetupScreenView.swift` line 151
  - `EndGameScreenView.swift` line 90
  - `LaunchSoundManager.swift` line 64

- **Problem:** There are **25+ print() debug statements** scattered across production code. These statements log tap events, card state, navigation flow, player counts, etc. This is unacceptable for a release build.
- **Impact:** Performance degradation, log spam, potential information leakage in crash reports.
- **Checklist Item:** No debug artifacts (Item 7) — FAILED
- **Required Fix:** Remove ALL print() statements from production code, or wrap them in `#if DEBUG` guards so they only run in development builds.

---

## WARNING (Non-blocking)

### ⚠️ Player count min/max validation inconsistency

- **Files:** `SetupScreenView.swift` lines 21-25, 43, 54, 156
- **Observation:** The UI allows 1-12 players but enforces a minimum of 3 to start the game. The text field accepts 1-2 with a warning "Minimum 3 players required." This is confusing UX but not technically broken.
- **Recommendation:** Consider changing the placeholder from "Enter number (1–12)" to "Enter number (3–12)" to match the actual requirement. Or change the validation at line 56 to only accept 3-12 instead of 1-12.

---

## ✅ PASSING Checks

### 1. ✅ Launch screen — PASS

- **Verified:** `AppState.swift` line 26 sets `currentScreen: AppScreen = .welcome`
- **Result:** App will launch to Welcome screen, not setup or game screen. No debug overrides found.

### 2. ✅ Navigation flow — PASS

- **Verified:** Traced navigation in WelcomeScreenView.swift (line 133 → `appState.goToSetup()`), SetupScreenView.swift (line 153 → `appState.startGame()`), GameScreenView.swift (transitions to EndGameScreenView when cards complete), EndGameScreenView.swift (line 91 → `appState.resetGame()` back to welcome).
- **Result:** Complete flow works: Welcome → Setup → Game → EndGame → Welcome. No dead ends.

### 4. ✅ Card display — PASS (except Blind Spy)

- **Verified:** `themes.json` contains real, meaningful words for all 7 defined themes:
  - Place: 26 words (Airport, Hotel, Hospital, etc.)
  - Country: 32 words (France, Italy, Japan, etc.)
  - Things: 8 words (Bicycle, Book, Camera, etc.)
  - Jobs: 30 words (Doctor, Teacher, Pilot, etc.)
  - Animal: 30 words (Lion, Elephant, Penguin, etc.)
  - Hollywood: 27 real movie titles (Titanic, Avatar, Inception, etc.)
  - Bollywood: 27 real movie titles (Sholay, DDLJ, 3 Idiots, etc.)
- **Result:** All themes have real words, not placeholders. Hollywood and Bollywood have real movie titles. **However**, Blind Spy is missing (see BLOCKING issue #1).

### 5. ✅ Player count logic — PASS (with warning)

- **Verified:** `SetupScreenView.swift` lines 13-25 enforce:
  - Input range: 1-12 (with filtering)
  - Start game requirement: 3-12 (canStartGame check)
  - Validation messages shown for < 3 or > 12
- **Result:** No off-by-one errors. Logic is sound. UX could be clearer (see warning above).

### 6. ✅ Full screen — PASS

- **Verified:** `Info.plist` line 42-43 sets `UIRequiresFullScreen` to `true`.
- **Verified:** GameScreenView.swift lines 74-79 use `.ignoresSafeArea()` correctly for background only, content respects safe area.
- **Verified:** Dynamic Island overlap handling at lines 92, 155-160 with topInset calculation from actual safeAreaInsets.
- **Result:** App is full screen, no Dynamic Island overlap, safe area handled correctly.

---

## Build Status

✅ **Build:** CLEAN — xcodebuild succeeded with no errors or warnings.

---

## Verdict

**⚠️ RELEASE BLOCKED**

Two critical issues must be fixed before v1.2 can be submitted to the App Store:

1. **Blind Spy theme missing data** — will cause crash or broken gameplay
2. **25+ debug print() statements** — unacceptable for production release

Once these are resolved, re-run this checklist and verify all 7 items pass.

---

**Next Steps:**
1. Fix Blind Spy theme data issue (add to themes.json or update game logic)
2. Remove all print() statements or wrap in `#if DEBUG`
3. Re-run regression checklist
4. Re-verify build is clean
5. Re-submit for QA approval

---

*This regression was triggered by the formal warning in April 2026 after the `currentScreen = .setup` incident. No shortcuts, no exceptions.*
