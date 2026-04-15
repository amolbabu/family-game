# Project Learnings — SPY WORD

A comprehensive record of technical, process, and design learnings from building the SPY WORD iOS family game, captured for future projects.

---

## 🛠️ Technical Learnings

### SwiftUI Safe Area Handling

**Pattern Discovered:**
```swift
ZStack {
    backgroundView.ignoresSafeArea()  // ✅ only background extends
    VStack { /* content */ }           // ✅ content respects safe area
}
// ❌ NEVER .ignoresSafeArea() on ZStack itself
```

**Why:** On iPhone 15+ with Dynamic Island, content behind status bar becomes illegible. Background can extend (decorative), but interactive content must respect safe area insets.

**Files:** `WelcomeScreenView.swift`, `GameScreenView.swift`, `SetupScreenView.swift`

---

### Custom Font and Emoji Rendering

**Critical Bug:** `.custom("Baloo2-Bold")` font references without bundled font files caused ALL emoji to render as "?" boxes.

**Root Cause:** When custom fonts fail to load, iOS fallback mechanism breaks emoji rendering in SwiftUI.

**Solution:** Replace custom fonts with system fonts using `.design: .rounded`:
```swift
// OLD: .custom("Baloo2-Bold", size: 28)
// NEW: .system(size: 28, weight: .bold, design: .rounded)
```

**Key Learnings:**
- Always test emoji rendering when changing fonts
- Simulator may show fonts that physical devices don't have
- System font variants (`.rounded`, `.serif`) provide aesthetic options without bundling
- Custom fonts require: TTF/OTF files + Info.plist registration + Build Phases inclusion

**Files Affected:** `AnimatedTitle.swift`, `WelcomeScreenView.swift`, `VibrantButton.swift`, `HowToPlayView.swift`, `PrivacyPolicyView.swift`

**Commit:** 5580b3af

---

### Full-Screen Support on iPhone 15+ (iOS 18+)

**Two-Part Fix Required:**

**Part 1:** `UILaunchScreen` in Info.plist
```xml
<key>UILaunchScreen</key>
<dict>
    <key>UIImageName</key>
    <string></string>
    <key>UIColorName</key>
    <string>LaunchScreenBackground</string>
</dict>
```

**Part 2:** `UIRequiresFullScreen` in Info.plist
```xml
<key>UIRequiresFullScreen</key>
<true/>
```

**Why Both Are Needed:**
- `UILaunchScreen`: Enables modern launch API, replaces storyboards
- `UIRequiresFullScreen`: Opts out of iOS 18+ multitasking, prevents letterboxing

**Symptom Without Fix:** ~240px black bars top/bottom on iPhone 17 Pro simulator

**Additional Fix:** Disable `GENERATE_INFOPLIST_FILE` in Xcode build settings
- Xcode was auto-generating Info.plist during build, ignoring custom settings
- Set `GENERATE_INFOPLIST_FILE = NO` in `project.pbxproj`

**Commits:** e52159ab, d36a6ed8, ce4478f5

**Key Learning:** Runtime SwiftUI fixes cannot solve launch configuration issues. Info.plist configuration happens before SwiftUI initialization.

---

### SwiftUI Button Tap Issues in Forms

**Problem:** Theme buttons (Place, Things, Country) inside `Form` were not responding to taps.

**Root Cause:** SwiftUI `Form` intercepts tap events for list row interactions. Nested buttons don't receive taps by default.

**Solution:** Add `.buttonStyle(.plain)` to all buttons inside Forms
```swift
Button(action: { selectTheme(.place) }) {
    Text("Place")
}
.buttonStyle(.plain)  // ← Required for tap handling in Forms
```

**File:** `SetupScreenView.swift`

**Key Takeaway:** Always use `.buttonStyle(.plain)` for buttons inside SwiftUI Forms when you want direct button tap behavior.

---

### ForEach View Identity and Card State Bug

**Bug:** Cards showing as revealed on initial GameScreenView render instead of face-down.

**Root Cause:** ForEach using index position instead of stable card ID:
```swift
// BROKEN:
ForEach(gameState.cards.indices) { index in
    CardView(...)
}

// FIXED:
ForEach(gameState.cards, id: \.id) { card in
    CardView(...)
}
```

**Why This Matters:** SwiftUI reuses views based on identity. Without stable IDs, view reuse bugs occur during state changes.

**File:** `GameScreenView.swift:80`

**Commit:** 5023d7f

---

### Early Window Configuration (Black Margin Flash Fix)

**Problem:** Black margins flash for 50-200ms on app launch when using `.onAppear` to configure window.

**Root Cause:** `.onAppear` fires AFTER first render. SwiftUI renders → callbacks execute → too late.

**Solution:** Use `UIViewRepresentable` with `didMoveToWindow()` to configure BEFORE first frame:
```swift
private struct EarlyWindowConfigurator: UIViewRepresentable {
    func makeUIView(context: Context) -> ConfigView { ConfigView() }
    func updateUIView(_ uiView: ConfigView, context: Context) {}
    
    final class ConfigView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            guard let window else { return }
            window.backgroundColor = .white
            if #available(iOS 16.0, *),
               let hostingVC = window.rootViewController as? any HostingControllerFix {
                hostingVC.disableSafeAreaPropagation()
            }
        }
    }
}
```

**Pattern:** Bridge SwiftUI and UIKit lifecycle for pre-render configuration

**File:** `FamilyGameApp.swift`

**Impact:** Eliminates visible flash, clean UX from frame 1

---

### Bottom-Pinned Sheet Button Pattern

**Problem:** "Hide Card & Next Player" button cut off on physical iPhone due to home indicator.

**Solution:** Use `.padding(.bottom)` without a value for safe-area-aware padding:
```swift
VStack(spacing: 0) {
    // Header
    headerContent.padding(.horizontal, 20).padding(.top, 20)
    
    // Scrollable content
    ScrollView { VStack { /* content */ } }
    
    // Pinned button
    Button(action: action) {
        Text("Action")
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.green)
            .cornerRadius(12)
    }
    .padding(.horizontal, 20)
    .padding(.bottom)  // ⬅️ No value = safe-area-aware (adds ~34pt on iPhone 15+)
}
```

**Anti-Pattern:** Fixed values like `.padding(.bottom, 24)` break on modern iPhones

**File:** `CardRevealSheet` in `GameScreenView.swift`

---

### Font Size Minimums for Accessibility

**Experiment:** Stats sizing went through 4 iterations before settling.

**Critical Threshold:** 6pt is minimum legibility on iPhone displays. Below 6pt becomes illegible.

**Final Sizing (TurnIndicatorView stats):**
- Icons: 13pt (readable SF Symbols)
- Numbers: 13pt bold (primary data)
- Labels: 10pt semibold (secondary context, minimum accessible size)

**Key Learning:** Test on physical devices at arm's length. What looks fine on simulator at close range may be illegible in real usage.

**File:** `TurnIndicatorView.swift`

**Decision Log:** `.squad/decisions.md` — Stats went from too large → two-column unreadable → single-line overcompact → final balanced design

---

### Turn Enforcement Architecture

**Bug:** GameScreenView passing `isCurrentPlayerTurn: true` to all CardView instances, allowing any player to tap any card.

**Fix:** Conditional parameter based on index match:
```swift
// BROKEN:
CardView(card: card, isCurrentPlayerTurn: true, onReveal: ...)

// FIXED:
CardView(
    card: card, 
    isCurrentPlayerTurn: (gameState.currentPlayerIndex == index),
    onReveal: ...
)
```

**Pattern:** View layer should compute UI state from data model, not use hardcoded flags

**File:** `GameScreenView.swift:85`

**Commit:** 983b7ec

---

## 🎨 UI/UX Learnings

### Stats Layout Evolution

**Iteration History:**
1. **Vertical 3-row:** Icon/Number/Label stacked (too large, dominated screen)
2. **Horizontal single-line:** Icon + Number + Label inline (much better)
3. **Ultra-compact:** 9pt/6pt fonts (too small, illegible)
4. **Final balanced:** 13pt icons/numbers, 10pt labels, two-column layout

**Key Pattern:** For compact UI elements, prefer horizontal layouts with consistent font sizes rather than vertical stacking.

**Visual Formula:**
- Icon size = Number size (visual unity)
- Label size ≥ 10pt (accessibility threshold)
- Spacing reduction has bigger visual impact than font shrinking
- Test at arm's length on physical device, not close-up in simulator

**File:** `TurnIndicatorView.swift`

---

### Warm Color Palette & Family-Friendly Design

**Color Strategy:**
- **Radial gradients** work better than linear for warm colors (orange/yellow/pink)
- Creates "sun burst" or "warm glow" effect
- More inviting than geometric linear gradients

**Emoji Usage:**
- Universally recognized, colorful, inherently playful
- Better than SF Symbols for "family fun" communication
- Mark `.accessibilityHidden(true)` for decorative emoji (not informative)

**Animation Choreography:**
- Staggered entrance creates delight: 0.0s background → 0.2s title → 0.4s subtitle → 0.6s icon → 0.9s button
- Progressive disclosure keeps eye engaged
- All-at-once appearance feels cheap; staggered feels considered

**File:** `WelcomeScreenView.swift`

---

### Compact vs. Verbose UI Philosophy

**Learning:** For pass-and-play mobile games, compact wins over verbose.

**Why:**
- Single device shared by multiple players
- Screen real estate is precious
- Players glance at stats, don't study them
- Minimize cognitive load per turn

**Pattern Applied:**
- Stats: Icon + Number + Label inline (not stacked)
- Padding: 5pt (not 8pt)
- Font sizes: 10-13pt range (not 14-18pt)
- Spacing: Tight but legible

**Counter-Example:** Dashboard apps need verbose labels and generous spacing. Games need density.

---

### Theme Button Visual Affordance

**UX Confusion:** Users reported "Place and Things could not be selected"

**Root Cause:** Unselected buttons used `Color.gray.opacity(0.3)` → looked disabled (low contrast)

**Fix:**
- Unselected: `Color(UIColor.secondarySystemFill)` + border (clear tappable affordance)
- Selected: `Color.playfulBlue` + white border (clear active state)
- Contrast ratios: ~13:1 unselected, ~4.8:1 selected (WCAG AA compliant)

**Key Learning:** Low-opacity backgrounds are perceived as "disabled" by users. Use semantic system colors for clear affordance.

**File:** `SetupScreenView.swift`

---

### Inline Validation vs. Modal Alerts

**Pattern:** Inline hints beat modal alerts for form validation

**Example:** Player count minimum validation
- User types "1"
- Inline hint appears: "Minimum 2 players required"
- Start button disabled with opacity 0.5
- Clear, contextual, non-intrusive

**Why Better Than Modal:**
- Less disruptive, appears immediately as user types
- Contextual placement near the input that needs correction
- Matches modern mobile UX patterns

**File:** `SetupScreenView.swift`

**Commit:** 71211051

---

## 🐛 Bugs & Root Causes

### Bug #1: Card Reveal State on Initial Render
**Symptom:** Cards showing as revealed on initial GameScreenView render instead of face-down

**Root Causes (3 layers):**
1. ForEach using index position instead of stable card ID (`id: \.id`)
2. Turn enforcement flag hardcoded to `true` (should be dynamic per index)
3. Card initialization potentially mutating state

**Fix:** All three architectural issues resolved in commits 5023d7f, 983b7ec

**Files:** `GameScreenView.swift:80, :85`, `GameLogic.swift:45`

---

### Bug #2: Black Margin Flash on Launch
**Symptom:** 50-200ms visible black margin flash at top/bottom on app launch

**Root Cause:** `.onAppear` fires AFTER first render

**Fix:** `EarlyWindowConfigurator` UIViewRepresentable with `didMoveToWindow()`

**File:** `FamilyGameApp.swift`

**Impact:** Poor first impression, breaks immersion

---

### Bug #3: Emoji Rendering Failure (ALL emojis as "?" boxes)
**Symptom:** Every emoji in app renders as box with question mark

**Root Cause:** Custom font references (Baloo2-Bold, Baloo2-Medium) without bundled font files

**Fix:** Replace all custom fonts with `.system(size:weight:design: .rounded)`

**Files:** 5 view files, 19 font declarations

**Commit:** 5580b3af

**Impact:** CRITICAL — visual corruption, app not release-ready

---

### Bug #4: Theme Buttons Not Responding to Taps
**Symptom:** Place, Country, Things buttons inside Form not responding to taps

**Root Cause:** SwiftUI Form intercepts tap events for list row system

**Fix:** Add `.buttonStyle(.plain)` to all theme buttons

**File:** `SetupScreenView.swift`

**Learning:** Forms require explicit button style for tap handling

---

### Bug #5: CardRevealSheet Button Cut Off
**Symptom:** "Hide Card & Next Player" button not visible on physical iPhone

**Root Cause:** Fixed `.padding(.bottom, 24)` doesn't account for ~34pt safe area inset (home indicator)

**Fix:** Use `.padding(.bottom)` without value for safe-area-aware padding

**Pattern:** VStack + ScrollView + pinned button with safe-area-aware padding

**File:** `GameScreenView.swift` (CardRevealSheet)

---

### Bug #6: Letterboxing on iPhone 15+ (iOS 18+)
**Symptom:** ~240px black bars top/bottom on iPhone 17 Pro simulator

**Root Causes:**
1. Missing `UILaunchScreen` in Info.plist
2. Missing `UIRequiresFullScreen` in Info.plist
3. Xcode auto-generating Info.plist during build (ignoring custom settings)

**Fix:** All three issues resolved
- Added UILaunchScreen and UIRequiresFullScreen
- Disabled GENERATE_INFOPLIST_FILE in build settings

**Commits:** e52159ab, d36a6ed8, ce4478f5

---

### Bug #7: SetupScreenView Cramped Layout
**Symptom:** Form layout caused tight vertical stacking with floating button

**Root Cause:** SwiftUI Form's automatic spacing and section behavior

**Fix:** Replace Form with custom ScrollView + VStack layout
- 32pt vertical spacing between sections
- 24pt horizontal padding
- Start button pinned at bottom with Divider

**File:** `SetupScreenView.swift`

**Commit:** fab1d1a3

---

### Bug #8: Content Rendering Behind Status Bar
**Symptom:** Game screen content overlaps iOS status bar (time, battery, signal)

**Root Cause:** `.ignoresSafeArea()` on root ZStack instead of scoped to background

**Fix:** Remove root-level `.ignoresSafeArea()`, keep only on background views

**File:** `GameScreenView.swift:144`

**Commit:** fab1d1a3

---

## 🔄 Process Learnings

### Team Coordination Patterns

**Parallel Work Strategy:**
- Data model changes → Tony (backend)
- View layout changes → Natasha (frontend)
- Integration happens automatically via property bindings

**Example:** Animal theme + Blind Spy button
- Natasha: Added `Theme.animal` to ForEach array in UI
- Tony: Updated `Theme.random.rawValue` to "Blind Spy" in data model
- UI automatically updates via property-driven rendering (no duplicated strings)

**Key Benefit:** Team parallelization without merge conflicts, single source of truth for display text

---

### QA Philosophy Applied

**Bruce Banner's QA Approach:**
- Give honest assessment, not cheerleading
- Identify specific line numbers and exact font sizes
- Distinguish between what works and what needs fixing
- Provide clear severity assessment (CRITICAL/MEDIUM/LOW)
- Acknowledge good work while being precise about remaining issues

**Example Output:** "⚠️ NEEDS TWEAK — Minor issue: Remove or balance the Spacer() to fix left-alignment problem. Otherwise the implementation is solid."

**Impact:** Developer gets actionable feedback without frustration, knows exact scope of fix

---

### Iterative Sizing vs. First-Principles Design

**Anti-Pattern Identified:** "Ping-pong" on stats sizing

**What Happened:**
- Too large → shrink → too small → enlarge → repeat 4 times
- User frustration: "Can we just settle on a size?"

**Better Approach:**
- Start with accessibility minimums (10pt labels, 13pt icons)
- Test on physical device at arm's length
- Make ONE informed decision based on real usage context
- Document reasoning and lock it

**Key Learning:** Iterative refinement has diminishing returns. After 2-3 iterations, analyze why it's not settling and make a first-principles decision.

---

### Documentation Discipline

**Pattern Established:** `.squad/decisions.md` logs all architectural decisions

**Structure:**
- Context: What problem are we solving?
- Decision: What did we choose?
- Rationale: Why this choice over alternatives?
- Alternatives Considered: What did we reject and why?
- Impact: User-facing and technical effects
- Verification: Build status, commit SHA

**Benefit:** Future developers understand WHY choices were made, not just WHAT was implemented

**Examples:**
- Full-screen configuration decisions (UILaunchScreen + UIRequiresFullScreen)
- Font strategy (system fonts vs. custom)
- Safe area patterns
- Bottom-pinned button patterns

---

### Build Verification Rigor

**Standard Practice:**
- Every fix validated with clean build: 0 errors, 0 warnings (or acknowledged acceptable warnings)
- Visual inspection on simulator AND physical device when possible
- Screenshots captured for GitHub issues
- Commit messages reference issue numbers

**Example Workflow:**
1. Identify bug (Bruce QA)
2. Implement fix (Natasha/Tony)
3. Build verification: `xcodebuild clean build`
4. Visual test on simulator
5. Commit with descriptive message and issue reference
6. Update GitHub issue with fix confirmation

---

## 📐 Architecture Decisions

### Value Type Architecture for Game State

**Decision:** GameState, Card, Player use immutable structs (not classes)

**Rationale:**
- Thread-safety: No shared mutable state
- Testability: Pure functions, predictable state transitions
- SwiftUI integration: Value types work naturally with @Observable

**Files:** `GameState.swift`, `Card.swift`, `Player.swift`

**Impact:** Zero state corruption bugs detected in 214+ test methods

**Assessment (Tony Stark):** Production-ready for MVP, excellent foundation

---

### Theme Data in JSON (Not Hardcoded)

**Decision:** Themes loaded from `themes.json` file

**Rationale:**
- Easy to add new themes without code changes
- Content editing doesn't require Xcode
- Clear separation: game logic vs. content data
- Future CDN-based content updates possible

**Files:** `themes.json`, `ThemeManager.swift`

**Extensibility:** Added Animal theme by editing JSON only, no code changes

---

### Single Device Pass-and-Play Model

**Decision:** One iPhone passed between players (not multiplayer networking)

**Rationale:**
- Fits family game night use case (co-located players)
- Simplifies architecture (no server, no network code)
- Maintains game secrecy (no screen mirroring risks)
- Lower development complexity for MVP

**Trade-off:** Cannot play remotely, but aligns with product vision

---

### Branch Policy: release/1.0.0 Strategy

**Pattern:**
- Feature work in `feature/*` branches
- Integration to `release/1.0.0` for QA
- Clean git history with descriptive commit messages
- Co-authored-by trailer on all commits: `Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>`

**Why:** Supports CI/CD integration, clear release versioning, team attribution

---

### Font Strategy: System Fonts Over Custom

**Decision:** Use `.system(size:weight:design: .rounded)` instead of custom Baloo2 fonts

**Rationale:**
- No bundle size impact (~200KB saved)
- Guaranteed availability on all iOS versions
- Full emoji support out-of-box
- Respects user accessibility settings better
- `.design: .rounded` provides playful aesthetic without custom fonts

**Commit:** 5580b3af

**Impact:** Critical bug fix, enables emoji rendering across app

---

### Minimum Player Count: 3 (Not 2)

**Decision:** SetupScreenView enforces minimum 3 players

**Rationale:** Confirmed by product owner (amolbabu) 2026-04-15

**Validation:** Two-tier approach
- Input validation: Allow 1-12 for typing (to show hints)
- Action validation: Enforce 3-12 for starting game

**File:** `SetupScreenView.swift`

**Note:** Earlier iterations used minimum 2 players; updated to 3 per product requirements

---

### Privacy-First Approach

**Decision:** Zero data collection, no analytics, no third-party SDKs

**Rationale:**
- Family-friendly positioning requires trust
- Simpler App Store review
- No ATT (App Tracking Transparency) prompt needed
- Faster app performance (no SDK overhead)

**Impact:** Clean privacy surface, minimal Info.plist permissions

---

## ⚠️ What To Avoid Next Time

### 1. Custom Fonts Without Bundling

**Mistake:** Referenced `.custom("Baloo2-Bold")` without including font files

**Impact:** Complete emoji rendering failure (all emojis as "?" boxes)

**Lesson:** If using custom fonts:
- Bundle TTF/OTF files in project
- Register in Info.plist `UIAppFonts`
- Add to Build Phases → Copy Bundle Resources
- Test on physical device (not just simulator)

**Better:** Start with system fonts, only add custom fonts if truly necessary

---

### 2. Hardcoded Safe Area Values

**Mistake:** Using fixed padding values (e.g., `.padding(.bottom, 24)`) for device-dependent layouts

**Impact:** Buttons cut off on iPhone 15+ with home indicator

**Lesson:** Use `.padding(.bottom)` without value for safe-area-aware padding, or use GeometryReader for dynamic calculation

---

### 3. Iterative Sizing Without First Principles

**Mistake:** Ping-pong on stats sizing through 4 iterations (too large → too small → repeat)

**Impact:** Developer frustration, wasted time, user impatience

**Lesson:** After 2 attempts, step back and apply first principles:
- What are accessibility minimums? (10pt+ for labels)
- Test on physical device at arm's length
- Make ONE informed decision and lock it
- Document reasoning to prevent re-opening

---

### 4. `.ignoresSafeArea()` on Container Views

**Mistake:** Applying `.ignoresSafeArea()` to ZStack/VStack instead of scoped to backgrounds only

**Impact:** Content rendering behind status bar, illegible UI

**Pattern to Follow:**
```swift
ZStack {
    backgroundView.ignoresSafeArea()  // ✅ only decorative backgrounds
    VStack { content }                 // ✅ respects safe area
}
```

---

### 5. Form for Custom Layouts

**Mistake:** Using SwiftUI `Form` for custom button layouts

**Impact:** Tap events intercepted, buttons unresponsive

**Lesson:** Use `Form` for standard iOS settings-style UIs. For custom layouts, use ScrollView + VStack with explicit spacing.

---

### 6. Assuming Xcode Build Settings

**Mistake:** Editing Info.plist without verifying Xcode isn't auto-generating it

**Impact:** ~240px letterboxing on iPhone 15+ because `GENERATE_INFOPLIST_FILE` was overriding manual edits

**Lesson:** Always verify build settings when Info.plist changes don't take effect. Check `GENERATE_INFOPLIST_FILE`, `CODE_SIGN_IDENTITY`, etc.

---

### 7. Simulator-Only Testing for Fonts

**Mistake:** Testing emoji rendering only on simulator, not physical device

**Impact:** Simulator showed fonts that physical device didn't have, hiding emoji bug

**Lesson:** Always test font/emoji changes on physical device. Simulator can have system fonts that apps won't.

---

## ✅ Best Practices Established

### 1. Safe Area Pattern (All Screens)

```swift
ZStack {
    backgroundView.ignoresSafeArea()  // Decorative only
    VStack { content }                 // Interactive content
        .padding(.top, 8)              // Optional cushion
}
```

**Files:** `WelcomeScreenView.swift`, `GameScreenView.swift`, `SetupScreenView.swift`

---

### 2. Bottom-Pinned Sheet Buttons

```swift
VStack(spacing: 0) {
    headerContent.padding(.horizontal, 20).padding(.top, 20)
    ScrollView { VStack { /* content */ } }
    Button("Action") { /* action */ }
        .padding(.horizontal, 20)
        .padding(.bottom)  // ⬅️ Safe-area-aware
}
```

**File:** `GameScreenView.swift` (CardRevealSheet)

---

### 3. ForEach with Stable IDs

```swift
// ✅ CORRECT:
ForEach(items, id: \.id) { item in
    ItemView(item)
}

// ❌ WRONG:
ForEach(items.indices) { index in
    ItemView(items[index])
}
```

**Why:** Stable IDs prevent view reuse bugs during state changes

**File:** `GameScreenView.swift:80`

---

### 4. Two-Tier Form Validation

**Pattern:**
- `isValidInput`: UI affordance (is the input valid?)
- `canProceed`: Business logic (can the action actually execute?)

**Example:**
```swift
var isValidInput: Bool { (1...12).contains(playerCount) }
var canProceed: Bool { (3...12).contains(playerCount) }
```

**File:** `SetupScreenView.swift`

**Benefit:** Users see hints explaining constraints, not just disabled buttons

---

### 5. Inline Validation Hints

```swift
if let count = Int(input), count < minimumRequired {
    Text("Minimum \(minimumRequired) players required")
        .font(.caption)
        .foregroundColor(.secondary)
}
```

**Pattern:** Contextual, non-intrusive, appears as user types

**File:** `SetupScreenView.swift`

---

### 6. Property-Driven UI (Not Hardcoded Strings)

```swift
// ✅ CORRECT:
Text(theme.rawValue)  // Property-driven

// ❌ WRONG:
Text("Random")        // Hardcoded
```

**Benefit:** Single source of truth, automatic UI updates when data changes

**Files:** `SetupScreenView.swift`, theme button implementations

---

### 7. Accessibility Labels for Decorative Elements

```swift
Text("🌟")
    .font(.system(size: 40))
    .accessibilityHidden(true)  // Decorative only, not informative
```

**Pattern:** Mark decorative emoji/icons as hidden for VoiceOver

**File:** `WelcomeScreenView.swift` (FloatingEmojiLayer)

---

### 8. Early Window Configuration for Pre-Render Setup

```swift
private struct EarlyWindowConfigurator: UIViewRepresentable {
    final class ConfigView: UIView {
        override func didMoveToWindow() {
            // Configure BEFORE first render
        }
    }
}
```

**Use Case:** Window-level configuration that must happen before SwiftUI rendering

**File:** `FamilyGameApp.swift`

---

### 9. Build Verification Standard

**Checklist:**
- [ ] Clean build: 0 errors
- [ ] Warnings reviewed (acceptable vs. must-fix)
- [ ] Visual inspection on simulator
- [ ] Test on physical device when possible
- [ ] Screenshot captured for documentation
- [ ] Commit with descriptive message + issue reference

---

### 10. Design Token Extraction

**Pattern:**
```swift
// Spacing scale (8pt baseline)
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
}

// Typography
enum Typography {
    static let h1 = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .rounded)
}
```

**Benefit:** Consistent UI, easy theme changes, single source of truth

**Reference:** `.squad/skills/vision-design-tokens.md`

**Status:** Partially implemented; full extraction deferred to Phase 3

---

## 📊 Metrics & Success Indicators

### Test Coverage
- **214+ test methods** across 11 test files
- Unit tests for GameState, TurnFlow, PlayerCount, AppState, etc.
- Zero state corruption bugs in comprehensive testing
- Build reproducibility: Clean builds on demand

### Code Quality
- **38 Swift files** well-organized (Models → Logic → Views)
- Clear separation of concerns
- Comprehensive MARK comments for navigation
- Value type architecture prevents accidental shared state

### Build Quality
- **0 errors** on every verified build
- Minimal warnings (2 async warnings acknowledged as acceptable)
- Clean git history with descriptive commits
- Proper Co-authored-by attribution

### Architecture Scalability
- Proven to scale from 3-12 players
- Theme system supports easy content expansion (added Animal theme with JSON-only change)
- Ready for Phase 3 features (scoring, game variants)

---

## 🎯 Key Takeaways for Next Project

1. **System fonts first, custom fonts only if necessary** — saves bundle size, ensures emoji support
2. **Safe area is not optional** — test on iPhone 15+ from day 1, not at the end
3. **Physical device testing required** — simulator hides font, emoji, safe area bugs
4. **Info.plist requires build settings verification** — check GENERATE_INFOPLIST_FILE
5. **Iterative design needs guardrails** — after 2-3 iterations, apply first principles
6. **QA honesty > cheerleading** — specific, actionable feedback with severity assessment
7. **Documentation is future-proofing** — `.squad/decisions.md` pattern saves time on future changes
8. **Value types for game state** — immutability prevents entire classes of bugs
9. **Property-driven UI** — enums and bindings over hardcoded strings
10. **Accessibility from day 1** — VoiceOver labels, font minimums, safe touch targets

---

**Document Version:** 1.0  
**Last Updated:** 2026-04-15  
**Project Status:** Phase 2 Complete, Ready for MVP Release  
**Team:** Natasha Romanoff (Frontend), Bruce Banner (QA), Tony Stark (Backend), Steve Rogers (Architecture), Vision (Design)

---

*This is a living document. Add new learnings as they are discovered.*
