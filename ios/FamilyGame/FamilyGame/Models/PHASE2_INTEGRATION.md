# Phase 2 Turn-Based Mechanics — Integration Guide for UI

## Overview

Phase 2 completes the turn-based game mechanics. The backend now provides all methods needed for Natasha's UI to interact with the game state atomically and safely.

## Core Methods for UI Integration

### 1. Card Reveal/Hide (User Stories 9-10)

**When player taps a card:**
```swift
let result = gameState.performCardTap(at: cardIndex, player: currentPlayerIndex)

switch result {
case .revealed(let content):
    // Animate card flip to show content
    // Display content (word or SPY!)
    
case .hidden:
    // Animate card flip back to face-down
    // User can now tap lock button or another card
    
case .locked(let message):
    // Show error message (optional: play error sound)
    // Card is already used, cannot tap
    
case .invalid(let error):
    // Log error for debugging
    // Show user-friendly message if needed
}
```

**Key Points:**
- `performCardTap` handles all state transitions atomically
- First tap reveals, second tap hides (if revealed)
- No need to call `revealCard`, `hideCard`, or `lockCard` separately for normal flow
- These lower-level methods exist for advanced use cases (direct control without tapping)

---

### 2. Lock Card (After Player Confirms)

**When player taps "Done" or "Lock" button after viewing:**
```swift
do {
    try gameState.lockCard(at: cardIndex)
    // Card is now permanently locked
    // Advance to next player
} catch {
    // Error unlikely in normal flow (already validated by tap)
    // Log: \(error)
}
```

---

### 3. Advance Turn (User Story 11)

**When current player finishes and passes to next player:**
```swift
gameState.advanceToNextPlayer()
// currentPlayerIndex is now updated to next player
// Show "It's Player X's turn" message
```

Or use the alias from Phase 1:
```swift
gameState.nextPlayer()  // Same as advanceToNextPlayer()
```

---

### 4. Check Game Completion (User Story 13)

**Periodically or after each card lock:**
```swift
if gameState.checkGameComplete() {
    // All cards are locked
    // Transition to EndGameScreenView
    appState.currentScreen = .endGame
} else {
    // Game continues
}
```

Or use Phase 1 alias:
```swift
if gameState.isGameComplete() { ... }
```

---

### 5. Reset for Replay (User Story 16)

**When player taps "Play Again":**
```swift
do {
    try gameState.resetGameState()
    // Game is ready to play again
    // New spy position, new word (same theme, same players)
    // All cards are unlocked and face-down
    appState.currentScreen = .game
} catch {
    // Error if theme is empty
    print("Reset failed: \(error)")
}
```

---

## Data Model Reference

### TapResult Enum

```swift
enum TapResult {
    case revealed(CardContent)      // Card successfully revealed
    case hidden                      // Card successfully hidden
    case locked(message: String)     // Card already locked
    case invalid(error: String)      // Invalid operation
}
```

### CardContent Enum

```swift
enum CardContent: Codable, Equatable {
    case word(String)   // Theme word (e.g., .word("Paris"))
    case spy            // The spy card
}
```

### Card Struct

```swift
struct Card: Identifiable, Codable {
    let id: UUID
    let content: CardContent
    var isRevealed: Bool   // Currently showing content
    var isLocked: Bool     // Permanently locked (cannot re-open)
}
```

### GameState Properties

```swift
struct GameState: Codable {
    var gamePhase: GamePhase              // .setup, .inGame, .endGame
    var players: [Player]
    var currentPlayerIndex: Int           // Index of current player
    var cards: [Card]
    var revealedCards: Set<Int>          // Indices of cards that have been viewed
    var selectedTheme: String
    var selectedWord: String
    var gameStartTime: Date?
}
```

---

## Turn Flow Example (Complete Game with 3 Players)

```
Initial State:
- gamePhase = .inGame
- currentPlayerIndex = 0 (Alice)
- All cards are face-down, unlocked

TURN 1: Alice taps card[0]
  -> performCardTap(0, 0) returns .revealed(.word("Paris"))
  -> Show card content
  -> Alice taps lock button
  -> gameState.lockCard(0) succeeds
  -> gameState.advanceToNextPlayer()  (now player 1)

TURN 2: Bob taps card[2]
  -> performCardTap(2, 1) returns .revealed(.spy)
  -> Show "SPY!" on card
  -> Bob taps lock button
  -> gameState.lockCard(2) succeeds
  -> gameState.advanceToNextPlayer()  (now player 2)

TURN 3: Charlie taps card[1]
  -> performCardTap(1, 2) returns .revealed(.word("Paris"))
  -> Show card content
  -> Charlie taps lock button
  -> gameState.lockCard(1) succeeds
  -> gameState.advanceToNextPlayer()  (now player 0)

After Turn 3:
  -> gameState.checkGameComplete() returns true
  -> All cards locked, game over
  -> Transition to EndGameScreen
```

---

## Error Handling

### Expected Errors (Normal Game Flow)

- **cardAlreadyLocked**: Player tapped a card that another player already locked
  - Message: "This card has already been used"
  - Action: Prevent tap (grayed out in UI)

- **invalidCardIndex**: Tap coordinate out of bounds
  - Message: "Invalid card selection"
  - Action: Ignore (shouldn't happen with proper UI grid)

- **invalidPlayerIndex**: Player index doesn't match current player
  - Message: "Not your turn"
  - Action: Prevent tap

### Advanced Methods (Lower-Level)

For special cases, these methods are available:

```swift
// Reveal a specific card (throwing version)
try gameState.revealCard(at: index) -> CardContent

// Hide a revealed card without locking
try gameState.hideCard(at: index)

// Lock a revealed card (alternative to performCardTap)
try gameState.lockCard(at: index)

// Check game completion
gameState.checkGameComplete() -> Bool
```

**When to use lower-level methods:**
- Custom UI animations or transitions
- Undo/redo logic
- Analytics tracking
- Debug/test scenarios

**When NOT to use:**
- Normal gameplay — use `performCardTap` instead

---

## Performance Notes

- All methods are O(n) or O(1) operations
- Safe to call multiple times per frame
- No threading concerns (value type with mutating methods)
- Card locking is atomic (no partial states)

---

## Future Extensions

The architecture supports:

1. **Save/Load**: GameState conforms to Codable
   - Save to UserDefaults or file
   - Recover mid-game if app crashes

2. **Undo/Redo**: Card state is trackable via `revealedCards`
   - Snapshot game state before lock
   - Restore if player requests undo

3. **Network Play**: Methods can be wrapped in RemoteGameState
   - Send state changes to other devices
   - Sync on reconnect

4. **Analytics**: Hook into TapResult enum
   - Track which cards are tapped
   - Time per turn
   - Win/loss patterns
