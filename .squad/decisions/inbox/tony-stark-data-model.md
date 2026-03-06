# Tony Stark — Data Model Decisions

**Date:** 2026-03-06T23:51:00Z  
**Phase:** 1 — GameState Model + Theme Management + Card Logic  
**Status:** Implementation Complete

---

## Key Architecture Decisions

### 1. Model Design: Value Types (Structs) vs Reference Types (Classes)
**Decision:** Used `struct` for all game data models (Card, Player, GameState, Theme)  
**Rationale:**
- Value semantics ensure immutability and thread-safety by default
- Prevents accidental mutations from affecting shared references
- Easier to test and reason about state changes
- Swift best practice for data models
- Codable conformance is simpler

### 2. GameState Mutability Strategy
**Decision:** `GameState` is mutable struct with mutation methods rather than immutable with factory functions  
**Rationale:**
- UI frameworks (SwiftUI) expect mutability for state management
- Clearer intent: `gameState.nextPlayer()` vs. `let newGameState = gameState.withNextPlayer()`
- Integrates seamlessly with `@Observable` and `@State` in SwiftUI
- Matches player action patterns (select card → lock card → next player)

### 3. Card Content Enum with Associated Values
**Decision:** `CardContent` as enum with `.word(String)` and `.spy` cases  
**Rationale:**
- Type-safe way to represent mutually exclusive card states
- Prevents invalid states (card can't be both spy and word)
- Pattern matching in views is clear and exhaustive
- Custom Codable implementation handles JSON serialization

### 4. Randomization Approach
**Decision:** Use standard `Int.random(in:)` and `Array.randomElement()`  
**Rationale:**
- Built-in Swift APIs are sufficient for non-cryptographic randomization
- Game context doesn't require cryptographic strength
- Simple, readable, and performant
- Adequate randomness for casual game purposes
- If future needs arise, can switch to `SecureRandom` without API changes

### 5. Theme Management: Singleton Pattern
**Decision:** `ThemeManager` implemented as singleton with lazy loading  
**Rationale:**
- Themes are app-wide immutable resource
- Single source of truth prevents duplicate loads
- Private initializer ensures controlled instantiation
- Validation happens at load-time, not at each access
- Error reporting via `didLoadSuccessfully()` method

### 6. Validation Strategy
**Decision:** Fail early at Theme load-time; throw errors during gameplay for invalid inputs  
**Rationale:**
- Empty themes caught immediately (configuration error)
- Invalid card/player indices caught at interaction time
- Separates configuration errors from runtime errors
- Prevents silent failures in production

### 7. Player Role Assignment
**Decision:** Roles assigned during player creation via `GameLogic.createPlayers()`  
**Rationale:**
- Centralizes spy assignment logic
- Keeps AppState UI-focused, GameLogic focuses on mechanics
- Easy to test deterministically with seeding (future enhancement)
- Separates player setup from player UI (names can be UI-only initially)

---

## Data Flow Architecture

```
AppState (UI coordination)
  ├─ playerCount, playerNames, selectedTheme
  └─ triggers GameLogic

GameLogic (Pure functions)
  ├─ generateCards(playerCount, theme) → [Card]
  ├─ selectRandomWord(theme) → String
  └─ createPlayers(names) → [Player]

GameState (Game model)
  ├─ players: [Player]
  ├─ cards: [Card]
  ├─ currentPlayerIndex: Int
  └─ methods: selectCard(), lockCard(), nextPlayer(), isGameComplete()

ThemeManager (Resource loading)
  └─ themes.json → [Theme]
```

---

## Edge Cases & Error Handling

| Case | Handling |
|------|----------|
| Missing themes.json | `ThemeLoadError.fileNotFound` on app start |
| Empty theme word list | `ThemeLoadError.emptyTheme()` during load |
| Invalid card index selection | `GameError.invalidCardIndex` thrown |
| Locked card re-selection | `GameError.cardAlreadyLocked` thrown |
| Zero or negative players | `GameLogicError.invalidPlayerCount` thrown |
| Theme not found | `GameLogicError.themeNotFound()` thrown |

---

## Testability Considerations

1. **Pure Functions:** `generateCards()` and `selectRandomWord()` have no side effects
2. **Deterministic:** Given same input, card generation produces valid output (spy count, word distribution)
3. **Exhaustive:** All enum cases covered in pattern matching
4. **Error Types:** Custom error enums enable specific assertions in tests
5. **State Snapshots:** GameState can be serialized/deserialized for snapshot testing

---

## Integration Points

- **Natasha Romanoff (UI):**
  - AppState manages screen navigation
  - GameLogic integrates with SetupScreenView for player/theme selection
  - GameScreenView will read GameState for card display
  - ThemeManager provides theme list for picker

- **Bruce Banner (Testing):**
  - GameLogic functions are pure and easily testable
  - GameState mutations are observable
  - Error types enable specific failure testing

---

## Word Lists (Implemented)

Per steve-rogers-prd-decisions.md:

- **Place:** Paris, London, Tokyo, Cairo, Sydney, Rome, Dubai, Barcelona
- **Country:** France, Italy, Japan, Brazil, Australia, Canada, Spain, Thailand
- **Things:** Bicycle, Book, Camera, Clock, Elephant, Guitar, Hat, Lighthouse

All words are family-friendly and recognizable by children.

---

## Files Created

```
Models/
  ├─ Card.swift          (Card struct, CardContent enum)
  ├─ Player.swift        (Player struct, PlayerRole enum)
  └─ GameState.swift     (GameState struct, GamePhase enum, GameError)

Managers/
  └─ ThemeManager.swift  (Theme loading, validation, access)

Logic/
  └─ GameLogic.swift     (Card generation, word selection, player creation)

Resources/
  └─ themes.json         (Theme definitions with word lists)
```

---

## Outstanding Tasks (For Next Phase)

1. GameScreenView implementation (card grid UI, turn flow UI)
2. Integration with game flow (setup → game → end)
3. Save/Load system using Codable conformance
4. Performance optimization if needed for large card counts
5. iPad landscape support (Phase 3)
