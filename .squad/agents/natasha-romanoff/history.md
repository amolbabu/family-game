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
