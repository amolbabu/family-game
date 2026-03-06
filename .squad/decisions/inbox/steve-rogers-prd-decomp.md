# Steve Rogers — PRD Validation & Architecture Decomposition

**Date:** 2026-03-07  
**Status:** ✅ COMPLETE — PRD Validated, Architecture Proposed, Work Sequence Ready  
**Requester:** amolbabu  

---

## 1. SCOPE VALIDATION

### ✅ Strengths of the PRD

The PRD is **well-structured** and **complete** for MVP scope:

- **Clear Vision:** Family spy game with single-phone, turn-based card reveals
- **Well-Defined Mechanics:** Card randomization, SPY assignment, turn flow
- **Acceptance Criteria:** All 16 user stories include concrete, testable criteria
- **Theme System:** JSON-based extensibility is future-proof
- **Scope Boundaries:** Realistic for a 3-phase MVP (no network, no backend, no complex AI)

### ⚠️ Scope Clarifications Needed (Non-Blocking)

Before **Phase 2** (Core Game), confirm:

1. **Win/Lose Condition** 
   - Story 13 says "reveal phase ends" but PRD doesn't define victory condition
   - Is this intentionally omitted for later phases, or should Phase 1 include a simple end-game screen?
   - **Recommendation:** Add simple "All cards revealed" → "End Game" screen to Phase 1 (non-blocking for card mechanics)

2. **Player Turn Order**
   - PRD shows players take turns in sequence, but doesn't specify:
     - Is order fixed (1→2→3→N→1) or configurable?
     - Do we show "Player 1's turn" or use a name system?
   - **Recommendation:** Use fixed sequential ordering (Player 1, 2, 3...). Names can be Phase 3 polish.

3. **Theme Content Validation**
   - Story 5 requires "family-friendly" words, but doesn't define the content review process
   - Should the JSON include a content-flag for adult themes, or is manual curation sufficient?
   - **Recommendation:** Manual curation at MVP. Add flagging in Phase 3 if needed.

4. **Minimum Player Count**
   - Story 2 says "Minimum player count is defined by the app" but doesn't specify the number
   - **Recommendation:** Set minimum to 2, maximum to 8 (practical for family play). Configurable in Phase 3.

5. **Card Visual Design**
   - No UI mockup or card design spec
   - Are cards rectangular? Do they have decorative elements? Font sizes?
   - **Recommendation:** Start with simple card design (centered text, large tap area). Iterate in Phase 3.

### 🎯 Scope Decision Points (Require User Sign-Off Before Dev)

**Decision 1:** Should the MVP include a win/lose condition screen?
- Option A: Yes, simple "Game Over" screen when all cards revealed (adds ~1 day, nice-to-have)
- Option B: No, end after all cards revealed, next phase adds scoring/discussion screen (keeps MVP smaller)
- **My Recommendation:** Option A (minimal win screen improves closure experience)

**Decision 2:** Should we support player names or just "Player 1, Player 2..."?
- Option A: MVP uses "Player 1, 2, 3..."; names added in Phase 3
- Option B: MVP supports name input on setup screen
- **My Recommendation:** Option A (keeps MVP scope tight; names are polish)

**Decision 3:** Fixed player count or variable setup?
- Option A: Always 3 players (simplest)
- Option B: 2–8 players (more flexible, ~1 extra day of work)
- **My Recommendation:** Option B (PRD expects player count selection, worth the effort)

---

## 2. ARCHITECTURE OUTLINE

### Core Swift/SwiftUI Design

#### App Structure (Scene/View Hierarchy)

```
FamilyGameApp (root)
├── ContentView (orchestrator)
│   ├── WelcomeView (state: initial load)
│   ├── SetupView (state: player count, theme selection)
│   ├── GameView (state: turn-based gameplay)
│   │   ├── CardGridView (state: card deck)
│   │   │   └── CardView (state: revealed/hidden)
│   │   ├── TurnIndicatorView (state: current player, cards remaining)
│   │   └── PhaseTransitionView (state: pass phone, ready?)
│   └── EndGameView (state: game over)
```

#### Game State Management

**Approach:** Combine MVVM with immutable game state struct

```swift
@main
struct FamilyGameApp: App {
    @StateObject var gameController = GameController()
}

class GameController: ObservableObject {
    @Published var gameState: GameState = .welcome
    @Published var currentGame: Game? = nil
}

enum GameState {
    case welcome
    case setup
    case playing(currentTurn: Int)
    case gameOver
}

struct Game: Codable {
    let playerCount: Int
    let theme: Theme
    var cards: [Card]
    var revealedCards: Set<Int>
    var currentPlayerIndex: Int
    
    var currentPlayer: Int { currentPlayerIndex + 1 }
    var remainingCards: Int { cards.count - revealedCards.count }
    var isGameComplete: Bool { remainingCards == 0 }
}

struct Card: Identifiable {
    let id: UUID
    let content: CardContent  // .word(String) or .spy
    var isRevealed: Bool = false
    var isLocked: Bool = false
}

enum CardContent {
    case word(String)
    case spy
}

struct Theme: Codable, Identifiable {
    let id: String  // "places", "countries", "things"
    let name: String
    let words: [String]
}
```

#### Data Flow

1. **Theme Loading** → Codable JSON parser loads themes at app startup
2. **Game Setup** → User selects player count + theme → GameController creates Game instance
3. **Card Generation** → Services.CardGenerator randomizes SPY position + word selection
4. **Turn Flow** → Player taps card → reveals → confirms → taps again → locks → next turn
5. **Game End** → All cards locked → show EndGameView → play again option resets state

#### JSON Theme Structure

```json
{
  "themes": [
    {
      "id": "places",
      "name": "Places",
      "words": ["Beach", "Mountain", "City", "Forest", ...]
    },
    {
      "id": "countries",
      "name": "Countries",
      "words": ["France", "Japan", "Brazil", "Spain", ...]
    },
    {
      "id": "things",
      "name": "Things",
      "words": ["Pizza", "Guitar", "Bicycle", "Camera", ...]
    }
  ]
}
```

#### Randomization Strategy

```swift
struct CardGenerator {
    static func generateCards(
        count: Int,
        theme: Theme
    ) -> [Card] {
        let selectedWord = theme.words.randomElement()!
        var cards: [Card] = (0..<count).map { idx in
            Card(id: UUID(), content: .word(selectedWord))
        }
        
        let spyIndex = Int.random(in: 0..<count)
        cards[spyIndex] = Card(id: UUID(), content: .spy)
        
        return cards.shuffled()
    }
}
```

### Turn-Based Flow State Machine

```
Initial:   [🃏 🃏 🃏 🃏 🃏] allLocked=false

Turn 1:    P1 taps card → reveals → sees content → taps → locks
           [🔒 🃏 🃏 🃏 🃏] currentPlayer=2

Turn 2:    P2 taps available card → reveals → sees content → taps → locks
           [🔒 🔒 🃏 🃏 🃏] currentPlayer=3

...continues...

Final:     All cards locked → isGameComplete=true → show EndGameView
           [🔒 🔒 🔒 🔒 🔒] Enable "Play Again" button
```

### Key Design Patterns

**1. Immutable Game State**
- Game struct is value type (struct, not class)
- Each turn update creates new Game instance with updated card/player state
- Enables easy undo/replay and time-travel debugging

**2. Turn Validation**
- Before allowing card selection, check: `card.isLocked == false && !revealedCards.contains(card.id)`
- Prevents illegal moves with compile-time safety

**3. Error Handling**
- Theme loading fails → show error alert, fallback to bundled themes
- Invalid theme selection → prevent game start with validation
- Card generation edge cases (playerCount=1) → clamp or show setup error

**4. Testing Support**
- Randomization uses `random` by default, but injectable for deterministic tests
- Game state is serializable (Codable) → easy snapshot testing

---

## 3. TECH DECISIONS

### Framework Choices

| Layer | Framework | Rationale |
|-------|-----------|-----------|
| **UI** | SwiftUI | Modern, required for iOS 14+. Enables smooth card animations and state-driven design. |
| **State** | Combine (@Published) | Lightweight for single-player flow. No Redux/MVI complexity needed. |
| **Data** | Codable (Foundation) | Built-in JSON parsing. Themes load from JSON at startup. |
| **Testing** | XCTest + Combine testing | Swift ecosystem. No 3rd-party test framework needed. |
| **Other** | None required | No GameKit needed (not a multi-device game). No networking. |

### Recommended Dependency Injection

Light-touch DI using environment variables:

```swift
class GameController: ObservableObject {
    var themeService = ThemeService()
    var cardGenerator = CardGenerator()
}
```

No external DI framework needed at MVP. If test complexity grows in Phase 3, adopt lightweight protocols.

### Rejected Options

- **Vapor/backend:** Local phone game only, no multiplayer server needed
- **CloudKit/Firestore:** No cloud persistence in MVP (can add in future phase)
- **CoreData:** JSON-only themes, no need for persistent database
- **Third-party animation libraries:** SwiftUI animations sufficient for card reveals
- **Complex state management (Redux, MVI):** Single-player turn-based game, MVVM adequate

---

## 4. WORK SEQUENCE — PRIORITIZED & DEPENDENCY-ORDERED

### Phase 1: Foundation (Player Count + Theme Selection + Card Setup)

| ID | Story | Title | Dependency | Est. Days | Priority |
|---|---|---|---|---|---|
| **P1-S1** | US1 | Welcome Screen with Start Button | None | 1 | 🔴 Must |
| **P1-S2** | US2 | Player Count Selection | P1-S1 | 1 | 🔴 Must |
| **P1-S3** | US3 | Theme Selection Screen | P1-S2 | 1 | 🔴 Must |
| **P1-S4** | US4 | Load Themes from JSON | P1-S3 | 1 | 🔴 Must |
| **P1-S5** | US5 | Validate Family-Friendly Content | P1-S4 | 0.5 | 🟡 Should |
| **P1-S6** | US6 | Card Generation (SPY + Words) | P1-S4 | 1 | 🔴 Must |
| **P1-S7** | US7 | Random Word Selection | P1-S6 | 0.5 | 🔴 Must |
| **P1-TEST** | – | Unit Tests: Game State & Card Generation | P1-S7 | 1 | 🟡 Should |

**Phase 1 Goal:** Players complete setup, app generates correct card deck.  
**Phase 1 Acceptance:** Given 3 players + "Places" theme → app creates 3 cards with 1 SPY + 2 place names.

---

### Phase 2: Core Game (Turn-Based Reveal + UI)

| ID | Story | Title | Dependency | Est. Days | Priority |
|---|---|---|---|---|---|
| **P2-S1** | US8 | Display All Cards Face Down | P1-S7 | 1.5 | 🔴 Must |
| **P2-S2** | US9 | Single Card Reveal on Tap | P2-S1 | 1.5 | 🔴 Must |
| **P2-S3** | US10 | Flip Card Back & Lock It | P2-S2 | 1 | 🔴 Must |
| **P2-S4** | US11 | Enforce Remaining Cards Only | P2-S3 | 0.5 | 🔴 Must |
| **P2-S5** | US12 | Turn Indicator & "Your Turn" Prompt | P2-S4 | 1 | 🔴 Must |
| **P2-S6** | US13 | Detect Game Complete, Show End Screen | P2-S5 | 1 | 🔴 Must |
| **P2-S7** | US14 | Child-Friendly Card UI Design | P2-S1 | 1.5 | 🟡 Should |
| **P2-TEST** | – | Integration Tests: Full Turn Flow | P2-S6 | 1 | 🟡 Should |

**Phase 2 Goal:** Players take turns revealing cards privately; game enforces rules.  
**Phase 2 Acceptance:** 3-player game → P1 reveals card (sees content) → flips back → P2 can only pick from remaining 2 cards → repeat → game ends when all cards locked.

---

### Phase 3: Polish & Extensibility

| ID | Story | Title | Dependency | Est. Days | Priority |
|---|---|---|---|---|---|
| **P3-S1** | US15 | Add New Themes Dynamically | P1-S4 | 0.5 | 🟢 Nice |
| **P3-S2** | US16 | Play Again Button & State Reset | P2-S6 | 1 | 🟢 Nice |
| **P3-S3** | – | Card Animation Enhancements | P2-S3 | 1 | 🟢 Nice |
| **P3-S4** | – | Accessibility (VoiceOver, larger text) | P2-S7 | 1 | 🟢 Nice |
| **P3-S5** | – | iPad Layout Support | P2-S1 | 0.5 | 🟢 Nice |
| **P3-TEST** | – | End-to-End Tests & QA Polish | P3-S2 | 2 | 🟢 Nice |

**Phase 3 Goal:** Extra features, animations, accessibility; production-ready polish.  
**Phase 3 Acceptance:** Game supports 3–8 players, smooth animations, accessible on all iPhone/iPad sizes.

---

## 5. WORK SEQUENCE TABLE — ALL STORIES

### Summary View (Dependency Tree)

```
FOUNDATION (Phase 1)
├── US1: Welcome Screen (1d)
│   └── US2: Player Count (1d)
│       └── US3: Theme Selection (1d)
│           ├── US4: Load JSON Themes (1d)
│           │   ├── US6: Card Generation (1d)
│           │   │   └── US7: Random Word (0.5d)
│           │   └── US5: Family-Friendly Check (0.5d)
│           └── P1 TESTS (1d)
│
CORE GAME (Phase 2)
├── US8: Cards Face Down (1.5d)
├── US9: Reveal on Tap (1.5d)
│   ├── US10: Flip Back & Lock (1d)
│   │   ├── US11: Remaining Cards Only (0.5d)
│   │   │   ├── US12: Turn Indicator (1d)
│   │   │   │   └── US13: Game Complete (1d)
│   │   │   │       └── P2 TESTS (1d)
│   │   │   └── US14: Card UI Design (1.5d)
│
POLISH (Phase 3)
├── US15: New Themes (0.5d)
├── US16: Play Again (1d)
├── Animations (1d)
├── Accessibility (1d)
├── iPad Support (0.5d)
└── P3 TESTS (2d)
```

### Critical Path Analysis

**Minimum Days to Playable MVP (Phase 1 + Phase 2 Core):**
- Phase 1 (foundation): ~6 days
- Phase 2 (core game): ~5 days
- **Total: ~11 days (2.5 weeks with testing)**

**With Recommended Polish (Phase 3):**
- Total: ~18 days (3.5 weeks)

---

## 6. DETAILED IMPLEMENTATION ROADMAP

### Phase 1 Workflow (Foundation)

#### Week 1: Setup Flow
1. **P1-S1 (Welcome Screen)** — Create FamilyGameApp, WelcomeView with "Start Game" button. Navigation state in GameController.
2. **P1-S2 (Player Count)** — SetupView with Picker (2–8 players, default 3). Save selection to GameController.
3. **P1-S3 (Theme Selection)** — ThemePickerView. List of themes with descriptions. Save selected theme.

#### Week 1-2: Data & Generation
4. **P1-S4 (Load Themes)** — Create `ThemeService`, bundle themes.json, use Codable to parse. Error handling with fallback.
5. **P1-S5 (Family-Friendly)** — Review bundled words, flag any questionable content. Document content policy.
6. **P1-S6 & P1-S7 (Card Generation)** — CardGenerator service. Create N cards, assign 1 SPY, N-1 random words, shuffle, return.
7. **P1-TEST** — Unit tests for CardGenerator (deterministic seeding), GameState, Theme parsing.

#### Phase 1 Deliverable
- App launches → Welcome → Setup (players + theme) → card deck generated in memory
- Game ready for turn-based reveal in Phase 2

---

### Phase 2 Workflow (Core Game)

#### Week 2-3: UI & Turn Flow
1. **P2-S1 (Face Down)** — GameView displays CardGridView with card count. CardView shows placeholder (no content visible).
2. **P2-S2 (Reveal on Tap)** — Tap handler reveals card content. Single card only (guard against multiple simultaneous taps).
3. **P2-S3 (Flip & Lock)** — Second tap flips card back, marks locked=true. Prevent further taps on locked cards.
4. **P2-S4 (Remaining Only)** — CardView disables taps on locked cards. Grey out or hide locked cards.
5. **P2-S5 (Turn Indicator)** — TurnIndicatorView shows "Player X's turn" and "Cards remaining: N". Advance turn after card locked.
6. **P2-S6 (Game Complete)** — Check `isGameComplete` after each turn. Show EndGameView with stats.
7. **P2-S7 (Card Design)** — Finalize CardView styling. Large tap area, readable font, color scheme.
8. **P2-TEST** — Integration tests for full turn sequence, edge cases (last card, invalid taps).

#### Phase 2 Deliverable
- Full playable game: setup → 3 players take turns → reveal cards → game ends
- All rules enforced, no invalid moves allowed

---

### Phase 3 Workflow (Polish)

#### Week 3-4: Features & QA
1. **P3-S1 (New Themes)** — Document theme.json format. App loads all themes from file without code change.
2. **P3-S2 (Play Again)** — EndGameView button resets GameController state. Navigation back to setup.
3. **P3-S3 (Animations)** — CardView flip animation with SwiftUI `.transition()`. Smooth state transitions.
4. **P3-S4 (Accessibility)** — Add `.accessibilityLabel()` to cards, larger font option, VoiceOver support.
5. **P3-S5 (iPad)** — Test on iPad, adjust layout for larger screens (wider card grid).
6. **P3-TEST** — Full QA, edge case testing, performance on older devices.

#### Phase 3 Deliverable
- Production-ready app: smooth UX, accessible, extensible theme system, replay support

---

## 7. DECISION POINTS — USER SIGN-OFF REQUIRED

### ✅ Decision 1: MVP End-Game Experience

**Question:** After all cards revealed, what happens?

**Options:**
- **A (Minimal):** Show "Game Over" with "Play Again" button (lightweight, ~1 hour)
- **B (Richer):** Show who was the spy, tally correct guesses, then "Play Again" (Phase 3 feature)

**Recommendation:** Option A for MVP. It provides closure without adding guessing/scoring logic.

**Sign-off Required:** Yes ☐

---

### ✅ Decision 2: Player Naming

**Question:** Should players enter names, or use "Player 1, Player 2..."?

**Options:**
- **A (Generic):** Use "Player 1, 2, 3..." throughout (MVP approach, simplest)
- **B (Named):** Optional name input on setup screen (Phase 3 polish)

**Recommendation:** Option A. Names are nice-to-have but not core to game flow.

**Sign-off Required:** Yes ☐

---

### ✅ Decision 3: Player Count Range

**Question:** What's the min/max player count?

**Options:**
- **A (Limited):** Only 2–4 players (simplest first implementation)
- **B (Flexible):** 2–8 players (broader use cases, same code complexity)

**Recommendation:** Option B (2–8). Covers family sizes. Implementation is trivial (just array sizing).

**Sign-off Required:** Yes ☐

---

### ✅ Decision 4: Theme Content Moderation

**Question:** How do we ensure themes stay family-friendly?

**Options:**
- **A (Manual):** Amolbabu reviews words before including in JSON (current approach)
- **B (Flagged):** Include a `adult_only` flag in JSON for runtime filtering (Phase 3)

**Recommendation:** Option A for MVP. Curate carefully upfront. Flag system in Phase 3 if user library grows.

**Sign-off Required:** Yes ☐

---

### ✅ Decision 5: Initial Theme Set

**Question:** Which 3 themes for MVP launch?

**Recommendation:**
- **Places** (Beach, Mountain, Park, Castle, Pyramid, ...)
- **Countries** (France, Japan, Brazil, Egypt, Korea, ...)
- **Things** (Pizza, Guitar, Camera, Bicycle, Book, ...)

Each theme should have ~30 words to allow replayability without repetition.

**Sign-off Required:** Yes ☐

---

## 8. ARCHITECTURE VALIDATION AGAINST PRD

| PRD Story | Architecture Coverage | Status |
|-----------|----------------------|--------|
| US1: Welcome Screen | WelcomeView + GameController state | ✅ |
| US2: Player Count | SetupView + GameController.playerCount | ✅ |
| US3: Theme Selection | ThemePickerView + GameController.selectedTheme | ✅ |
| US4: Load from JSON | ThemeService + Codable parsing | ✅ |
| US5: Family-Friendly | Content review process + validation guard | ✅ |
| US6: SPY Card + Words | CardGenerator randomization logic | ✅ |
| US7: Random Word Selection | CardGenerator.randomElement() | ✅ |
| US8: Cards Face Down | CardView initial state (isRevealed=false) | ✅ |
| US9: Reveal on Tap | CardView tap handler + content display | ✅ |
| US10: Flip & Lock | CardView second tap + isLocked=true guard | ✅ |
| US11: Remaining Cards Only | CardView disabled guard + revealedCards Set | ✅ |
| US12: Turn Indicator | TurnIndicatorView + currentPlayerIndex state | ✅ |
| US13: Game Complete | Game.isGameComplete computed property | ✅ |
| US14: Child-Friendly Design | CardView styling + accessibility | ✅ |
| US15: Extensible Themes | JSON-based themes, no code changes needed | ✅ |
| US16: Play Again | EndGameView button + state reset | ✅ |

**Conclusion:** Architecture fully covers all 16 user stories.

---

## 9. MODULE STRUCTURE & FILE ORGANIZATION

```
familyGame/
├── FamilyGameApp.swift                    # App entry point
├── Models/
│   ├── Game.swift                         # Main game state struct
│   ├── Card.swift                         # Card model + CardContent enum
│   ├── Theme.swift                        # Theme model (Codable)
│   └── GameController.swift               # Published state container
├── Views/
│   ├── WelcomeView.swift                  # Launch screen
│   ├── SetupView.swift                    # Player count + theme picker
│   ├── GameView.swift                     # Main gameplay screen
│   ├── CardGridView.swift                 # Grid of cards
│   ├── CardView.swift                     # Individual card component
│   ├── TurnIndicatorView.swift            # Current player + cards left
│   ├── EndGameView.swift                  # Game over screen
│   └── ContentView.swift                  # Main navigation/state orchestrator
├── ViewModels/
│   ├── GameViewModel.swift                # Game logic coordinator
│   └── CardViewModel.swift                # Card-specific state (optional)
├── Services/
│   ├── ThemeService.swift                 # JSON loading, theme management
│   ├── CardGenerator.swift                # Card creation + randomization
│   └── GameRulesEngine.swift              # Turn validation, game rules
├── Resources/
│   └── themes.json                        # Bundled themes
├── Tests/
│   ├── CardGeneratorTests.swift
│   ├── GameStateTests.swift
│   ├── ThemeServiceTests.swift
│   └── GameFlowIntegrationTests.swift
└── Package.swift (or project.pbxproj)
```

---

## 10. KEY IMPLEMENTATION NOTES

### Immutability & State Updates

Every turn, create a new Game instance:

```swift
var currentGame: Game {
    // Compute remainingCards without mutating
    return Game(
        playerCount: game.playerCount,
        theme: game.theme,
        cards: game.cards,  // Cards reference same instances
        revealedCards: game.revealedCards,
        currentPlayerIndex: (game.currentPlayerIndex + 1) % game.playerCount
    )
}
```

This enables:
- Easy undo/redo
- Time-travel debugging
- Testability (compare before/after states)

### Turn Validation

Guard every action:

```swift
func attemptRevealCard(_ cardIndex: Int) -> Result<Void, GameError> {
    guard cardIndex < cards.count else { return .failure(.invalidCard) }
    guard !cards[cardIndex].isLocked else { return .failure(.cardAlreadyRevealed) }
    guard !revealedCards.contains(cardIndex) else { return .failure(.cardAlreadyUsed) }
    
    return .success(())  // Proceed with reveal
}
```

### Testing Strategy

1. **Unit Tests:** CardGenerator, Game state transitions, Theme parsing
2. **Integration Tests:** Full turn sequence (setup → reveal → lock → next player)
3. **Snapshot Tests:** CardView rendering in different states
4. **UI Tests:** Navigation flow, tap interactions (if needed)

### Performance Considerations

- **Card Grid:** SwiftUI's `LazyVGrid` for efficient rendering even with 8+ cards
- **Theme Loading:** Load once at app startup, keep in memory (~100KB JSON)
- **Randomization:** Use `Swift.Random` (built-in, no external dependency)

---

## 11. RISK REGISTER & MITIGATION

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| SwiftUI/Combine learning curve | Medium | Low | Architecture is simple MVVM; ample tutorials available |
| JSON theme format too rigid | Low | Medium | Design format to allow future fields (expansible design) |
| Card tap responsiveness on older devices | Low | Medium | Test on iPhone 12 mini; optimize LazyVGrid rendering |
| Theme words not family-friendly | Medium | High | Manual review of all words before shipping; user feedback mechanism in Phase 3 |
| Player count edge cases (1 player, 9+ players) | Low | Low | Clamp input 2–8; show validation error if violated |

---

## 12. NEXT STEPS & TIMELINE

### Approval Gate (Before Dev Starts)

Confirm the 5 decision points above:
1. ☐ End-game experience (minimal vs. richer)
2. ☐ Player naming (generic vs. named)
3. ☐ Player count range (2–4 vs. 2–8)
4. ☐ Theme content moderation (manual vs. flagged)
5. ☐ Initial theme set (Places, Countries, Things approved)

### Dev Schedule (After Approval)

- **Week 1:** Phase 1 (setup & card generation)
- **Week 2–3:** Phase 2 (core game & turn flow)
- **Week 3–4:** Phase 3 (polish & QA)
- **Week 4:** Final testing, bug fixes, submission prep

### Handoff to Team

1. **Scribe:** Document decisions, architecture diagram, API surface
2. **Tony Stark:** Lead Phase 1 implementation (setup + data models)
3. **Vision:** Lead Phase 2 implementation (game UI + turn logic)
4. **Natasha Romanoff:** QA + testing strategy in Phase 2
5. **Bruce Banner:** Performance optimization in Phase 3

---

## CONCLUSION

The PRD is **well-formed and complete** for MVP development. Architecture is **straightforward**: SwiftUI + Combine for a single-player turn-based game with local JSON themes.

**Estimated delivery:** 3–4 weeks to production-ready.

**Approval required:** 5 decision points (non-blocking technical details; all relate to scope/UX polish).

**Recommendation:** Proceed with Phase 1 immediately after sign-off on the decision points.
