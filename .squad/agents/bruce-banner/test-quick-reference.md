# FamilyGame Test Suite — Quick Reference Guide

## Test Files Location

```
/Users/amolbabu/projects/familyGame/ios/FamilyGame/FamilyGameTests/
├── GameStateTests.swift      (26 tests)
├── TurnFlowTests.swift       (20 tests)
├── CardContentTests.swift    (24 tests)
├── PlayerTests.swift         (26 tests)
└── AppStateTests.swift       (31 tests)
```

## Quick Run Commands

### Run All Tests
```bash
cd /Users/amolbabu/projects/familyGame
xcodebuild test -scheme FamilyGame
```

### Run Specific Test Suite
```bash
xcodebuild test -scheme FamilyGame -only GameStateTests
xcodebuild test -scheme FamilyGame -only TurnFlowTests
xcodebuild test -scheme FamilyGame -only CardContentTests
xcodebuild test -scheme FamilyGame -only PlayerTests
xcodebuild test -scheme FamilyGame -only AppStateTests
```

### Run Single Test
```bash
xcodebuild test -scheme FamilyGame -only GameStateTests/testCorrectCardCountForThreePlayers
```

## Test Coverage by User Story

| User Story | Tests | File |
|-----------|-------|------|
| **US 6**: Card generation (N cards, exactly 1 spy) | 8 | GameStateTests |
| **US 7**: Random word selection | Covered in card tests | GameStateTests |
| **US 9**: Card reveal | 3 | GameStateTests, TurnFlowTests |
| **US 10**: Card lock after view | 3 | GameStateTests, TurnFlowTests |
| **US 11**: Next player, turn wrapping, game complete | 8 | GameStateTests, TurnFlowTests |

## Test Statistics

- **Total Tests:** 127
- **Total Test Methods:** 127
- **Average Tests per File:** 25
- **Edge Cases:** 10+
- **Error Scenarios:** 10+
- **Integration Tests:** 4

## Family-Safety Checklist

✅ 24 words tested (8 places, 8 countries, 8 things)  
✅ Age-appropriate for 6+ years  
✅ No profanity or offensive content  
✅ UI language friendly ("SPY!", "Player X's turn")  

## Key Test Patterns

### 1. Card Generation (8 tests)
- Correct count for 2-8 players
- Exactly 1 spy per game
- All non-spy cards show same word
- Random spy position (varies)
- Edge cases: 2 players, 8 players

### 2. Turn Flow (20 tests)
- Player turn advancement
- Turn wrapping to first player
- Card locking persistence
- Multiple cards locked simultaneously
- Complete game sequences (2, 3, 4, 8 players)

### 3. Card Content (24 tests)
- CardContent type equality
- JSON serialization roundtrip
- Family-safe word validation
- Word length constraints
- State transitions (revealed → locked)

### 4. Player Management (26 tests)
- Player initialization with roles
- Player ID uniqueness
- Player name updates
- Role assignment (normal, spy)
- Game integration

### 5. App State (31 tests)
- Screen navigation (welcome → setup → game)
- Player count management (2-8)
- Player name updates
- Theme selection (place, country, things)
- State consistency

## Debugging Tips

### If Tests Fail:

1. **Check Implementation:** Verify models match test expectations
2. **Read Error Message:** XCTest provides clear failure descriptions
3. **Run Single Test:** Isolate failing test for debugging
4. **Check Assertions:** Verify test logic is correct
5. **Review Changelog:** Tests may catch recent regressions

### Common Issues:

| Issue | Solution |
|-------|----------|
| Test file not found | Ensure FamilyGameTests target exists in Xcode |
| Import failure | Verify `@testable import FamilyGame` at file top |
| Card generation fails | Check Card(content:) initializer signature |
| Player creation fails | Ensure Player(name:) initializer works |
| Randomization fails | Run test multiple times (probabilistic test) |

## Test Execution Order

1. **AppStateTests** — Foundation (initialization, navigation)
2. **PlayerTests** — Player model (used by GameState)
3. **CardContentTests** — Card model (used by GameState)
4. **GameStateTests** — Core game logic
5. **TurnFlowTests** — Complete game sequences

## Integration Checkpoint

Before merging to main:
```bash
# Run all tests
xcodebuild test -scheme FamilyGame

# Check results:
# - 127 tests passed ✓
# - 0 tests failed ✓
# - Randomization distribution within 20-43% per position ✓
```

## Future Test Additions (Phase 2)

- [ ] themes.json loading tests
- [ ] Game history persistence tests
- [ ] End-game voting/reveal tests
- [ ] Performance benchmarks

## Test Dependencies

### Required Models (Tony Stark)
- GameState with selectCard(), lockCard(), nextPlayer(), isGameComplete()
- Card with isRevealed, isLocked properties
- Player with role and name
- GameError enum

### Required State (AppState via Natasha Romanoff)
- Screen navigation (welcome, setup, game)
- Player count and name management
- Theme selection

## Document Info

- **Created:** 2026-03-06
- **Author:** Bruce Banner (QA)
- **Status:** Ready for Integration
- **Last Updated:** 2026-03-06

