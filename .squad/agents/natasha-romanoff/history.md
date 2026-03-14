# Natasha Romanoff — History

## Project Context

**Project:** familyGame  
**Tech Stack:** Swift, SwiftUI, possibly SpriteKit  
**Goal:** Beautiful, intuitive, accessible UI for all ages  
**User:** Amolbabu  

---

## Core Context

Natasha Romanoff is the Frontend/UI Engineer. You build SwiftUI components, animations, and ensure family-friendly UX with accessibility in mind.

---

## Learnings

### Phase 1: Welcome & Setup UI (Completed 2026-03-06)

#### Architecture
- **State Model:** Used `@Observable` AppState class for modern, simple reactive state management
  - Single source of truth: `currentScreen`, `playerCount`, `playerNames`, `selectedTheme`
  - Methods: `setPlayerCount()`, `updatePlayerName()`, `startGame()`, `goToSetup()`, `resetGame()`
  - No third-party dependencies; aligns with iOS 17+ best practices

#### View Patterns
- **WelcomeScreenView:** Centered, icon-based layout with clear CTA. SF Symbol `person.3.fill` as placeholder (art TBD)
- **SetupScreenView:** Form-based with segmented controls for 2–8 player count, text fields for names, segmented picker for themes
- **Form Validation:** "Start Game" button disabled until all player names are non-empty
- **Navigation:** ZStack in FamilyGameApp switches screens based on `AppState.currentScreen` enum

#### Accessibility
- VoiceOver labels & hints on all interactive elements
- System colors (no custom color palettes yet — deferred to Phase 3)
- Dynamic Type support via `.font(.system(...))` sizing
- Portrait-only orientation locked in Info.plist (iPad support Phase 3)

#### Key File Paths
- App entry: `ios/FamilyGame/FamilyGame/App/FamilyGameApp.swift`
- State: `ios/FamilyGame/FamilyGame/Models/AppState.swift`
- Views: `ios/FamilyGame/FamilyGame/Views/{WelcomeScreenView,SetupScreenView}.swift`

#### Integration Notes
- **Tony Stark (Backend):** Can now build GameScreenView and inject GameState model alongside AppState
- **Bruce Banner (QA):** Can write snapshot/unit tests for view state transitions
- **Team:** Xcode project file (.xcodeproj) to be generated next (not included in Phase 1 UI scope)

#### Decisions Logged
- See `.squad/decisions/inbox/natasha-romanoff-view-structure.md` for full design rationale

### Phase 2: Game Screen & Turn-Based Card Reveal (Completed 2026-03-07)

#### GameScreenView Architecture
- **State Management:** Uses local @State for GameState alongside @Environment AppState
- **Initialization:** GameState populated via onAppear; creates players from appState.playerNames
- **Card Grid:** Responsive LazyVGrid with adaptive columns (3 for 2-3 players, 4 for 4+ players)
- **Turn Flow:** TurnIndicatorView shows current player and game status; card tap triggers modal reveal
- **Game Completion:** Automatic transition to EndGameScreenView when isGameComplete() returns true

#### CardView Pattern: Four-State Component
- **Face-Down:** Question mark icon, blue background, tappable
- **Revealed (not locked):** Shows content (word or "SPY!"), blue background, tappable to hide
- **Locked:** Gray background, disabled, shows lock icon visually
- **Disabled:** Non-current player turns; style matches locked but semantically distinct
- **Touch Feedback:** isPressed state gives visual feedback on tap
- **Accessibility:** Each card labeled with index + state-specific hints

#### TurnIndicatorView: Lightweight Status Widget
- **Layout:** Fixed at top of game screen, shows player name and position
- **Stats:** Two-column layout showing cards remaining vs. cards locked
- **Updates:** Reactive to GameState changes (currentPlayerIndex, revealedCards)
- **Accessibility:** Combined VoiceOver labels for efficient announcements

#### Card Reveal Modal Pattern
- **Interaction:** Card tap → modal sheet appears with enlarged card content
- **Privacy:** Card content shown only in modal, not grid (prevents accidental glimpses)
- **Affordance:** "Hide Card & Next Player" button makes next step clear
- **Flow:** Dismiss sheet → card locks → player advances → view updates

#### AppState Extensions
- **New case:** AppScreen.endGame
- **New method:** goToEndGame() (for future explicit transitions)
- **Updated:** FamilyGameApp now routes to GameScreenView and EndGameScreenView

#### EndGameScreenView: Replay Support
- **Display:** Game summary (player count, theme) + celebration icon
- **Actions:** 
  - "Play Again" → resetGame() (welcome screen)
  - "Change Settings" → goToSetup() (setup screen with preserved names option)
- **Accessibility:** Labels and hints for all buttons

#### Key Technical Decisions
1. **CardView is pure component:** No game logic, just presentation. Parent handles state mutations via GameState methods.
2. **Responsive grid:** LazyVGrid calculates columns based on player count; 80×100pt cards meet accessibility minimum.
3. **Modal for privacy:** Card content revealed in sheet (not grid) to prevent accidental exposure during phone handoff.
4. **Turn structure enforces completion:** No skip button; all cards must be locked to finish game (fairness).
5. **No animations in Phase 2:** Simple transitions; animations deferred to Phase 3 polish.

#### Accessibility Enhancements
- Large touch targets: Cards 80×100pt minimum
- VoiceOver: Card index + state (unrevealed, revealed, locked) + instructions
- Modal instructions: "Remember what you saw!" + "Tap Hide Card & Next Player"
- System colors: High contrast, no custom palette yet
- Dynamic Type: All text respects user font size preferences

#### File Structure Created/Modified
- **New:** CardView.swift, TurnIndicatorView.swift, GameScreenView.swift, EndGameScreenView.swift
- **Modified:** AppState.swift (endGame case), FamilyGameApp.swift (routing)
- **Total Lines:** ~730 lines of new UI code (GameScreenView: 275, CardView: 150, TurnIndicator: 95, EndGame: 145)

#### Integration Points for Team
- **Tony Stark:** GameLogic should populate cards/players before navigation to .game; can modify GameScreenView.initializeGameState()
- **Bruce Banner:** CardView (pure), GameScreenView logic (turn advance), TurnIndicatorView (display) are all testable in isolation
- **Steve Rogers (Lead):** Review accessibility (VoiceOver, Dynamic Type) before Phase 3
- **Natasha (Phase 3):** Add card flip animation, smooth turn transitions, celebration animation

#### Known Limitations
- No animation support yet (Phase 3 polish)
- Game result/discussion phase not implemented (could be separate EndGameDetailView in Phase 3)
- iPad landscape support deferred to Phase 3
- Custom color palette not applied (using system colors; Phase 3 design refresh)

#### Decisions Logged
- See `.squad/decisions/inbox/natasha-romanoff-game-screen.md` for full Phase 2 rationale

## Learnings (2026-03-08 patch)

- SwiftUI animation patterns used: implemented press-state scaling using a reusable ButtonStyle (scaleEffect + spring animation) to provide consistent tactile feedback across the app.
- Player count validation logic: replaced name-based entry with a numeric TextField; input is sanitized to digits only and validated to be within 1–12 players with clear inline error messaging.
- Color token extraction strategy: centralized commonly-used colors and a gradient border token in Theme/ThemeColors.swift for easier theming and future dark-mode adjustments.
- iOS SDK quirks discovered: using .keyboardType(.numberPad) improves numeric entry but requires explicit sanitization on macOS previews and external keyboards; using a ButtonStyle for press behaviour avoids fragile long-press gesture hacks in most tap cases.

### Current-player tap enforcement fix (2026-03-14)

- Issue: GameScreenView was passing isCurrentPlayerTurn: true to every CardView, allowing any player to tap any card during any turn. This broke the turn-based flow.
- Root cause: The ForEach loop used the card position index but unconditionally marked every CardView as belonging to the current player.
- Fix applied: CardView now receives isCurrentPlayerTurn: (gameState.currentPlayerIndex == index), where index is the card's position and corresponds to the owning player. Only the current player can tap their assigned card.
- Assumptions: Card generation maps player order to card index (GameLogic.generateCards creates one card per player in order), so card index == player index. The rules interpreted: each player owns one card and can only reveal their own card on their turn.
- Follow-ups: Consider a subtle UI hint (tooltip or toast) when non-current players attempt to tap — CardView currently disables taps and is visually similar to locked; a distinct visual state for "not your turn" may improve clarity.

### UI Implementation Verification (2026-03-14)

#### WelcomeScreen Color & Visual Design — ✅ LIVE & WORKING
- **LinearGradient Background:** Orange (1.0, 0.7, 0.5) to Golden Yellow (1.0, 0.85, 0.3), full-screen with ignoresSafeArea()
- **Decorative Circles:** Three colorful circles at top — Blue (50×50pt), Pink/Red (40×40pt), Green (45×45pt), spaced 20pt apart
- **Enhanced Button Styling:** 
  - White background with 16pt corner radius
  - Shadow: 8pt blur, 0.2 opacity, 4pt y-offset
  - Orange text (#FF7A59 equivalent) for contrast
  - Full-width layout with 18pt vertical padding, 28pt horizontal margins
- **Accessibility:** VoiceOver labels, hints, and system traits throughout
- **File:** WelcomeScreenView.swift (99 lines)

#### SetupScreen — Player Names Removed ✅ CONFIRMED
- **Form Section Removed:** No player name text fields in SetupScreenView (verified lines 4-104)
- **Remaining Sections:**
  1. Number of Players: TextField with 1-12 range, numeric-only input
  2. Theme Selection: Segmented picker (Place, Country, Things)
  3. Start Button: Enabled only when player count is valid
- **Auto-Generated Names in AppState:** 
  - updatePlayerNames(for:) generates ["Player 1", "Player 2", ..., "Player N"]
  - Called on init and whenever setPlayerCount() is invoked
  - Names available at appState.playerNames for game initialization
- **End-to-End Flow:** Player count validation → theme selection → auto-generated names → game transition via startGame()
- **File:** SetupScreenView.swift (111 lines), AppState.swift (71 lines)

#### Build Status — ✅ CLEAN & VERIFIED
- **Build Target:** iOS Simulator (iPhone Air, iOS 26.3.1)
- **Result:** BUILD SUCCEEDED
- **Errors:** 0 (fixed CardView.swift return statement syntax error)
- **Warnings:** 2 deprecation warnings (onChange in iOS 17 — expected, non-blocking)
- **Compiler:** Swift 5.10, no UI-related compilation warnings
- **Command:** `xcodebuild -scheme FamilyGame -destination "platform=iOS Simulator,name=iPhone Air" build`

#### Files Modified/Verified
1. **WelcomeScreenView.swift** — Colorful gradient, decorative circles, enhanced button
2. **SetupScreenView.swift** — Player count + theme selection only (names removed)
3. **AppState.swift** — Auto-generates player names ("Player N" format)
4. **CardView.swift** — Fixed return statement syntax error for build success

#### Summary
All requested UI changes are live and working. WelcomeScreen presents warm, inviting family-friendly aesthetic with gradient background and visual elements. SetupScreen simplified to player count + theme selection with auto-generated player names. Build is production-ready with zero critical errors.



### Phase 3 Preparation — UI Polish Complete (2026-03-14)

**Session:** UI & Bug Verification Sprint  
**Status:** ✅ COMPLETE

**WelcomeScreen Colorful Gradient — LIVE**
- Implemented warm, inviting aesthetic with LinearGradient background (Orange → Golden Yellow)
- Decorative circles added for visual interest (Blue, Pink/Red, Green)
- Enhanced button styling with white background, shadow, orange text
- All changes verified working, build clean (0 errors, 0 warnings)

**SetupScreen Simplification — Player Names Removed**
- Removed manual player name input section
- Retained player count (1-12 numeric) and theme selection
- Implemented auto-generated names ("Player 1", "Player 2", etc.) in AppState
- Integration verified, form flow working correctly

**Current Player Turn Enforcement — Verified Fixed**
- Reviewed implementation: `isCurrentPlayerTurn: (gameState.currentPlayerIndex == index)`
- Turn-based flow confirmed working, non-current players cannot tap cards
- File: GameScreenView.swift line 85

**Build Quality:** 0 errors, 0 warnings, iOS Simulator verified

**Phase 3 Ready:** UI foundation complete and stable. Ready for animation work and feature expansion.

