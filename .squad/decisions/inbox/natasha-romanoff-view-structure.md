# Natasha Romanoff — View Structure Decisions

**Date:** 2026-03-06  
**Phase:** 1 — Launch & Setup  
**Status:** COMPLETED ✅

---

## Architecture Decisions

### 1. State Management: `@Observable` AppState
- **Choice:** Single `AppState` class using `@Observable` macro (iOS 17+)
- **Rationale:** Clean, reactive state without relying on third-party libraries. `@Observable` is modern SwiftUI and plays well with the environment.
- **Location:** `Models/AppState.swift`
- **Properties:**
  - `currentScreen: AppScreen` (enum for navigation: welcome → setup → game)
  - `playerCount: Int` (2–8, default 3)
  - `playerNames: [String]` (auto-synced with player count)
  - `selectedTheme: Theme` (enum: Place, Country, Things)

### 2. Screen Navigation via Enum
- **Choice:** `AppScreen` enum in AppState (not NavigationStack routing)
- **Rationale:** Clearer control for Phase 1. No deep linking yet. Single ZStack in FamilyGameApp switches views.
- **Future:** If deep-linking needed in Phase 3, can migrate to NavigationStack.

### 3. View Hierarchy
```
FamilyGameApp (main entry)
  ├── WelcomeScreenView
  │   └── "Start Game" button → sets currentScreen = .setup
  ├── SetupScreenView
  │   ├── Player count picker (2–8, default 3)
  │   ├── Player name text fields (auto-generate placeholders)
  │   ├── Theme segmented control (Place, Country, Things)
  │   └── "Start Game" button (disabled until all names filled)
  └── GameScreenPlaceholder (stub for Tony Stark's GameScreenView)
```

### 4. Form Validation
- **Choice:** Disable "Start Game" button if any player name is empty
- **Rationale:** User Story 2 & 3 require player count and theme selection. Names should not be skipped (personalization matters).
- **Implementation:** `isFormValid` computed property checks `playerNames.allSatisfy { !$0.isEmpty }`

### 5. Accessibility (VoiceOver, Dynamic Type)
- All buttons: `.accessibilityLabel()` + `.accessibilityHint()`
- Pickers & text fields: `.accessibilityLabel()` + `.accessibilityValue()`
- High contrast: System colors used (no custom color definitions yet; can be added in Phase 3)
- Large text support: Font sizes use `.font(.system(...))` which respect Dynamic Type

### 6. Portrait-Only Orientation
- **Implementation:** Info.plist restricts `UISupportedInterfaceOrientations` to `UIInterfaceOrientationPortrait`
- **Rationale:** Matches Steve Rogers' decision (iPad support deferred to Phase 3)
- **Testing:** Verified structure for iPhone 14+

---

## Component Design Patterns

### WelcomeScreenView
- Simple, centered layout with VStack
- Uses SF Symbols (`person.3.fill`) for family icon (placeholder; real artwork TBD)
- Clear call-to-action button in system blue (high contrast)

### SetupScreenView
- Form-based layout (familiar iOS pattern)
- Section headers with icons for clarity
- Segmented picker for player count (limited options, visual grouping)
- Text fields for player names (standard iOS input)
- Segmented control for themes (3 options → segmented is ideal)
- "Start Game" button styled with conditional background color:
  - Green when form is valid
  - Gray when form is incomplete

---

## Testing Assumptions (for Bruce Banner)
1. **No animations yet** — all views are static (Phase 3: Polish)
2. **No game logic** — views manage only UI state, not card generation
3. **Navigation is simple** — mock GameScreenPlaceholder included for reference
4. **Testable structure** — each view is independent, minimal dependencies

---

## Integration Points

### For Tony Stark (Backend/GameState):
- `AppState.startGame()` sets `currentScreen = .game`
- By that time, `appState.playerNames`, `appState.playerCount`, `appState.selectedTheme` are finalized
- Tony can inject his GameState model alongside AppState or as a child

### For Bruce Banner (QA):
- Can write snapshot tests for each view
- Can test AppState state transitions
- Can mock player counts & names for validation tests

---

## Known Limitations & Phase 3 Roadmap

| Feature | Phase 1 | Phase 2 | Phase 3 |
|---------|---------|---------|---------|
| Welcome screen | ✅ | — | Polish (animation) |
| Setup screens | ✅ | — | Polish (animation) |
| Accessibility | ✅ (basic) | — | Enhanced (audio cues) |
| iPad support | — | — | ✅ |
| Custom colors | — | — | ✅ |
| Animations | — | — | ✅ |
| End-game screen | — | Game flow | Polish |

---

## File Locations

- **App entry:** `/ios/FamilyGame/FamilyGame/App/FamilyGameApp.swift`
- **State model:** `/ios/FamilyGame/FamilyGame/Models/AppState.swift`
- **Views:** `/ios/FamilyGame/FamilyGame/Views/WelcomeScreenView.swift`, `SetupScreenView.swift`
- **Config:** `/ios/FamilyGame/FamilyGame/Info.plist`

---

## Next Steps (for team)
1. **Tony Stark:** Create Xcode project file (FamilyGame.xcodeproj) from this structure
2. **Bruce Banner:** Write unit tests for AppState transitions
3. **Natasha (Phase 2):** Implement GameScreenView once Tony's GameState model is ready
4. **Steve Rogers (Lead):** Schedule accessibility review before Phase 2
