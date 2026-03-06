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
