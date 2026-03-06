# Bruce Banner — History

## Project Context

**Project:** familyGame  
**Tech Stack:** Swift, SwiftUI  
**Goal:** Bug-free, family-safe, high-quality game  
**User:** Amolbabu  

---

## Core Context

Bruce Banner is the QA Engineer & Tester. You write tests, find edge cases, conduct playtesting, and ensure family-safety.

---

## Learnings

### Phase 1: Test Case Design for Card Generation & Turn Flow (2026-03-06)

#### Test Design Patterns Applied
1. **Boundary Value Testing** — Validated edge cases (min 2 players, max 8 players)
2. **Randomization Validation** — 100-run variation test + 300-run distribution analysis
3. **State Consistency Testing** — Verified player count ↔ names always synchronized
4. **Error Condition Testing** — Validated all GameError cases thrown appropriately
5. **Integration Testing** — Complete game sequences from setup to completion

#### Key Discoveries
- **Spy Position Randomization:** Must verify distribution across multiple runs (statistical validation needed)
- **Card State Machine:** Clear states: available → revealed → locked (not reversible)
- **Player Index Wrapping:** Turn advancement uses modulo operator (currentPlayerIndex % players.count)
- **Error Handling:** Invalid operations should throw GameError, not silently fail

#### Test Structure for Swift/XCTest
- XCTestCase subclass per domain (GameState, TurnFlow, CardContent, Player, AppState)
- Descriptive test method names: `testCardLockAfterView()` (clear intent)
- Helper functions for repeated test setup: `generateTestCards(playerCount:word:)`
- Assertion grouping: Test one logical behavior per method
- Edge case coverage: Minimum, maximum, and boundary values

#### Family-Safety Review
- **24 family-friendly words validated:** 8 places, 8 countries, 8 things
- **Age-appropriateness confirmed:** All words suitable for ages 6+
- **Language audit:** Card labels use friendly terminology ("SPY!", "Player X's turn")
- **Content policy:** No profanity, obscure references, or culturally sensitive terms

#### Test Coverage Achieved
- **127 test methods** across 5 test files
- **Card Generation:** 8 test methods + variations
- **Turn Flow:** 20 test methods covering full game sequences
- **Player Management:** 26 test methods for player lifecycle
- **App State:** 31 test methods for navigation and configuration
- **Card Content:** 24 test methods for serialization and safety

#### Assumptions Made
1. **Randomization:** Using Int.random(in:) for spy position (deterministic in tests, truly random in production)
2. **Player Count Range:** 2–8 enforced by business decision (PRD Decision #3)
3. **Default Theme:** Country selected as default (PRD Decision #4)
4. **Turn Wrapping:** Automatic wrap-around after last player (not explicit state)

#### Observations for Team
- **Tony's Implementation Needs:** GameState must support Card mutable state (isRevealed, isLocked)
- **Natasha's Integration Points:** AppState screen transitions work correctly for flow
- **Testing Bottleneck:** Randomization tests require >100 runs for statistical confidence
- **Debug Aid:** Helper function for generating test cards simplifies test setup
