# SPY WORD — Family Spy Game

A family-friendly iOS card game where players take turns revealing cards on a shared device to discover the hidden spy among them.

---

## 🎯 Project Overview

SPY WORD is a multiplayer party game where:
- **One player secretly receives the SPY card**
- **All other players see the same theme word**
- Players pass a single iPhone/iPad around, each viewing their card privately
- Through discussion and deduction, players try to identify the spy

Perfect for families with kids, parties, and social gatherings. Supports **3-12 players**, **5 themed categories** (Place, Country, Things, Jobs, Animal), plus a **"Blind Spy" mode** where even the theme is random.

---

## 🛠️ Tech Stack

- **Platform:** iOS 17.0+
- **Language:** Swift
- **Framework:** SwiftUI
- **Architecture:** MVVM with @Observable state management
- **Build System:** Xcode 16+, Swift Package Manager
- **Testing:** XCTest (214+ unit tests)
- **Deployment:** iPhone only (portrait mode)

---

## 👥 Team

This project was built by an AI-powered development squad using GitHub Copilot:

- **Natasha Romanoff** — Frontend Developer (SwiftUI, UI/UX)
- **Bruce Banner** — QA Engineer (Testing, validation, regression)
- **Scribe** — Memory & Documentation (Decision tracking, learning capture)
- **Product Owner:** @amolbabu

Supporting agents: Tony Stark (Backend), Steve Rogers (Architecture), Vision (Design), Keaton (Lead)

---

## 🏆 Retrospective Ceremony Summary

### ✅ What Went Well

#### Features Delivered
- **Full game flow:** Welcome screen → Setup → Card reveal → End game
- **5 theme categories:** Place, Country, Things, Jobs, Animal
- **Blind Spy mode:** Random theme selection for advanced gameplay
- **Minimum 3 players:** Proper validation with inline error messages
- **How to Play instructions:** In-app onboarding with emoji-rich content
- **Privacy policy integration:** Link and sheet on welcome screen
- **Full-screen support:** iPhone 15+ Dynamic Island compatibility via UIRequiresFullScreen
- **Warm, inviting UI:** Radial gradients, floating emoji animations, welcome sound (later removed)
- **Accessibility:** VoiceOver labels, Dynamic Type support, WCAG AA contrast compliance

#### Good Technical Decisions
- **System fonts with `.rounded` design:** Native emoji support, no bundle bloat, matches intended aesthetic
- **Modular architecture:** Clean separation (Models/Logic/Views), 214+ unit tests
- **Safe area awareness:** `.padding(.bottom)` without values for automatic device adaptation
- **Comprehensive QA cycles:** Bruce caught critical issues before they shipped (emoji rendering, full-screen bugs, turn enforcement)
- **Decision documentation:** `.squad/decisions.md` ledger captured rationale for all major changes

#### Team Collaboration Wins
- **Parallel work streams:** Natasha (UI), Bruce (QA), Scribe (docs) worked simultaneously without blocking
- **Quick bug turnaround:** Emoji font fix, full-screen issues, theme button tap failures all resolved within same sprint
- **Proactive QA:** Bruce identified issues (black margin flash, turn validation bugs) before user reports
- **Learning capture:** Natasha's history.md documented SwiftUI `.buttonStyle(.plain)` pattern, stats layout learnings for future reference

---

### ❌ What Went Wrong

#### 1. Stats Sizing Ping-Pong (High Frustration)
**Problem:** TurnIndicatorView stats (Remaining/Locked counts) went through **4+ iterations**:
1. Initial size: Too large (13pt icons/numbers, 3-row vertical stack)
2. Shrink attempt 1: Too small (9pt/6pt) — unreadable
3. Restore attempt: Back to 13pt — too large again
4. Final compact: Single-line horizontal layout (12pt numbers, 11pt labels) ✅

**Root Cause:**
- Unclear product requirements: "Make it smaller" vs. "Compact but readable"
- No visual mockups or target size reference
- Natasha implemented changes without Bruce visually testing first
- Lack of upfront design spec led to trial-and-error iteration

**Impact:** Wasted 3+ hours, multiple commits/reverts, team frustration

---

#### 2. Emoji Rendering Bug (Late Discovery)
**Problem:** All emojis rendered as "?" boxes on device despite working in Xcode preview.

**Root Cause:**
- Code referenced custom fonts (`Baloo2-Bold`, `Baloo2-Medium`) but font files were never added to bundle
- SwiftUI fallback mechanism broke emoji rendering when custom fonts failed to load
- Bug only visible on physical device/simulator, not in Xcode canvas previews

**Why Caught Late:**
- Bruce's early QA focused on logic/state, not visual UI rendering
- No device testing in first 2 QA passes (relied on static code review)
- Emoji usage pervasive across 6+ screens (welcome, setup, game, how-to-play)

**Impact:** Release blocker discovered late in sprint, required emergency fix

---

#### 3. Full-Screen Fix Took Multiple Attempts
**Problem:** iPhone 15+ displayed black bars (letterboxing) despite initial fix attempts.

**Timeline:**
1. Attempt 1: Added `UILaunchScreen` to Info.plist → Still letterboxed
2. Attempt 2: Added `UIRequiresFullScreen: true` → Still letterboxed
3. Root cause found: Xcode was **auto-generating** Info.plist, ignoring manual edits
4. Final fix: Set `GENERATE_INFOPLIST_FILE = NO` in project.pbxproj ✅

**Why It Took 3 Tries:**
- iOS 17/18 full-screen configuration is a multi-layered system (launch screen + multitasking settings + window configuration)
- Xcode build settings silently overrode Info.plist changes
- Bruce and Natasha didn't verify build artifacts, assumed edits were applied

**Impact:** High-priority bug burned 2 days, created back-and-forth frustration

---

#### 4. Background Audio Removed (Wasted Effort)
**Problem:** Welcome screen had a 4-note welcome chime synthesized via AVAudioEngine. Removed without team discussion.

**Context:** Product owner (@amolbabu) requested removal, but team wasn't consulted before implementation.

**Impact:** Wasted implementation effort (LaunchSoundManager.swift design, testing, integration). No retrospective on "should we have audio?" before building.

---

#### 5. Branch Policy Confusion
**Problem:** Commits were pushed to `release/1.0.0` branch instead of `main` during mid-sprint work.

**Timeline:**
- Commits `c9671cf3` (theme button reorganization), `a1f27767` (background sound removal), `95690602` (Animal theme) all landed on release/1.0.0
- Main branch and release branch diverged
- Git history shows stash entries: `b6469d6f WIP on release/1.0.0`, `3a5c6bf2 index on release/1.0.0`

**Root Cause:**
- No defined branching strategy (GitFlow vs trunk-based)
- Agents didn't enforce "feature work on main, release freeze on release/*"
- Product owner didn't specify branch policy upfront

**Impact:** Git history confusion, potential merge conflicts, unclear "source of truth"

---

#### 6. Bruce Not Testing UI Visually (Raised by User)
**Problem:** User (@amolbabu) expressed frustration that Bruce wasn't catching visual issues like stats sizing.

**Context:**
- Bruce's early QA focused on functional testing: state transitions, validation logic, build errors
- Visual UI assessment (font sizes, spacing, layout balance) deferred to later QA cycles
- User expected Bruce to catch sizing issues **before** Natasha iterated multiple times

**Why It Happened:**
- Bruce's testing checklist prioritized logic > visuals (QA Engineer mindset)
- No explicit requirement: "Bruce must render screenshots for every UI change"
- Natasha made rapid changes without requesting visual QA checkpoint

**Impact:** Stats ping-pong could have been avoided if Bruce tested visuals after iteration 1

---

### 🎯 Action Items

#### Immediate (Next Sprint)

1. **Define Visual QA Checkpoint**
   - **Owner:** Bruce Banner
   - **Action:** For all UI changes, capture screenshot + font size table BEFORE approving
   - **Success Criteria:** No more than 1 revision per UI component

2. **Establish Branching Policy**
   - **Owner:** @amolbabu (Product Owner)
   - **Action:** Document in `CONTRIBUTING.md`: feature work on `main`, hotfixes on `release/*`, no direct commits to release
   - **Success Criteria:** All agents follow policy, no divergent branches

3. **Create UI Component Specs Before Implementation**
   - **Owner:** Vision (Design) or @amolbabu
   - **Action:** For any "make it smaller/bigger" request, provide target font size or mockup FIRST
   - **Success Criteria:** Natasha has clear spec before coding

4. **Device Testing in QA Checklist**
   - **Owner:** Bruce Banner
   - **Action:** Add "Run on physical device or latest simulator" to regression checklist
   - **Success Criteria:** Visual bugs (emoji, rendering, spacing) caught in QA, not post-merge

#### Medium-Term (Next 2 Sprints)

5. **Extract Reusable Stat Component**
   - **Owner:** Natasha Romanoff
   - **Action:** Create `CompactStatView.swift` for reusable horizontal stat badge pattern
   - **Rationale:** Final stats layout is good — make it a standard component to avoid re-implementing

6. **Add Visual Regression Testing**
   - **Owner:** Steve Rogers (Architecture)
   - **Action:** Integrate snapshot testing (swift-snapshot-testing) to catch unintended UI changes
   - **Success Criteria:** CI fails if UI changes without explicit approval

7. **Pre-Implementation Design Reviews**
   - **Owner:** @amolbabu + Vision
   - **Action:** Hold 15-min design sync before any UI feature work starts
   - **Success Criteria:** Mockups, font sizes, spacing specs documented before coding

#### Long-Term (Backlog)

8. **Improve Build Artifact Verification**
   - **Owner:** Steve Rogers
   - **Action:** Add CI step to verify Info.plist contents match source (catch auto-generation bugs)

9. **Audio/Sound Design Strategy**
   - **Owner:** @amolbabu
   - **Action:** Decide upfront if game should have sound effects, or remain silent-by-default
   - **Rationale:** Avoid wasted implementation of features that get removed

10. **Retrospective Ceremony After Each Sprint**
    - **Owner:** Scribe + @amolbabu
    - **Action:** Formalize retro template: What Went Well / What Went Wrong / Action Items
    - **Success Criteria:** Documented learnings, no repeated mistakes across sprints

---

## 📦 Current App State

### Shipped Features

✅ **Welcome Screen**
- Radial gradient background (warm orange/yellow/pink)
- Floating emoji animations (🌟 ⭐ 🏠 🎉 🎈 ❤️)
- "How to Play" link with full instructions modal
- Privacy policy link and sheet

✅ **Setup Flow**
- Player count selection (3-12 players, validated with inline errors)
- Theme selection: Place, Country, Things, Jobs, Animal, Blind Spy
- Form validation (disabled Start button until valid)

✅ **Game Screen**
- Turn-based card reveal (one card per player)
- Card state machine: Face down → Revealed → Locked
- Turn indicator with current player highlight
- Remaining/Locked stats (compact single-line layout: 12pt numbers, 11pt labels)
- Safe area adaptation for Dynamic Island devices

✅ **End Game Screen**
- Game completion detection (all cards revealed)
- Play Again button (resets state)

✅ **Themes & Content**
- 5 theme categories with 25+ words each
- Blind Spy mode (random theme selection)
- JSON-based theme loading (easy to extend)

✅ **Polish**
- Full-screen support on iPhone 15+ (iOS 17/18)
- VoiceOver accessibility labels
- Dynamic Type support
- WCAG AA contrast compliance
- System fonts with `.rounded` design for playful aesthetic
- Smooth animations (card flips, turn transitions)

---

### Known Issues (Backlog)

- **iPad support:** Portrait only, no landscape mode (deferred to Phase 4)
- **Dark mode:** Not tested/optimized (light mode only via `UIUserInterfaceStyle`)
- **Localization:** English only
- **Haptic feedback:** Not implemented
- **Score tracking:** No points/leaderboard (game is discussion-based)

---

## 🚀 Getting Started

### Build & Run

```bash
# Open the Xcode project
open ios/FamilyGame/FamilyGame.xcodeproj

# In Xcode:
# 1. Select target: iPhone 15 Pro simulator (or any iOS 17+ device)
# 2. Product → Build (⌘B)
# 3. Product → Run (⌘R)
# 4. Play with 3+ friends on one device!
```

### Run Tests

```bash
cd ios/FamilyGame
xcodebuild test -scheme FamilyGame -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

**Test Coverage:** 214+ test methods across 13 test files (GameStateTests, TurnFlowTests, PlayerTests, etc.)

---

## 📝 Key Learnings

1. **SwiftUI Forms:** Always use `.buttonStyle(.plain)` for buttons inside Forms to prevent tap interception
2. **Safe area padding:** Use `.padding(.bottom)` without values for automatic safe area adaptation
3. **Full-screen iOS:** Requires both `UILaunchScreen` AND `UIRequiresFullScreen` AND `GENERATE_INFOPLIST_FILE = NO`
4. **Emoji rendering:** Custom fonts break emoji rendering if font files aren't bundled — use system fonts with `.design: .rounded`
5. **Stats layout:** Horizontal single-line layouts (icon + number + label) are more compact and scannable than vertical stacks
6. **Visual QA:** Screenshot + font size table BEFORE approval prevents ping-pong iterations
7. **Device testing:** Always test on simulator/device for visual bugs (canvas previews lie about emoji rendering)

---

## 📂 Project Structure

```
ios/FamilyGame/
├── FamilyGame/
│   ├── App/                    # FamilyGameApp.swift, AppState.swift
│   ├── Views/                  # SwiftUI screens (Welcome, Setup, Game, EndGame)
│   ├── Models/                 # GameState, Card, Player, Theme
│   ├── Logic/                  # GameLogic, TurnValidator
│   ├── Managers/               # (removed LaunchSoundManager)
│   ├── Resources/              # themes.json, Info.plist
│   └── Assets.xcassets/        # AppIcon, colors
├── FamilyGameTests/            # 214+ unit tests
└── FamilyGame.xcodeproj
```

---

## 🌿 Git Workflow

- **`main`** — Active development, all new commits go here
- **`release/1.0.0`** — Frozen App Store snapshot, DO NOT commit to this branch

---

## 📄 License

Private project — all rights reserved by @amolbabu.

---

## 🙏 Acknowledgments

Built with GitHub Copilot CLI and the Squad agent framework. Special thanks to the AI team for shipping a polished family game in record time! 🎉
