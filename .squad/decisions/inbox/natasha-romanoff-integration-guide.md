# Phase 1 Integration Guide: Views → Game State

**Date:** 2026-03-06  
**Prepared by:** Natasha Romanoff  
**For:** Tony Stark, Bruce Banner, Steve Rogers  

---

## Executive Summary

✅ **Views Layer Complete**
- WelcomeScreenView: Welcome screen with CTA
- SetupScreenView: Player count, names, theme selection
- AppState: Navigation & setup state management
- Info.plist: Portrait-only, light mode

✅ **Tony Stark's Game Logic Ready**
- GameState: Game phase tracking, card/player management
- GameLogic: Card generation, random word selection, player creation
- ThemeManager: Loads themes.json, validates themes
- themes.json: Place, Country, Things with curated words

---

## Navigation Flow (Implemented)

```
1. App Launch
   ↓
2. WelcomeScreenView (AppState.currentScreen == .welcome)
   - Shows "Family Game" banner
   - "Start Game" button → AppState.goToSetup()
   ↓
3. SetupScreenView (AppState.currentScreen == .setup)
   - Section 1: Player count picker (2–8, default 3)
   - Section 2: Player name text fields (auto-generated placeholders)
   - Section 3: Theme segmented control (Place, Country, Things)
   - "Start Game" button → AppState.startGame()
   ↓
4. GameScreenPlaceholder (AppState.currentScreen == .game)
   - Ready for Tony Stark's GameScreenView
   - Displays current player names + selected theme
```

---

## Data Flow: Views → Game Logic

### Step 1: User fills SetupScreenView
```swift
// AppState (Natasha's view state)
appState.playerCount = 4          // User selects 4 players
appState.playerNames = ["Alice", "Bob", "Carol", "Dave"]  // User enters names
appState.selectedTheme = .country // User selects theme
```

### Step 2: User taps "Start Game"
```swift
// AppState.startGame() → currentScreen = .game
```

### Step 3: Tony's GameScreenView will:
```swift
// Tony's code (not yet written):
// 1. Create GameState from AppState
var gameState = GameState()

// 2. Use GameLogic to generate players
let players = try GameLogic.createPlayers(from: appState.playerNames)
gameState.players = players

// 3. Use GameLogic to generate cards
let cards = try GameLogic.generateCards(
    playerCount: appState.playerCount,
    theme: appState.selectedTheme.rawValue
)
gameState.cards = cards
gameState.selectedTheme = appState.selectedTheme.rawValue
gameState.gamePhase = .inGame
```

---

## File Locations & Responsibility Matrix

| File | Purpose | Owner | Status |
|------|---------|-------|--------|
| `App/FamilyGameApp.swift` | App entry, screen routing | Natasha | ✅ Done |
| `Models/AppState.swift` | View-level state (nav, setup inputs) | Natasha | ✅ Done |
| `Views/WelcomeScreenView.swift` | Welcome screen UI | Natasha | ✅ Done |
| `Views/SetupScreenView.swift` | Setup form UI | Natasha | ✅ Done |
| `Models/GameState.swift` | Game-level state (cards, players, phases) | Tony | ✅ Done |
| `Models/Card.swift` | Card model (content, reveal state) | Tony | ✅ Done |
| `Models/Player.swift` | Player model (name, role) | Tony | ✅ Done |
| `Logic/GameLogic.swift` | Card generation, word selection, player creation | Tony | ✅ Done |
| `Managers/ThemeManager.swift` | Theme loading, word access | Tony | ✅ Done |
| `Resources/themes.json` | Themes & words | Tony | ✅ Done |
| `Info.plist` | App configuration (portrait-only, light mode) | Natasha | ✅ Done |

---

## Integration Checklist for Tony Stark

When building GameScreenView, ensure:

- [ ] Import `AppState` from Models
- [ ] Receive `@Environment(AppState.self) var appState` in GameScreenView
- [ ] Call `GameLogic.createPlayers(from: appState.playerNames)` to create Player objects
- [ ] Call `GameLogic.generateCards(playerCount: appState.playerCount, theme: appState.selectedTheme.rawValue)` to generate cards
- [ ] Initialize `GameState` and populate it with the generated players and cards
- [ ] Handle game phases: `.inGame` while cards are being revealed, `.endGame` when complete
- [ ] Implement card reveal/lock logic using `GameState.selectCard()` and `GameState.lockCard()`
- [ ] Track `gameState.currentPlayerIndex` for turn management
- [ ] Check `gameState.isGameComplete()` to determine when to show end-game screen

---

## Accessibility Features (Already Implemented)

✅ VoiceOver labels on all buttons, pickers, text fields  
✅ Accessibility hints for form validation ("Fill in all names to continue")  
✅ Dynamic Type support via `.font(.system(...))` sizing  
✅ High contrast system colors (no custom palettes yet)  
✅ Portrait-only orientation (simpler layout for families)

---

## Testing Strategy (for Bruce Banner)

### View Tests (snapshot/XCTest)
```swift
// Test WelcomeScreenView appearance
// Test SetupScreenView form validation
// Test navigation state transitions in AppState
```

### Integration Tests
```swift
// Test AppState → GameLogic data flow
// Test GameLogic.createPlayers() with names from AppState
// Test GameLogic.generateCards() with theme from AppState
```

### GameState Tests (already started by Tony)
```swift
// Test card selection and locking
// Test player rotation
// Test game completion detection
```

---

## Known Constraints & Future Work

| Feature | Phase 1 | Phase 2 | Phase 3 |
|---------|---------|---------|---------|
| Welcome screen | ✅ | — | Animations |
| Setup form | ✅ | — | Animations |
| Game screen | — | Implement | Polish |
| Accessibility | ✅ (basic) | Enhanced | Audio cues |
| iPad support | — | — | ✅ |
| Custom colors | — | — | ✅ |
| Theme animations | — | — | ✅ |

---

## Next Immediate Steps

1. **Tony Stark:** Build GameScreenView using the GameState models
   - Integrate AppState from Views layer
   - Use GameLogic to populate GameState on entry
   - Implement card reveal/lock UI

2. **Bruce Banner:** Write unit tests for:
   - AppState state transitions
   - GameLogic (using existing themes.json)
   - GameState (player management, card locking)

3. **Natasha:** Await GameScreenView to finalize navigation & test end-to-end flow

4. **Steve Rogers (Lead):** Review completed Phase 1 views for accessibility compliance

---

## Quick Reference: AppState API

```swift
// Navigation
appState.goToSetup()           // welcome → setup
appState.startGame()           // setup → game
appState.resetGame()           // any → welcome (reset all state)

// Player management
appState.setPlayerCount(4)     // updates playerNames array automatically
appState.updatePlayerName(0, to: "Alice")  // safe index check included

// Data access (read in GameScreenView)
appState.playerCount      // Int (2–8)
appState.playerNames      // [String]
appState.selectedTheme    // Theme enum (.place, .country, .things)
appState.currentScreen    // AppScreen enum (for navigation)
```

---

## Communication Plan

- **Standup:** Report view completion, confirm GameLogic integration readiness
- **Issues:** Use GitHub for dependency tracking (AppState ready → Tony can start GameScreenView)
- **Code Review:** Natasha will review GameScreenView for view patterns consistency

---

**Status:** ✅ Phase 1 Views COMPLETE — Ready for GameScreenView integration
