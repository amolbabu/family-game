# Tony Stark — History

## Project Context

**Project:** familyGame  
**Tech Stack:** Swift, CoreData or custom serialization  
**Goal:** Solid game logic, reliable saves, smooth performance  
**User:** Amolbabu  

---

## Core Context

Tony Stark is the Backend Developer. You build game mechanics, data models, and handle performance optimization.

---

## Learnings

### Phase 1 Completion — Data Layer Implementation (2026-03-06)

**Architecture:**
- Game data modeled as value types (structs) for immutability and testability
- GameState mutation methods align with SwiftUI state management patterns
- CardContent enum prevents invalid states (can't be both spy and word)
- Randomization uses built-in Swift APIs (sufficient for non-cryptographic use)

**Theme Management:**
- Singleton ThemeManager pattern centralizes resource loading
- Validation happens at app startup (fail-fast on configuration errors)
- themes.json contains 8 words per theme × 3 themes (24 words total)
- All words are family-friendly and kid-recognizable per PRD

**Error Handling:**
- Configuration errors (missing themes, empty word lists) caught at load-time
- Runtime errors (invalid card/player indices) throw specific error types
- Custom error enums enable granular testing and debugging

**Card Generation Logic:**
- `generateCards()` creates N cards for N players
- Exactly 1 spy position, randomized via `Int.random(in:)`
- All non-spy cards show the same word
- Edge cases covered: 2-8 player counts, various themes, invalid inputs

**Testing Surface:**
- GameLogic functions are pure (no side effects) → easy to test
- GameState mutations are observable and verifiable
- Error types enable specific failure assertions
- Randomness coverage tested via statistical distribution (300 runs per test)

**Integration:**
- Natasha's UI layers build on AppState and GameLogic
- Bruce's test suite covers all card generation, state transitions, edge cases
- Save/Load system ready (GameState conforms to Codable)
- Future features (iPad, more themes) plug in without architecture changes

---

### Phase 2 Completion — Turn-Based Mechanics (2026-03-07)

**Turn Validation Architecture:**
- Extracted TurnValidator struct encapsulates all turn-based rules
- Pure functions (no state mutation) enable easy testing and reuse
- Validators include: card index bounds, card state, player turn checks
- Clear separation of concerns: validation logic separate from state mutation

**UI-Facing API Design:**
- `performCardTap()` is the primary UI integration point
- Single method handles both reveal and hide operations atomically
- TapResult enum provides rich feedback without throwing exceptions
- UI never calls low-level methods (revealCard, hideCard, lockCard) directly

**Error Handling Strategy:**
- Throwing methods (revealCard, hideCard, lockCard) for backend use
- Non-throwing performCardTap() for UI with TapResult enum
- Extended GameError enum with specific error types
- Clear error messages guide user actions (e.g., "Card already used")

**Replay & Persistence Design:**
- resetGameState() maintains players & theme, regenerates cards & word
- Atomic reset: single call changes all necessary state
- Future-proof: structure enables save/load without architecture changes
- GameState.Codable support enables UserDefaults or file-based persistence

**Testing Coverage:**
- 30+ new tests in Phase2TurnsTests.swift
- Integration tests cover complete game flows (2-8 players)
- Edge cases: last card locked, reset mid-game, invalid indices
- TapResult enum tested for all branches (revealed, hidden, locked, invalid)

**Performance & Concurrency:**
- All operations O(1) or O(n) with small n
- Value type semantics ensure thread-safety (no shared mutable state)
- Ready for future async/await patterns (no blocking I/O)
- No external dependencies; pure Swift implementation

---

### Black Margin Fix — didMoveToWindow Timing (2026-03-25)

**Problem:**
- `.onAppear` fires AFTER first frame render → 50-200ms black flash at launch
- Protocol-based safeAreaRegions fix was correct, but timing was wrong
- Users see black margins briefly on every app launch

**Solution:**
- UIViewRepresentable with `didMoveToWindow()` callback fires BEFORE first frame
- `didMoveToWindow()` executes during window hierarchy setup, not after render
- EarlyWindowConfigurator added as first child in root ZStack
- Removed entire `.onAppear` block — no longer needed

**Technical Details:**
- `EarlyWindowConfigurator.ConfigView.didMoveToWindow()` accesses window immediately
- Sets `window.backgroundColor = .white` for clean background
- Calls existing `HostingControllerFix.disableSafeAreaPropagation()` protocol method
- Zero flash: configuration happens before UIKit draws first frame

**Related Fix:**
- GameScreenView had hardcoded `isCurrentPlayerTurn: true`
- Fixed to pass actual turn state: `gameState.gamePhase == .inGame`
- Cards now properly disable when not in active game phase

**Learning:**
- SwiftUI lifecycle timing: `.onAppear` vs UIKit view hierarchy callbacks
- UIViewRepresentable provides early access to window/view controller before render
- For frame-1 configuration, use `didMoveToWindow()` not `.onAppear`

---

## Regression Sprint Results (2026-04-15)

**Context:** Full codebase regression audit completed by Bruce Banner QA. 24 files reviewed, 4 issues identified (1 MEDIUM, 2 LOW, 1 ENHANCEMENT). Backend game logic verified as stable.

### Backend Issues Identified (Awareness)

| Issue | Severity | File | Impact on Backend |
|-------|----------|------|-------------------|
| Issue #3 | MEDIUM | SetupScreenView.swift | Player validation in UI (SetupScreen allows 1 player, but GameLogic expects 2+). Backend already enforces minimum 2 via GameLogic.generateCards() |
| Issue #5 | LOW | GameScreenView.swift | Turn indicator layout on Pro devices (backend logic unaffected) |

**Key Finding:** Tony's backend architecture is sound. GameState, TurnValidator, and game logic validated as production-ready. No architectural changes needed.

**Related Frontend Work:** Natasha Romanoff merged safe area fix to release/1.0.0 (dynamic inset replacement for hardcoded 72pt).

---

## QA Findings Context (2026-03-25)

### Bruce Banner QA Audit Summary — Black Margin & CardView Turn Issues

**Critical Issues Affecting Tony's Work:**

1. **Black Margin Timing Bug (CRITICAL)**
   - `.onAppear` in FamilyGameApp.swift applies safe area fix AFTER first render (50-200ms flash visible)
   - Solution: Implement UIApplicationDelegate hook or custom UIHostingController to configure before first render
   - Impact: Visual polish for app launch

2. **CardView Turn Enforcement Hardcoded (MODERATE)**
   - GameScreenView.swift line 105: `isCurrentPlayerTurn: true` should be `(gameState.currentPlayerIndex == index)`
   - Currently masked by CardView.swift internal check, but violates separation of concerns
   - Future refactoring risk: internal check could be removed, breaking turn validation
   - Impact: Game mechanics correctness

**Full QA Report:**
- Build: Clean (0 errors, 2 pre-existing deprecation warnings)
- Family-Safe Content: Validated
- State Machine: Robust TurnValidator architecture approved
- Test Coverage: 214+ test methods available
- Status: 5 issues found (1 critical, 2 moderate, 2 cosmetic)

**Next Steps for Tony:**
1. Fix black margin timing (AppDelegate approach recommended)
2. Fix CardView turn flag (line 105 in GameScreenView)
3. Verify changes with QA before next test cycle

---

### Animal Theme & Blind Spy Rename (2026-04-15)

**Theme Expansion:**
- Added "Animal" theme with 30 family-friendly animal words
- Updated all four data sources to maintain sync: themes.json, AppState.swift, ThemeManager.swift, GameLogic.swift
- Animal words: Lion, Elephant, Penguin, Dolphin, Eagle, Tiger, Kangaroo, Giraffe, Cheetah, Panda, Octopus, Flamingo, Gorilla, Chimpanzee, Crocodile, Parrot, Shark, Butterfly, Peacock, Koala, Zebra, Wolf, Deer, Fox, Rabbit, Owl, Bear, Hawk, Seal, Camel
- All words kid-recognizable and family-safe per PRD requirements

**Random Theme Rename:**
- Changed Theme.random rawValue from "Random" to "Blind Spy" for better game clarity
- Swift case name remains `random` (preserves existing code references)
- Updated GameLogic.resolveTheme() to check "Blind Spy" instead of "Random"
- Updated concreteThemes array to include "Animal" (now 5 themes for random selection)
- Documentation comments updated to reflect new naming

**Data Sync Pattern:**
- Reinforced importance of keeping 4 data sources in sync: JSON resource, enum rawValue, ThemeManager fallback, GameLogic validation
- Single source of truth for theme names: Theme enum rawValues drive all string comparisons
- Fallback system ensures app works even if JSON fails to load

**Branch Context:**
- Changes made on release/1.0.0 branch
- No commit yet - Natasha working on SetupScreenView in parallel
- Coordinated team effort for v1.0.0 release
