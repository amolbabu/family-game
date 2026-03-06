# Natasha Romanoff — Phase 2 GameScreen Implementation

**Date:** 2026-03-07  
**Phase:** 2 — Core Game Screen (Turn-based card reveal)  
**Status:** COMPLETED ✅

---

## Executive Summary

✅ **GameScreenView** — Main game screen with turn-based card reveal  
✅ **CardView** — Reusable card component with multiple states  
✅ **TurnIndicatorView** — Player turn and game status display  
✅ **EndGameScreenView** — End-game screen with replay options  
✅ **AppState integration** — Navigation to/from game screens  
✅ **FamilyGameApp routing** — Updated to use GameScreenView

---

## Architecture Decisions

### 1. Card State Machine: Four-State CardView Component

**Decision:** CardView handles visual representation of four card states:
- **Face-down** (unrevealed, unlocked): Show "?" icon, tap to reveal
- **Revealed** (unrevealed → revealed): Show card content (word or "SPY!"), allow tap to hide
- **Locked** (after hide): Gray out, disable tapping, show lock icon
- **Disabled** (not current player's turn): Show disabled state styling

**Rationale:**
- Separates visual state from game logic state
- CardView is a pure presentation component (no side effects)
- Parent (GameScreenView) handles state mutations via GameState
- Makes testing easier (can test card appearance in isolation)

**Card Visual Properties:**
```swift
// Input: Card model (from GameState)
struct Card {
    let id: UUID
    let content: CardContent      // .word(String) or .spy
    var isRevealed: Bool          // Currently showing content
    var isLocked: Bool            // Permanently locked (no taps allowed)
}

// CardView computes styling based on these properties:
// - isLocked: gray background, disabled state
// - isRevealed && !isLocked: blue background, content visible
// - !isRevealed && !isLocked: blue background, "?" icon visible
```

### 2. Responsive Grid Layout Based on Player Count

**Decision:** Use `LazyVGrid` with adaptive column counts:
- 2-3 players: 3 columns (larger cards)
- 4-5 players: 4 columns (medium cards)
- 6-8 players: 4 columns (smaller cards)

**Rationale:**
- Card aspect ratio 80×100pt minimum (accessibility: large touch targets)
- Scales naturally as player count increases
- Portrait orientation: fits well within iPhone widths
- No external libraries; pure SwiftUI Grid

**Code:**
```swift
func calculateColumnCount() -> Int {
    let playerCount = gameState.players.count
    switch playerCount {
    case 2, 3: return 3
    case 4, 5, 6, 7, 8: return 4
    default: return 3
    }
}
```

### 3. Turn Indicator: Lightweight Status Display

**Decision:** TurnIndicatorView shows:
- Current player name + "Your turn" label
- Player position (e.g., "Player 1 of 3")
- Cards remaining (count of non-locked cards)
- Cards locked (count of locked cards)

**Rationale:**
- Placed at top of screen (sticky, always visible)
- Small, non-intrusive (doesn't consume game grid space)
- Two stat boxes (remaining vs. locked) give quick game overview
- Accessibility labels for VoiceOver

### 4. Modal Sheet for Card Reveal

**Decision:** When player taps a card:
1. Card state changes to `isRevealed = true` (shows content in grid)
2. A `.sheet()` modal appears showing the card enlarged
3. Player reads the card content
4. Player taps "Hide Card & Next Player" to dismiss sheet
5. Card state changes to `isLocked = true`, turn advances to next player

**Rationale:**
- Prevents accidental glimpses during handoff
- Card content is private (shown in dedicated modal, not the grid)
- Clear affordance: "Hide Card & Next Player" button makes next step obvious
- Sheet can be enhanced later with animations/delays (Phase 3)

**Code Flow:**
```swift
// In GameScreenView:
// 1. Tap card → handleCardTap(index)
// 2. Card reveals (isRevealed = true) + sheet shows
// 3. Dismiss sheet → handleCardLock()
// 4. Card locks (isLocked = true) + player advances
```

### 5. Game Completion Detection: isGameComplete() Method

**Decision:** GameScreenView monitors `gameState.isGameComplete()`:
- Returns `true` when `revealedCards.count == cards.count`
- When `true`, view switches to EndGameScreenView automatically
- No manual button to skip; turn structure enforces completion

**Rationale:**
- Simplifies logic: no end-game button to manage
- Ensures all players see their card (gameplay fairness)
- GameState already tracks `revealedCards` set

### 6. End-Game Screen: Replay & Settings Options

**Decision:** EndGameScreenView shows:
- "All Cards Revealed!" celebration icon
- Game summary (player count, theme)
- Two action buttons:
  - "Play Again" → resets to welcome screen (`appState.resetGame()`)
  - "Change Settings" → goes to setup screen (`appState.goToSetup()`)

**Rationale:**
- Honors PRD Story 16 (replay support)
- Allows quick rematch or new game with different settings
- Clear visual closure (green checkmark, centered layout)

### 7. AppState Extensions: EndGame Navigation

**Decision:** Added `goToEndGame()` method and `.endGame` case to `AppScreen` enum

**Future:** Currently EndGameScreenView is triggered by GameScreenView's condition check. When Tony's GameLogic is fully integrated, could also call `appState.goToEndGame()` explicitly.

---

## Data Flow: Turn-Based Card Reveal

```
Player taps card (CardView tap handler)
  ↓
GameScreenView.handleCardTap(index)
  ├─ Call GameState.selectCard(at: index, byPlayer: currentPlayerIndex)
  ├─ Set selectedCardIndex = index
  ├─ Show modal sheet (showRevealedCard = true)
  └─ Card.isRevealed = true
  ↓
Player reads card in modal sheet
Player taps "Hide Card & Next Player"
  ↓
GameScreenView.handleCardLock()
  ├─ Call GameState.lockCard(at: index)
  ├─ Call GameState.nextPlayer()
  ├─ Dismiss modal sheet
  └─ Card.isLocked = true, currentPlayerIndex advances
  ↓
View refreshes (updated GameState triggers re-render)
  ├─ Card grid shows locked card in gray
  ├─ TurnIndicatorView shows new current player
  └─ If isGameComplete() → switch to EndGameScreenView
```

---

## Component Architecture

### GameScreenView (Main Container)
- **Inputs:** AppState (via @Environment)
- **Local State:** GameState, selectedCardIndex, showRevealedCard
- **Outputs:** Navigation to EndGameScreenView when game complete
- **Children:** TurnIndicatorView, CardView (grid), CardRevealSheet

### CardView (Reusable Card)
- **Inputs:** Card model, cardIndex, isCurrentPlayerTurn, onTap callback
- **State:** isPressed (for tap feedback)
- **Logic:** Enable/disable based on isLocked and isCurrentPlayerTurn
- **Accessibility:** Card description, state hints

### TurnIndicatorView (Status Display)
- **Inputs:** currentPlayer, playerIndex, totalPlayers, cardsRemaining, lockedCardCount
- **Pure presentation** (no state, no callbacks)
- **Accessibility:** Combined labels for player turn and game status

### CardRevealSheet (Modal)
- **Inputs:** Card, playerName, onDismiss callback
- **Display:** Large card with word or "SPY!"
- **Interaction:** "Hide Card & Next Player" button

### EndGameScreenView (Game Over)
- **Inputs:** totalPlayers, themeName
- **Access to AppState:** Via @Environment for navigation
- **Buttons:** "Play Again" → resetGame(), "Change Settings" → goToSetup()

---

## Styling & UX Decisions

### Colors
- **Card backgrounds:** System blue (.systemBlue) for playable, gray (.systemGray4) for locked
- **Card borders:** Blue with 50% opacity for visual softness
- **Turn indicator:** Light blue background (.systemBlue.opacity(0.1))
- **Game status box:** Light gray background (.systemGray6)

### Typography
- **Card labels:** 24pt bold rounded font
- **Turn header:** 18pt bold rounded font
- **Instruction text:** 16pt semibold rounded
- **Status numbers:** 14pt bold rounded
- All use `.font(.system(size:, weight:, design: .rounded))` for consistency with Welcome/Setup screens

### Spacing & Layout
- Card grid: 8pt spacing between cards
- View padding: 12-16pt standard margins
- Modal sheet: Standard iOS sheet with large size (detent)

### Accessibility Features
- **Large touch targets:** Cards are 80×100pt minimum
- **VoiceOver labels:** "Card 1", "Card 2", etc. + state hints
- **High contrast:** System colors with no low-opacity text
- **Font support:** Dynamic Type via system font design
- **Modal hints:** Clear instructions for hiding cards ("Remember what you saw!")

---

## Integration Points

### With Tony Stark's GameLogic:
Currently, GameScreenView initializes an empty GameState. When GameLogic is fully integrated:

1. **Before navigation to .game:**
   - AppState.startGame() should trigger GameLogic.generateCards()
   - AppState.startGame() should trigger GameLogic.createPlayers()
   - Populate GameState with cards and players before showing GameScreenView

2. **Alternative approach (deferred to Phase 3):**
   - GameScreenView can call GameLogic on onAppear if cards are empty
   - This requires GameLogic to be @Observable or reactive

3. **Suggested refactor:**
   - Create a GameViewModel that bridges AppState ↔ GameState ↔ GameLogic
   - Initialize GameViewModel with AppState data
   - GameScreenView reads from GameViewModel

### With Bruce Banner's Tests:
- CardView is a pure component (easy snapshot tests)
- GameScreenView has testable turn logic (nextPlayer, isGameComplete)
- TurnIndicatorView is view-only (snapshot tests)
- Can mock Card, Player, GameState for isolated testing

### With Steve Rogers' Architecture Review:
- No external dependencies maintained (SwiftUI-only)
- State management follows iOS 17+ @Observable pattern
- Navigation is simple (enum-based, not NavigationStack)
- Ready for code review and accessibility audit

---

## Known Limitations & Phase 3 Roadmap

| Feature | Phase 2 | Phase 3 (Future) |
|---------|---------|-----------------|
| Card reveal mechanics | ✅ | Card flip animation |
| Turn-based flow | ✅ | Smoother transitions |
| End-game detection | ✅ | Result screen (who was spy?) |
| Accessibility | ✅ (basic) | Audio cues, haptics |
| iPad support | — | ✅ Landscape layout |
| Custom color palette | — | ✅ Theme colors |
| Game discussion phase | — | ✅ Dedicated result UI |

---

## File Locations

**Created:**
- `Views/GameScreenView.swift` — Main game screen (436 lines)
- `Views/CardView.swift` — Reusable card component (154 lines)
- `Views/TurnIndicatorView.swift` — Turn/status display (96 lines)
- `Views/EndGameScreenView.swift` — End-game screen (144 lines)

**Modified:**
- `Models/AppState.swift` — Added .endGame case, goToEndGame() method
- `App/FamilyGameApp.swift` — Updated switch to use GameScreenView + EndGameScreenView

---

## Testing Checklist (for Bruce Banner)

- [ ] CardView renders correctly in all states (unrevealed, revealed, locked, disabled)
- [ ] Card tap triggers onTap callback (with correct cardIndex)
- [ ] TurnIndicatorView displays correct player name and player count
- [ ] Cards remaining counter updates after card lock
- [ ] Turn advances to next player after card lock
- [ ] Game completes when all cards are locked
- [ ] EndGameScreenView appears when isGameComplete() returns true
- [ ] "Play Again" button resets to welcome screen
- [ ] "Change Settings" button goes to setup screen
- [ ] Modal sheet shows card content correctly (word or "SPY!")
- [ ] Modal sheet hides after "Hide Card" button tap
- [ ] Card grid responsive layout for 2-8 players

---

## Next Steps

1. **Tony Stark:** Integrate GameLogic with GameScreenView
   - Generate cards before navigation to .game
   - Seed GameState with initial players and cards
   - (Optional) Handle coin flip/spy assignment logic

2. **Bruce Banner:** Write UI tests for card tap sequences and turn flow

3. **Natasha (Phase 3):** Add animations
   - Card flip animation
   - Smooth transitions between turns
   - Celebration animation when game completes

4. **Steve Rogers:** Review for accessibility compliance
   - VoiceOver testing
   - Dynamic Type testing on various font sizes
   - High contrast verification

---

## Summary

Phase 2 delivers a fully functional game screen with:
- Responsive card grid (2-8 players)
- Turn-based card reveal with modal privacy
- Game status tracking (remaining/locked cards)
- Automatic end-game detection
- Replay support via EndGameScreenView

The implementation is ready for GameLogic integration and follows SwiftUI best practices with no external dependencies.
