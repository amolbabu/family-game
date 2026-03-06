# FamilyGame Unit Tests — Comprehensive Test Suite

## Overview

This document provides a comprehensive overview of the unit tests written for the FamilyGame project. The test suite covers card generation, randomization, turn mechanics, player management, and app state handling.

**Test Framework:** XCTest (Swift)  
**Total Test Files:** 5  
**Total Test Cases:** 80+

---

## Test Files and Coverage

### 1. GameStateTests.swift

**Purpose:** Core game mechanics including card generation, randomization, and game state management.

**Test Coverage:**

#### Card Generation Tests (User Stories 6 & 7)
- ✅ **Correct Card Count** — Validates that N players generate N cards
- ✅ **Exactly One Spy** — Ensures exactly 1 spy card per game
- ✅ **All Non-Spy Cards Show Same Word** — Validates consistency of shared word
- ✅ **Random Spy Position** — Tests spy position varies across 100 games
- ✅ **Spy Position Distribution** — Statistical validation of randomization across 300 games
- ✅ **Edge Case: Minimum Players (2)** — Tests 2-player game setup
- ✅ **Edge Case: Maximum Players (8)** — Tests 8-player game setup
- ✅ **Player Count Range (2-8)** — Tests all valid player counts

#### Card State Tests (User Stories 9-10)
- ✅ **Card Reveal** — Tests card becomes revealed when selected
- ✅ **Card Lock After View** — Tests card hides and locks after viewing
- ✅ **Cannot Reopen Locked Card** — Tests error thrown when accessing locked card

#### Turn Flow Tests (User Stories 9-11)
- ✅ **Next Player Advances** — Player index increments correctly
- ✅ **Turn Wraps Around** — Turn loops back to Player 1 after last player
- ✅ **Turn Wrapping for Various Player Counts** — Tests wrap for all valid counts
- ✅ **Game Complete Detection** — All cards locked = game complete
- ✅ **Game Not Complete Early** — Game not complete with locked cards remaining
- ✅ **Game Completion Progress** — Tests progressive completion

#### Error Handling Tests
- ✅ **Invalid Card Index** — Throws error for out-of-range index
- ✅ **Negative Card Index** — Throws error for negative index
- ✅ **Invalid Player Index** — Throws error for invalid player reference

**Test Count:** 26 test methods

---

### 2. TurnFlowTests.swift

**Purpose:** Complete turn-based gameplay sequences and player interactions.

**Test Coverage:**

#### Turn Progression Tests
- ✅ **Complete Reveal and Lock Sequence** — Full single turn lifecycle
- ✅ **Cannot Select Same Card Twice** — Player can't reselect their card
- ✅ **Turn Progression Through All Players** — Sequential player turns
- ✅ **Multi-Round Turn Progression** — Tests across multiple game rounds

#### Card Locking and Persistence
- ✅ **Locked Cards Persist Across Turns** — Cards stay locked across turns
- ✅ **Multiple Cards Locked Simultaneously** — Multiple players' cards locked
- ✅ **Game State Transition (Partial → Complete)** — Progressive game completion

#### Card Content Preservation
- ✅ **Card Content Preserved Through Cycle** — Content unchanged after reveal/lock
- ✅ **Spy Card Content Preserved** — Spy designation preserved through cycle

#### Edge Cases
- ✅ **Minimum Player (2) Turn Flow** — Tests 2-player turn mechanics
- ✅ **Maximum Player (8) Turn Flow** — Tests 8-player turn mechanics
- ✅ **All Cards Lockable in Large Game** — Complete 8-player game

#### Card Availability
- ✅ **All Cards Start Available** — No cards locked initially
- ✅ **Available Card Count Decreases** — Count decreases as cards lock

#### Sequence Verification
- ✅ **Complete Game Sequence** — Full 3-player game from start to end
- ✅ **All Revealed Cards Tracked** — revealedCards set accurate

**Test Count:** 20 test methods

---

### 3. CardContentTests.swift

**Purpose:** Card model functionality, serialization, and content validation.

**Test Coverage:**

#### Card Content Type Tests
- ✅ **CardContent.word Equality** — Word content comparison
- ✅ **CardContent.spy Equality** — Spy content comparison
- ✅ **Word vs Spy Inequality** — Different content types not equal

#### Card Content Serialization
- ✅ **Word Content Encoding/Decoding** — JSON roundtrip for words
- ✅ **Spy Content Encoding/Decoding** — JSON roundtrip for spy
- ✅ **Multiple Contents Coding** — Array of mixed content
- ✅ **Different Words Encode Differently** — Content distinction preserved

#### Card Structure Tests
- ✅ **Card Default Initialization** — Default values set correctly
- ✅ **Card Explicit Initialization** — All parameters honored
- ✅ **Card ID Uniqueness** — Each card gets unique UUID
- ✅ **Card with Custom UUID** — Custom ID assignment
- ✅ **Card Identifiable Protocol** — Supports Identifiable

#### Card Serialization
- ✅ **Card Encoding/Decoding** — Full card JSON roundtrip
- ✅ **Spy Card Coding** — Spy card serialization
- ✅ **Card Array Coding** — Array of mixed cards
- ✅ **Complete Card State Preservation** — All fields preserved

#### Card State Transitions
- ✅ **Card State Transitions** — revealed/locked state changes
- ✅ **Locked Card Behavior** — Locked state prevents reveal

#### Family-Safety Content Tests
- ✅ **Family-Friendly Words Accepted** — 24 approved words validated
- ✅ **Word Length Constraints** — Reasonable word length
- ✅ **Spy Card Always Valid** — Spy content always valid

#### Codable Edge Cases
- ✅ **Invalid Content Type Decoding** — Error on unknown type
- ✅ **Exact Value Preservation** — Words preserved exactly in encoding

**Test Count:** 24 test methods

---

### 4. PlayerTests.swift

**Purpose:** Player model management and gameplay integration.

**Test Coverage:**

#### Player Initialization
- ✅ **Player Initialization** — Default player creation
- ✅ **Player with Spy Role** — Spy role assignment
- ✅ **Player ID Uniqueness** — Each player gets unique ID
- ✅ **Player with Custom UUID** — Custom ID assignment
- ✅ **Player Identifiable Protocol** — Supports Identifiable

#### Player Role Tests
- ✅ **Normal Player Role** — Role assignment
- ✅ **Spy Player Role** — Spy role assignment
- ✅ **Multiple Players with Roles** — Role distribution in arrays

#### Player Name Tests
- ✅ **Player Name Storage** — Name persistence
- ✅ **Various Player Names** — Different name formats
- ✅ **Special Characters in Names** — International character support

#### Player Serialization
- ✅ **Player Encoding/Decoding** — JSON roundtrip
- ✅ **Spy Player Coding** — Spy role preserved
- ✅ **Player Array Coding** — Array of players
- ✅ **Multiple Players Coding** — Mixed role players

#### PlayerRole Enumeration
- ✅ **PlayerRole.normal** — Enumeration value
- ✅ **PlayerRole.spy** — Enumeration value
- ✅ **PlayerRole Inequality** — Different roles not equal

#### Game Integration
- ✅ **Game Initialization with Players** — Player array passed to game
- ✅ **Player Access During Gameplay** — Player lookup by index
- ✅ **Sequential Player Access** — Iteration through players

#### Player Customization
- ✅ **Player Name Customization** — Custom name support
- ✅ **Player Identity Maintenance** — ID preservation
- ✅ **Minimum Player Count (2)** — Minimum valid game
- ✅ **Maximum Player Count (8)** — Maximum valid game

**Test Count:** 26 test methods

---

### 5. AppStateTests.swift

**Purpose:** Application-wide state management and navigation.

**Test Coverage:**

#### Initialization Tests
- ✅ **Default Initialization** — AppState starts correctly
- ✅ **Default Player Names Count** — Correct name array size
- ✅ **Default Player Names Format** — Proper naming convention

#### Player Count Management
- ✅ **Set Player Count: Minimum (2)** — Boundary value
- ✅ **Set Player Count: Maximum (8)** — Boundary value
- ✅ **Set Player Count: Various Values** — All valid counts (2-8)
- ✅ **Player Count Increase** — Count increases properly
- ✅ **Player Count Decrease** — Count decreases properly

#### Player Name Management
- ✅ **Update Player Name** — Single name update
- ✅ **Update Multiple Names** — Batch name updates
- ✅ **Special Characters in Names** — International names
- ✅ **Invalid Index Handling** — Out-of-range ignored
- ✅ **Update After Count Change** — Names sync with count

#### Screen Navigation
- ✅ **Navigate to Game Screen** — startGame() works
- ✅ **Navigate to Setup** — goToSetup() works
- ✅ **Reset Game** — resetGame() restores all defaults
- ✅ **Navigation Sequence** — Multiple navigation transitions

#### Theme Selection
- ✅ **Theme Enum Cases** — All 3 themes available
- ✅ **Theme Raw Values** — String representations correct
- ✅ **Theme Selection** — Theme assignment works
- ✅ **Theme CaseIterable** — All themes enumerable
- ✅ **Theme Persistence** — Theme survives game start

#### Integration Tests
- ✅ **Complete Setup Flow** — Full configuration sequence
- ✅ **Reset Maintains Defaults** — Reset restores initialization
- ✅ **Player Count Change Updates Names** — Auto-generation of names

#### State Consistency
- ✅ **Count and Names Synchronized** — Always in sync
- ✅ **Names Array Consistency** — Proper array state

**Test Count:** 31 test methods

---

## Test Statistics

| Category | Count |
|----------|-------|
| GameStateTests.swift | 26 |
| TurnFlowTests.swift | 20 |
| CardContentTests.swift | 24 |
| PlayerTests.swift | 26 |
| AppStateTests.swift | 31 |
| **TOTAL** | **127** |

---

## Key Testing Patterns

### 1. Boundary Value Testing
- Player counts: 2 (min), 8 (max), and ranges between
- Card indices: Valid, negative, out-of-range
- State transitions: All valid screen transitions

### 2. Randomization Validation
- 100-run spy position variation test
- 300-run distribution test (20-43% per position)
- Statistical verification of random behavior

### 3. State Consistency
- Player count ↔ player names always synchronized
- Card content preserved through reveal/lock cycles
- Game completion tracked accurately

### 4. Error Handling
- Invalid card/player indices throw GameError
- Locked cards cannot be reopened
- Out-of-range operations fail gracefully

### 5. Integration Testing
- Complete game sequences (start to end)
- Multi-turn gameplay
- State persistence across operations

### 6. Family-Safety Validation
- All 24 family-friendly words tested
- Word length constraints verified
- Age-appropriate content confirmed

---

## Family-Safety Coverage

**Words Tested for Family-Friendliness:**

**Place Theme:**
Paris, London, Tokyo, Cairo, Sydney, Rome, Dubai, Barcelona

**Country Theme:**
France, Italy, Japan, Brazil, Australia, Canada, Spain, Thailand

**Things Theme:**
Bicycle, Book, Camera, Clock, Elephant, Guitar, Hat, Lighthouse

**Language & UI:**
- All test assertions use family-friendly language
- No inappropriate content in test descriptions
- Suitable for ages 6+

---

## Test Execution Guidelines

### Running All Tests
```bash
xcodebuild test -scheme FamilyGame
```

### Running Specific Test Suite
```bash
xcodebuild test -scheme FamilyGame -only GameStateTests
xcodebuild test -scheme FamilyGame -only TurnFlowTests
xcodebuild test -scheme FamilyGame -only CardContentTests
xcodebuild test -scheme FamilyGame -only PlayerTests
xcodebuild test -scheme FamilyGame -only AppStateTests
```

### Running Specific Test Method
```bash
xcodebuild test -scheme FamilyGame -only GameStateTests/testCorrectCardCountForThreePlayers
```

---

## Notes for Development Team

### For Tony Stark (Backend):
- GameState model must implement the cardSelection and lockCard methods
- Randomization of spy position must pass distribution test (300 runs)
- GamePhase enum needed for state tracking
- All GameError cases must be thrown appropriately

### For Natasha Romanoff (Frontend):
- AppState screen transitions work with tested navigation flow
- Player name updates sync with UI inputs
- Theme selection displayed with CaseIterable enumeration
- Card reveal/lock animations align with state changes

### For QA/Testing:
- Run full test suite before each integration checkpoint
- Validate manual playtesting against automated scenarios
- Check family-safety of any custom words before adding to themes.json
- Monitor randomization distribution in production builds

---

## Future Test Expansions

### Phase 2 Testing Scope:
- End-game voting/reveal mechanics (Epic 7)
- Game statistics and scoring
- Word list loading from themes.json
- Persistent game history

### Phase 3 Testing Scope:
- iPad layout testing
- Accessibility (VoiceOver, dynamic type)
- Performance profiling
- Battery impact testing

---

## Document Metadata

**Created:** 2026-03-06  
**Author:** Bruce Banner (QA)  
**Framework:** XCTest  
**Swift Version:** 5.9+  
**Xcode Compatibility:** 15.0+  
**Status:** Ready for Integration Testing

