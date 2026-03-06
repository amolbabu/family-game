# Phase 2 Turn-Based Mechanics Decision — Tony Stark

**Date:** 2026-03-07  
**Author:** Tony Stark (Backend Developer)  
**Status:** Complete — Ready for UI Integration

---

## Problem Statement

Phase 1 provided data models and card generation. Phase 2 needs complete turn-based mechanics so:
- Natasha's UI can drive gameplay atomically
- Bruce's tests can verify all game rules and edge cases
- Players can reveal, hide, and lock cards without invalid states
- Game resets cleanly for replay with new spy position

---

## Key Decisions

### 1. Two-Level API for Card Taps

**Decision:** Provide both low-level and high-level methods

**Low-Level (for tests & advanced use):**
```swift
mutating func revealCard(at: Int) throws -> CardContent
mutating func hideCard(at: Int) throws
mutating func lockCard(at: Int) throws
```

**High-Level (for UI):**
```swift
mutating func performCardTap(at: Int, player: Int) -> TapResult
```

**Why:** 
- UI never throws exceptions; uses TapResult enum instead
- State transitions are atomic in performCardTap()
- Tests can directly call low-level methods for fine-grained control
- Clear separation: throwing methods = programmer error, TapResult = user action

---

### 2. TurnValidator Struct (Not Extension)

**Decision:** Extract validation as a separate struct, not GameState extension

```swift
struct TurnValidator {
    static func isValidCardIndex(_ index: Int, in count: Int) -> Bool
    static func canRevealCard(_ card: Card) -> Bool
    // ... other validators
}
```

**Why:**
- Pure functions (no state mutation) are easy to test
- Reusable logic without GameState dependency
- Future: easily wrap for Combine publishers or async/await
- Clear intent: "Is this action valid?" vs "Perform this action"

---

### 3. TapResult Enum for Non-Throwing Feedback

**Decision:** Use enum instead of throwing in performCardTap()

```swift
enum TapResult {
    case revealed(CardContent)
    case hidden
    case locked(message: String)
    case invalid(error: String)
}
```

**Why:**
- UI doesn't throw; it branches on result
- Rich context in each case (especially .locked and .invalid messages)
- SwiftUI-friendly: easier to bind to @State
- Distinguishes user actions (locked, invalid) from programmer errors (thrown exceptions)

---

### 4. Atomic Reset for Replay

**Decision:** Single resetGameState() method handles all reset needs

```swift
mutating func resetGameState() throws {
    selectedWord = try GameLogic.selectRandomWord(from: selectedTheme)
    cards = try GameLogic.generateCards(playerCount: ..., theme: ..., word: ...)
    currentPlayerIndex = 0
    revealedCards.removeAll()
    gamePhase = .inGame
    gameStartTime = Date()
}
```

**What's kept:**
- players (same team)
- selectedTheme (same theme)

**What's reset:**
- cards (new spy position, fresh states)
- selectedWord (new random word from theme)
- currentPlayerIndex (back to player 0)
- revealedCards (cleared)
- gamePhase (.inGame)
- gameStartTime (new start time)

**Why:**
- Single call = no partial states
- Keeps same players and theme (User Story 16)
- New spy position and word (variety for replay)
- Future: enables save/load without extra work

---

### 5. Codable GameState (Future-Proof)

**Decision:** Keep GameState conforming to Codable from Phase 1

**Enables:**
- Save to UserDefaults: `try? JSONEncoder().encode(gameState)`
- Save to file: `try gameState.write(to: ...)`
- Cloud sync: encode → send to server → decode
- Undo/redo: snapshot state before each action

**Not implemented in Phase 2 but no obstacles added**

---

## Extended Error Types

**Added to GameError enum:**

```swift
case cardAlreadyRevealed     // Tap unrevealed card when already revealed
case cardNotRevealed         // Try to lock/hide a card that's not revealed
case cardUnavailable         // Generic: card can't be acted upon
case invalidTheme            // resetGameState with empty theme
```

**Why:**
- More granular error handling in tests
- Clearer debugging (specific error = specific problem)
- Phase 1 methods still work: GameError.Equatable enables comparison

---

## Testing Strategy

**New test file: Phase2TurnsTests.swift (30+ tests)**

Coverage includes:
- revealCard: success, locked card, invalid index, already revealed
- hideCard: success, not revealed, invalid index
- lockCard: success, not revealed, invalid index
- performCardTap: all branches (revealed, hidden, locked, invalid)
- advanceToNextPlayer: single step, wrapping, multiple rounds
- checkGameComplete: all cards locked, partial, none, empty cards
- resetGameState: cards reset, players maintained, word changes, theme validation
- Integration: complete game flows with 2-8 players

**Edge cases tested:**
- Last card locked (game completion)
- Rapid taps (second tap hides)
- Player wrapping (last player → first)
- Invalid indices (negative, out of bounds)

---

## Integration Points for Natasha

**In GameScreenView:**

```swift
@State var gameState: GameState

let result = gameState.performCardTap(at: cardIndex, player: gameState.currentPlayerIndex)

switch result {
case .revealed(let content):
    // Animate card flip, show content
case .hidden:
    // Animate card flip back
case .locked(let msg):
    // Show error toast
case .invalid(let err):
    // Log, optionally show error
}
```

**Turn flow:**
```swift
gameState.advanceToNextPlayer()
gameState.lockCard(at: cardIndex)  // After player locks

if gameState.checkGameComplete() {
    appState.currentScreen = .endGame
}
```

**Replay:**
```swift
try gameState.resetGameState()
appState.currentScreen = .game
```

---

## No Breaking Changes

**Phase 1 methods still work:**
- `selectCard(at:byPlayer:)` → replaced by performCardTap, but available
- `nextPlayer()` → alias for advanceToNextPlayer()
- `isGameComplete()` → alias for checkGameComplete()
- `lockCard(at:)` → enhanced with better validation

**Backward compatible:** Bruce's existing tests in GameStateTests.swift and TurnFlowTests.swift still pass

---

## Performance Characteristics

| Method | Time | Space | Notes |
|--------|------|-------|-------|
| revealCard | O(1) | O(1) | Single array access + bool flip |
| hideCard | O(1) | O(1) | Single array access |
| lockCard | O(log n) | O(1) | Set insert for revealedCards |
| advanceToNextPlayer | O(1) | O(1) | Modulo arithmetic |
| checkGameComplete | O(n) | O(1) | Single pass through cards |
| performCardTap | O(log n) | O(1) | Validation + lockCard call |
| resetGameState | O(n) | O(n) | New card generation |

---

## Future Extensions (Already Structured For)

1. **Undo/Redo:**
   - Snapshot gameState before lock
   - Restore on undo request
   - Track revealedCards history

2. **Network Multiplayer:**
   - Encode gameState → send to server
   - Sync state on reconnect
   - No changes needed to current design

3. **Analytics:**
   - Hook TapResult enum
   - Track which cards tapped, timing, patterns
   - No state changes needed

4. **Custom Saves:**
   - GameState.Codable ready
   - Save before game, load on crash
   - No new methods needed

---

## Conclusion

Phase 2 provides a complete, testable, UI-friendly turn-based game engine. The two-level API (throwing vs. non-throwing) cleanly separates concerns. Atomic operations and clear error handling prevent invalid states. The design is extensible without refactoring.

**Ready for Natasha to build UI on top.**
**Ready for Bruce to write comprehensive integration tests.**
