# Steve Rogers — Phase 2 Architecture Design

**Date:** 2026-03-08  
**Phase:** 2 — Core Game (Turn-Based Card Reveal)  
**Status:** Architecture Blueprint Complete  
**Owner:** Steve Rogers (Lead Architect)  
**Prepared for:** Natasha (Frontend), Tony (Backend), Bruce (Testing)

---

## Executive Summary

Phase 2 builds the turn-based card reveal gameplay on top of Phase 1's solid foundation (GameState, Card, Player models, themes.json). This design enables **zero blockers** for parallel work: Natasha designs and implements GameScreenView, Tony wires game logic and state flow, and Bruce tests all interactions simultaneously.

**Key Architectural Principles:**
1. **Immutable State + Mutation Methods:** GameState remains the single source of truth; UI reacts to changes
2. **Reactive UI via SwiftUI:** No external state management library needed; @Observable/Environment leverage is sufficient
3. **State Machine for Turn Flow:** Legal transitions are enforced; invalid actions throw typed errors
4. **Family-First Interactions:** Large tap targets, clear feedback, no harsh errors
5. **No New Dependencies:** SwiftUI-native only; proven in Phase 1

---

## 1. GameScreenView Architecture

### Overview

GameScreenView is the heart of Phase 2. It displays the card grid, current player indicator, turn controls, and handles user interactions. The view is **stateless** in terms of game logic—all state lives in GameState; the view reacts to changes.

### Layout Structure

```
┌─────────────────────────────────────┐
│         Turn Indicator              │
│    "Player 1's Turn • Round 1/3"    │
├─────────────────────────────────────┤
│                                     │
│         Card Grid                   │
│    ┌──────┐ ┌──────┐                │
│    │  ?   │ │  ?   │                │
│    └──────┘ └──────┘                │
│    ┌──────┐ ┌──────┐                │
│    │  ?   │ │  ?   │                │
│    └──────┘ └──────┘                │
│                                     │
├─────────────────────────────────────┤
│       Action Prompt Area             │
│  "Tap a card to reveal"             │
│  OR                                 │
│  "[REVEALED] Tap to hide"           │
│  OR                                 │
│  "Press NEXT PLAYER to continue"    │
├─────────────────────────────────────┤
│  [ Next Player ]  [ Reveal ]         │
│   (if showing)    (if needed)        │
└─────────────────────────────────────┘
```

### Card Grid Responsiveness

```swift
// LazyVGrid with dynamic column count
// 2–4 players: 2 columns (large cards, tap-friendly)
// 5–6 players: 3 columns (medium cards)
// 7–8 players: 4 columns (smaller cards, still readable)

let columns = [
    GridItem(.flexible(minimum: 80), spacing: 12),
    GridItem(.flexible(minimum: 80), spacing: 12),
    // 3rd/4th column added conditionally based on playerCount
]
```

### Card Component (CardView)

**Responsibilities:**
- Display face-down state: Blue back with "?" or card outline
- Display revealed state: Show word or "SPY!" text, animated flip
- Display locked state: Slightly desaturated, disabled interaction
- Provide haptic feedback on tap

**CardView States:**

```
State: facedDown
  └─ Appearance: Blue rectangle, "?" centered, tap-enabled
  └─ Interaction: Tap → selectCard(index) → setState(.revealing)
  
State: revealing
  └─ Appearance: Flip animation, then show content (word or SPY!)
  └─ Interaction: Locked; no further input until hideCard()
  └─ Duration: ~300ms flip animation, ~1000ms dwell time (show content)
  
State: revealed
  └─ Appearance: Content visible (word or SPY!), can tap to hide
  └─ Interaction: Tap → hideCard(index) → setState(.hiding)
  
State: hiding
  └─ Appearance: Flip animation, back to face-down
  └─ Interaction: Locked; animating
  └─ Duration: ~300ms flip animation
  
State: locked
  └─ Appearance: Desaturated, grayed out, shows content faintly
  └─ Interaction: No interaction possible
```

**CardView Implementation Pattern:**

```swift
struct CardView: View {
    @State private var isFlipped = false
    @State private var displayContent = false
    
    let card: Card
    let cardIndex: Int
    let onTap: (Int) -> Void
    let isCurrentPlayerTurn: Bool
    let gameScreenState: GameScreenState  // Local UI state
    
    var body: some View {
        ZStack {
            // Back side (face-down or locked appearance)
            if !displayContent {
                CardBackView(isLocked: card.isLocked)
            } else {
                // Front side (revealed content)
                CardFrontView(content: card.content)
            }
        }
        .frame(height: 120)
        .onTapGesture {
            if isInteractable {
                onTap(cardIndex)
            }
        }
    }
    
    var isInteractable: Bool {
        !card.isLocked && isCurrentPlayerTurn && 
        (gameScreenState == .selectingCard || gameScreenState == .cardRevealed)
    }
}
```

### Turn Indicator Component

```swift
struct TurnIndicatorView: View {
    @Binding var gameState: GameState
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Turn-Based Card Reveal")
                .font(.headline)
            
            HStack {
                Text("Current Player:")
                    .font(.body)
                Text(gameState.players[gameState.currentPlayerIndex].name)
                    .font(.headline)
                    .foregroundStyle(.blue)
            }
            
            HStack {
                Text("Round:")
                Text("\(gameState.revealedCards.count)/\(gameState.cards.count)")
                    .font(.headline)
            }
            
            ProgressView(value: Double(gameState.revealedCards.count), 
                        total: Double(gameState.cards.count))
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .accessibilityLabel("Turn information")
        .accessibilityValue(
            "Player \(gameState.currentPlayerIndex + 1) of \(gameState.players.count). " +
            "\(gameState.revealedCards.count) of \(gameState.cards.count) cards revealed."
        )
    }
}
```

### Accessibility Features

**VoiceOver:**
- Each card has `.accessibilityLabel("Card \(index + 1)")`
- Revealed card: `.accessibilityValue("Shows word: \(word)")` or `"Shows spy"`
- Turn indicator announces current player and round progress
- Action buttons (Next Player, Reveal Hide) have clear labels and hints

**Large Tap Targets:**
- Minimum 44×44 pt per Apple guidelines
- Cards min 80×120 pt (exceeds minimum, family-friendly)
- Buttons min 48 pt tall

**Dynamic Type:**
- All text uses system fonts that respect accessibility settings
- Card content scales with Dynamic Type (within bounds)

---

## 2. Turn-Based Flow State Machine

### High-Level State Flow

```
Setup (from Phase 1)
  ↓
[GameState initialized with players, cards, currentPlayerIndex=0]
  ↓
GameScreenView enters: selectingCard
  ↓
[Player taps card → GameLogic.selectCard()] → reveals CardContent
  ↓
UI state: cardRevealed
  ↓
[Player sees content (word or SPY!), ~1000ms dwell]
  ↓
[Player taps card again → GameLogic.lockCard()]
  ↓
UI state: cardLocking (animation)
  ↓
[Card flips, locks, becomes unavailable]
  ↓
[Check: isGameComplete()?]
  ├─ YES → UI state: gameOver → transition to EndGameView
  └─ NO → GameLogic.nextPlayer() → back to selectingCard
```

### State Machine Definition

```swift
enum GameScreenState: Equatable {
    case selectingCard           // Player can tap a card
    case cardRevealing           // Card flip animation in progress
    case cardRevealed            // Card content visible, ready to hide
    case cardHiding              // Card flip back animation
    case cardLocked              // Turn complete, card locked
    case nextPlayerPrompt        // Prompt to pass phone
    case gameOver                // All cards revealed
    case error(GameError)        // Invalid action (locked card, bad index, etc.)
}
```

### Legal State Transitions

```
selectingCard
  ├─ onCardTapped(index)
  │   ├─ [if valid] → cardRevealing → cardRevealed
  │   └─ [if locked] → error(.cardAlreadyLocked)
  └─ [if !canSelectMore] → gameOver

cardRevealed
  ├─ onCardTappedAgain(index)
  │   └─ → cardHiding → cardLocked
  └─ [if timeout 3s, auto-hide] → cardHiding

cardLocked
  ├─ [if isGameComplete()] → gameOver
  └─ [else] → nextPlayerPrompt

nextPlayerPrompt
  └─ onNextPlayerTap()
      └─ → selectingCard [currentPlayerIndex incremented]

gameOver
  └─ [no further transitions, show EndGameView]

error(reason)
  └─ [user dismisses] → selectingCard [state unchanged]
```

### Transition Pseudocode

```swift
// Model
@Observable
class GameScreenViewModel {
    @ObservationIgnored var gameState: GameState
    var screenState: GameScreenState = .selectingCard
    var cardRevealTimeout: Timer?
    
    func handleCardTap(index: Int) {
        do {
            let cardContent = try gameState.selectCard(at: index, byPlayer: gameState.currentPlayerIndex)
            screenState = .cardRevealing
            
            // Animate flip, then show content for 1-2 seconds
            withAnimation(.easeInOut(duration: 0.3)) {
                screenState = .cardRevealed
            }
            
            // Schedule auto-hide (user can manually hide anytime)
            cardRevealTimeout = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.screenState = .cardHiding
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.handleCardHide(index: index)
                }
            }
        } catch {
            screenState = .error(error as! GameError)
        }
    }
    
    func handleCardHide(index: Int) {
        do {
            try gameState.lockCard(at: index)
            screenState = .cardLocked
            cardRevealTimeout?.invalidate()
            
            if gameState.isGameComplete() {
                screenState = .gameOver
            } else {
                screenState = .nextPlayerPrompt
            }
        } catch {
            screenState = .error(error as! GameError)
        }
    }
    
    func handleNextPlayer() {
        gameState.nextPlayer()
        screenState = .selectingCard
    }
}
```

### Error Handling

**Invalid Actions & Recovery:**

| Error | Cause | User Feedback | Recovery |
|-------|-------|---|---|
| `cardAlreadyLocked` | Tap locked card | "That card is already used" (toast) | Stay in selectingCard |
| `invalidCardIndex` | Tap out of bounds | "Something went wrong" (generic) | Stay in selectingCard |
| `invalidPlayerIndex` | Game state corrupted | "Game error" (generic) | Reset or restart |

---

## 3. Data Binding Strategy

### Environment & Binding Hierarchy

**AppState (Navigation):**
```swift
// Phase 1: Holds player count, names, theme selection
// Phase 2: Passed as @Environment to GameScreenView
@Environment(AppState.self) var appState
```

**GameState (Game Model):**
```swift
// Phase 2 NEW: Wrap in @Observable for reactivity
@Observable
class GameScreenViewModel {
    var gameState: GameState
    var screenState: GameScreenState = .selectingCard
    
    init(playerCount: Int, playerNames: [String], theme: String) {
        let players = GameLogic.createPlayers(from: playerNames)
        let cards = GameLogic.generateCards(playerCount: playerCount, theme: theme)
        let word = GameLogic.selectRandomWord(from: theme)
        
        self.gameState = GameState(players: players, theme: theme, word: word)
        self.gameState.cards = cards
    }
}
```

**GameScreenView (UI):**
```swift
struct GameScreenView: View {
    @Environment(AppState.self) var appState
    @State var viewModel: GameScreenViewModel
    
    var body: some View {
        ZStack {
            VStack {
                TurnIndicatorView(gameState: $viewModel.gameState)
                
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.gameState.cards.indices, id: \.self) { index in
                        CardView(
                            card: viewModel.gameState.cards[index],
                            cardIndex: index,
                            onTap: { i in viewModel.handleCardTap(index: i) },
                            isCurrentPlayerTurn: index == viewModel.gameState.currentPlayerIndex,
                            gameScreenState: viewModel.screenState
                        )
                    }
                }
                
                ActionPromptArea(
                    screenState: viewModel.screenState,
                    onNextPlayer: viewModel.handleNextPlayer,
                    onDismissError: { viewModel.screenState = .selectingCard }
                )
            }
            
            // Show EndGameView when game is over
            if viewModel.screenState == .gameOver {
                EndGameView(
                    onPlayAgain: { appState.resetGame() },
                    onReturn: { appState.goToSetup() }
                )
            }
        }
        .onAppear {
            viewModel.initializeGame()
        }
    }
}
```

### Data Flow Diagram

```
AppState (Phase 1)
    ├─ playerCount: Int
    ├─ playerNames: [String]
    └─ selectedTheme: Theme

    ↓ passed to GameScreenView.onAppear

GameScreenViewModel
    ├─ gameState: GameState
    │   ├─ players: [Player]
    │   ├─ cards: [Card]
    │   ├─ currentPlayerIndex: Int
    │   ├─ revealedCards: Set<Int>
    │   └─ methods: selectCard(), lockCard(), nextPlayer(), isGameComplete()
    │
    ├─ screenState: GameScreenState
    └─ methods: handleCardTap(), handleCardHide(), handleNextPlayer()

    ↓ observed by

GameScreenView (UI)
    ├─ TurnIndicatorView
    ├─ CardGrid (LazyVGrid)
    │   └─ CardView (×N)
    ├─ ActionPromptArea
    └─ EndGameView (conditional)
```

### State Mutation & Binding Pattern

**Principle:** GameState mutations happen in ViewModel only, never in View.

```swift
// ✅ CORRECT: ViewModel handles logic, View reacts
struct GameScreenView: View {
    @State var viewModel: GameScreenViewModel
    
    var body: some View {
        CardView(
            card: viewModel.gameState.cards[0],
            onTap: { viewModel.handleCardTap(index: 0) }  // ViewModel method
        )
    }
}

// ❌ AVOID: Direct GameState mutation in View
struct GameScreenView: View {
    @State var gameState: GameState
    
    var body: some View {
        CardView(
            card: gameState.cards[0],
            onTap: {
                try? gameState.selectCard(at: 0, byPlayer: 0)  // No, do this in ViewModel
            }
        )
    }
}
```

### Animation & UI State

**Card Reveal Animation:**

```swift
struct CardView: View {
    @State private var isFlipped = false
    let card: Card
    
    var body: some View {
        ZStack {
            if isFlipped {
                CardFrontView(content: card.content)
            } else {
                CardBackView()
            }
        }
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0),
            perspective: 1.0
        )
        .onReceive(revealPublisher) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                isFlipped = true
            }
        }
    }
}

// Trigger from ViewModel:
// withAnimation(.easeInOut(duration: 0.3)) {
//     screenState = .cardRevealed
// }
```

**Action Prompt State:**

```swift
struct ActionPromptArea: View {
    let screenState: GameScreenState
    let onNextPlayer: () -> Void
    
    var body: some View {
        VStack {
            Group {
                switch screenState {
                case .selectingCard:
                    Text("Tap a card to reveal").font(.headline)
                case .cardRevealing, .cardRevealed:
                    Text("Tap again to hide").font(.headline)
                case .cardLocked:
                    Text("Card locked").font(.body)
                case .nextPlayerPrompt:
                    VStack {
                        Text("Ready to pass?").font(.headline)
                        Button("Next Player", action: onNextPlayer)
                    }
                case .gameOver:
                    Text("All cards revealed!").font(.headline)
                case .error(let error):
                    Text("Error: \(error.description)").foregroundStyle(.red)
                default:
                    EmptyView()
                }
            }
            .transition(.opacity)
        }
    }
}
```

---

## 4. End-Game Flow

### Detect Completion

Phase 1 already provides `isGameComplete()`:

```swift
func isGameComplete() -> Bool {
    return revealedCards.count == cards.count
}
```

**Check After Each Card Lock:**
```swift
func handleCardHide(index: Int) {
    try gameState.lockCard(at: index)
    
    if gameState.isGameComplete() {
        screenState = .gameOver  // ← Triggers EndGameView display
    } else {
        screenState = .nextPlayerPrompt
    }
}
```

### EndGameView Design

```swift
struct EndGameView: View {
    let onPlayAgain: () -> Void
    let onReturn: () -> Void
    
    var body: some View {
        ZStack {
            // Semi-transparent overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Game Over!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("All cards have been revealed")
                    .font(.body)
                
                VStack(spacing: 12) {
                    Button(action: onPlayAgain) {
                        Text("Play Again")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: onReturn) {
                        Text("Return to Setup")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray3))
                            .foregroundStyle(.black)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(12)
            .padding(16)
        }
        .transition(.scale.combined(with: .opacity))
    }
}
```

### Play Again Flow

**Option A: Mutate GameState (Preferred)**
```swift
// In AppState or GameScreenViewModel
func resetGame() {
    let players = GameLogic.createPlayers(from: appState.playerNames)
    let cards = GameLogic.generateCards(playerCount: appState.playerCount, theme: appState.selectedTheme.rawValue)
    let word = GameLogic.selectRandomWord(from: appState.selectedTheme.rawValue)
    
    gameState = GameState(players: players, theme: appState.selectedTheme.rawValue, word: word)
    gameState.cards = cards
    gameState.gamePhase = .inGame
    gameState.currentPlayerIndex = 0
    gameState.revealedCards = []
    
    screenState = .selectingCard
}
```

**Option B: Return to Setup**
```swift
// In AppState
func resetGame() {
    currentScreen = .setup
    // User re-selects and starts again
}
```

**Recommendation:** Option A (Play Again) for quick replays; Option B (Return to Setup) for theme/player changes.

---

## 5. Module Organization

### Proposed File Structure for Phase 2

```
ios/FamilyGame/FamilyGame/
├── App/
│   └── FamilyGameApp.swift                      [no change]
│
├── Models/
│   ├── AppState.swift                           [existing, no change]
│   ├── GameState.swift                          [existing, no change]
│   ├── Card.swift                               [existing, no change]
│   └── Player.swift                             [existing, no change]
│
├── ViewModels/                                  [NEW]
│   └── GameScreenViewModel.swift                [new: handles game logic & UI state]
│
├── Views/
│   ├── WelcomeScreenView.swift                  [existing, no change]
│   ├── SetupScreenView.swift                    [existing, no change]
│   ├── GameScreenView.swift                     [NEW: main game screen]
│   ├── Components/                              [NEW: reusable components]
│   │   ├── CardView.swift
│   │   ├── CardBackView.swift
│   │   ├── CardFrontView.swift
│   │   ├── TurnIndicatorView.swift
│   │   ├── ActionPromptArea.swift
│   │   └── EndGameView.swift
│   └── Screens/                                 [NEW: full screens]
│       └── GameScreenContainer.swift            [orchestrates GameScreenView + EndGameView]
│
├── Logic/
│   └── GameLogic.swift                          [existing, no change]
│
├── Managers/
│   └── ThemeManager.swift                       [existing, no change]
│
├── Resources/
│   └── themes.json                              [existing, no change]
│
└── Info.plist                                   [existing, no change]
```

### Module Responsibilities

| Module | Owner | Responsibility |
|--------|-------|---|
| GameScreenViewModel | Tony | Game logic orchestration, state mutations, error handling |
| GameScreenView | Natasha | Layout, card grid, turn indicator display |
| CardView | Natasha | Card appearance, flip animation, tap handling (delegates to ViewModel) |
| TurnIndicatorView | Natasha | Current player + round display, VoiceOver |
| ActionPromptArea | Natasha | Context-aware text/buttons (selecting, hiding, pass phone, game over) |
| EndGameView | Natasha | Post-game modal, Play Again / Return to Setup buttons |
| GameScreenContainer | Natasha | Coordinate GameScreenView + EndGameView transitions |

### Integration Points

**GameScreenView ← AppState:**
- Subscribe to AppState for navigation changes
- On `.setup` → `.game`: Initialize GameScreenViewModel with playerCount, playerNames, theme

**GameScreenView ↔ GameScreenViewModel:**
- ViewModel: Owns GameState, screenState, mutation methods
- View: Observes changes, calls ViewModel methods on user interaction

**CardView ← GameScreenViewModel:**
- Receives Card data (content, isRevealed, isLocked)
- Receives callback: `onTap: (Int) -> Void` (handled by ViewModel)

---

## 6. Technical Decisions

### Decision 1: Animation Framework

**Decision:** SwiftUI native transitions (`.rotation3DEffect` + `.withAnimation`)  
**Rationale:**
- Reduces complexity; no Combine animation publishers needed
- Smooth 60 FPS on all supported devices (Phase 1 proved SwiftUI is viable)
- Built-in timings (easeInOut) are family-friendly and predictable
- Easier to test and debug than Combine

**Implementation:**
```swift
withAnimation(.easeInOut(duration: 0.3)) {
    isFlipped = true  // Triggers rotation3DEffect
}
```

---

### Decision 2: Card Grid Layout

**Decision:** LazyVGrid with dynamic columns based on playerCount  
**Rationale:**
- Responsive to player count (2 cols for 2–4 players, 3 cols for 5–6, 4 cols for 7–8)
- Maintains tap-friendly sizes (min 80×120 pt per card)
- No external layout libraries needed
- LazyVGrid defers rendering off-screen cards (performance)

**Implementation:**
```swift
var cardColumns: [GridItem] {
    let count = gameState.players.count
    let columnCount: Int = count <= 4 ? 2 : (count <= 6 ? 3 : 4)
    return Array(repeating: GridItem(.flexible(minimum: 80), spacing: 12), count: columnCount)
}

LazyVGrid(columns: cardColumns, spacing: 12) {
    ForEach(gameState.cards.indices, id: \.self) { index in
        CardView(...)
    }
}
```

---

### Decision 3: State Management Pattern

**Decision:** @Observable class (GameScreenViewModel) + Environment (AppState)  
**Rationale:**
- @Observable is SwiftUI 4.0+ pattern, cleaner than @StateObject + @Published
- Separates UI state (screenState) from game logic (gameState)
- GameState stays a Codable struct (serializable); ViewModel is transient
- AppState remains @Environment (navigation concerns separate from game logic)

**Avoid:**
- ❌ Redux/Flux (overkill for single-turn game)
- ❌ Global singletons (violates dependency injection)
- ❌ @StateObject(GameState) in View (tightly couples UI to data model)

---

### Decision 4: Replay Mechanism

**Decision:** Mutate GameState in-place via `resetGame()` method  
**Rationale:**
- Fast replay (user taps "Play Again" immediately)
- No allocation of new GameState struct (memory efficient)
- Preserves player names & theme from setup (user expectation for quick replay)
- Alternative (return to setup) still available via "Return to Setup" button

**Implementation:**
```swift
func resetGame() {
    let newCards = GameLogic.generateCards(playerCount: gameState.players.count, theme: gameState.selectedTheme)
    gameState.cards = newCards
    gameState.revealedCards = []
    gameState.currentPlayerIndex = 0
    gameState.gamePhase = .inGame
    screenState = .selectingCard
}
```

---

### Decision 5: Error Handling Pattern

**Decision:** Typed Errors (GameError enum) + screenState case  
**Rationale:**
- Specific error cases enable targeted user feedback (vs. generic "error")
- screenState.error(reason) allows UI to show error overlay
- Tests can assert specific error types thrown
- User can dismiss error and retry (resilient flow)

**Error Types:**
```swift
enum GameError: Error, Equatable {
    case invalidCardIndex
    case cardAlreadyLocked
    case invalidPlayerIndex
    case noCardsGenerated
}
```

**UI Handling:**
```swift
case .error(let error):
    // Show toast or modal with error message
    // Offer "Retry" or "Return to Setup" button
```

---

### Decision 6: Accessibility Approach

**Decision:** VoiceOver labels per component + Dynamic Type support  
**Rationale:**
- No external accessibility libraries needed
- SwiftUI's `.accessibilityLabel()` and `.accessibilityValue()` suffice
- Family games must be accessible to players of all abilities
- Tests can validate VoiceOver navigation (covered in Bruce's test plan)

**Implementation:**
```swift
CardView(...)
    .accessibilityLabel("Card \(cardIndex + 1)")
    .accessibilityValue(
        card.isLocked ? "locked" : 
        card.isRevealed ? "revealed, shows \(card.content.description)" :
        "face-down, available"
    )
```

---

### Decision 7: Haptic Feedback

**Decision:** Light impact feedback on card tap; success feedback on card lock  
**Rationale:**
- Provides tactile confirmation (family-friendly, accessible)
- No external dependencies (UIKit's UIImpactFeedbackGenerator is built-in)
- Helps players feel game responsiveness on lower-end devices

**Implementation:**
```swift
import UIKit

func provideFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.impactOccurred()
}

// In CardView.onTap:
onTap: {
    provideFeedback()
    viewModel.handleCardTap(index: index)
}

// In GameScreenViewModel.handleCardHide:
provideFeedback(style: .success)
gameState.lockCard(at: index)
```

---

## 7. Testing Plan (for Bruce Banner)

### Unit Tests

**GameScreenViewModel:**
```swift
func testSelectCard_ValidIndex_UpdatesGameState() {
    // Arrange
    let viewModel = GameScreenViewModel(playerCount: 2, playerNames: ["A", "B"], theme: "Place")
    
    // Act
    viewModel.handleCardTap(index: 0)
    
    // Assert
    XCTAssertTrue(viewModel.gameState.cards[0].isRevealed)
    XCTAssertEqual(viewModel.screenState, .cardRevealed)
}

func testSelectCard_LockedCard_ThrowsError() {
    // Arrange
    var gameState = GameState(players: [Player(name: "A", role: .normal)], theme: "Place", word: "Paris")
    try gameState.lockCard(at: 0)
    
    // Act & Assert
    XCTAssertThrowsError(try gameState.selectCard(at: 0, byPlayer: 0)) { error in
        XCTAssertEqual(error as? GameError, .cardAlreadyLocked)
    }
}

func testLockCard_UpdatesRevealedSet() {
    // Arrange
    let viewModel = GameScreenViewModel(playerCount: 2, playerNames: ["A", "B"], theme: "Place")
    viewModel.handleCardTap(index: 0)
    
    // Act
    viewModel.handleCardHide(index: 0)
    
    // Assert
    XCTAssertTrue(viewModel.gameState.revealedCards.contains(0))
    XCTAssertTrue(viewModel.gameState.cards[0].isLocked)
}

func testIsGameComplete_AllCardsLocked_ReturnsTrue() {
    // Arrange
    let viewModel = GameScreenViewModel(playerCount: 2, playerNames: ["A", "B"], theme: "Place")
    
    // Act: Lock all cards
    for i in 0..<viewModel.gameState.cards.count {
        viewModel.handleCardTap(index: i)
        viewModel.handleCardHide(index: i)
    }
    
    // Assert
    XCTAssertTrue(viewModel.gameState.isGameComplete())
    XCTAssertEqual(viewModel.screenState, .gameOver)
}

func testNextPlayer_AdvancesCurrentPlayerIndex() {
    // Arrange
    let viewModel = GameScreenViewModel(playerCount: 3, playerNames: ["A", "B", "C"], theme: "Place")
    
    // Act
    viewModel.handleNextPlayer()
    
    // Assert
    XCTAssertEqual(viewModel.gameState.currentPlayerIndex, 1)
    XCTAssertEqual(viewModel.screenState, .selectingCard)
}

func testNextPlayer_WrapsAroundAtEnd() {
    // Arrange
    let viewModel = GameScreenViewModel(playerCount: 2, playerNames: ["A", "B"], theme: "Place")
    viewModel.gameState.currentPlayerIndex = 1
    
    // Act
    viewModel.handleNextPlayer()
    
    // Assert
    XCTAssertEqual(viewModel.gameState.currentPlayerIndex, 0)
}

func testResetGame_ClearsRevealedCardsAndState() {
    // Arrange
    let viewModel = GameScreenViewModel(playerCount: 2, playerNames: ["A", "B"], theme: "Place")
    viewModel.handleCardTap(index: 0)
    viewModel.handleCardHide(index: 0)
    
    // Act
    viewModel.resetGame()
    
    // Assert
    XCTAssertEqual(viewModel.gameState.revealedCards.count, 0)
    XCTAssertEqual(viewModel.screenState, .selectingCard)
    XCTAssertFalse(viewModel.gameState.cards[0].isLocked)
}
```

### Integration Tests

**Full Turn Flow (2–8 players):**
```swift
func testCompleteTurnFlow_TwoPlayers() {
    // Arrange
    let viewModel = GameScreenViewModel(playerCount: 2, playerNames: ["Alice", "Bob"], theme: "Place")
    
    // Act: Alice's turn
    viewModel.handleCardTap(index: 0)
    XCTAssertEqual(viewModel.screenState, .cardRevealed)
    
    viewModel.handleCardHide(index: 0)
    XCTAssertEqual(viewModel.screenState, .nextPlayerPrompt)
    
    // Act: Next player (Bob)
    viewModel.handleNextPlayer()
    XCTAssertEqual(viewModel.gameState.currentPlayerIndex, 1)
    XCTAssertEqual(viewModel.screenState, .selectingCard)
    
    // Act: Bob's turn
    viewModel.handleCardTap(index: 1)
    XCTAssertEqual(viewModel.screenState, .cardRevealed)
    
    viewModel.handleCardHide(index: 1)
    XCTAssertTrue(viewModel.gameState.isGameComplete())
    XCTAssertEqual(viewModel.screenState, .gameOver)
}

func testCompleteTurnFlow_EightPlayers() {
    // Similar pattern with 8 players, validates column responsiveness
}
```

**Error Handling:**
```swift
func testRapidRetap_CardAlreadyRevealed() {
    // Arrange
    let viewModel = GameScreenViewModel(playerCount: 2, playerNames: ["A", "B"], theme: "Place")
    viewModel.handleCardTap(index: 0)
    
    // Act: Try to tap same card again during reveal (should be blocked)
    // This depends on UI state management; screenState prevents re-tap
    
    // Assert
    XCTAssertEqual(viewModel.screenState, .cardRevealed)
    // View should ignore taps while cardRevealing or cardLocking
}

func testOutOfTurnInteraction_Handled() {
    // Arrange
    let viewModel = GameScreenViewModel(playerCount: 2, playerNames: ["A", "B"], theme: "Place")
    
    // Act: View logic should prevent wrong player from tapping
    // (Enforced by CardView's isInteractable check)
    
    // Assert
    XCTAssertEqual(viewModel.gameState.currentPlayerIndex, 0)
}
```

### UI State Machine Tests

```swift
func testStateTransitions_Exhaustive() {
    // Test all legal paths:
    // selectingCard → cardRevealing → cardRevealed → cardHiding → cardLocked
    //   → [gameComplete? gameOver : nextPlayerPrompt → selectingCard]
    
    let viewModel = GameScreenViewModel(playerCount: 2, playerNames: ["A", "B"], theme: "Place")
    
    // Path 1: Normal flow
    XCTAssertEqual(viewModel.screenState, .selectingCard)
    viewModel.handleCardTap(index: 0)
    // (cardRevealing is brief, may not be observable)
    XCTAssertEqual(viewModel.screenState, .cardRevealed)
    viewModel.handleCardHide(index: 0)
    XCTAssertEqual(viewModel.screenState, .nextPlayerPrompt)
    viewModel.handleNextPlayer()
    XCTAssertEqual(viewModel.screenState, .selectingCard)
}
```

### Accessibility Tests

```swift
func testVoiceOver_CardLabels() {
    // Verify CardView accessibility labels are set correctly
    let card = Card(id: UUID(), content: .word("Paris"), isRevealed: false, isLocked: false)
    let view = CardView(card: card, cardIndex: 0, onTap: { _ in }, isCurrentPlayerTurn: true, gameScreenState: .selectingCard)
    
    // Assert accessibility hierarchy
    // (Use XCTest accessibility APIs or manual VoiceOver testing)
}

func testVoiceOver_TurnIndicator() {
    // Verify turn indicator announces player and round progress
}

func testDynamicType_CardText() {
    // Verify card content (word, "SPY!") scales with Dynamic Type
}
```

### Performance Tests

```swift
func testCardGrid_ScrollPerformance_EightPlayers() {
    // Measure frame rate while scrolling LazyVGrid with 8 cards
    // Target: ≥55 FPS on iPhone 13+, ≥45 FPS on iPhone 11
}

func testMemory_GameState_Growth() {
    // Verify memory usage is stable across multiple resets
    // Target: <10 MB for all card states
}
```

### Family-Safety Tests

```swift
func testGameContent_NoInappropriateWords() {
    // Verify all card words (from themes.json) are family-friendly
    // (Manual review, but can be automated via word list validation)
}
```

---

## 8. Constraints & Notes

### Architecture Constraints

1. **No External Dependencies:** SwiftUI-only, no CocoaPods/SPM additions
2. **Portrait-Only (MVP):** LazyVGrid works portrait; landscape deferred to Phase 3
3. **Minimum iOS:** Match Phase 1 (iOS 15+, likely)
4. **No Networking:** Local game; multiplayer deferred to Phase 3+
5. **Single Device:** Players pass phone; no online sync

### Family-First Design

1. **Large Tap Targets:** 80×120 pt cards, 48 pt buttons (exceed Apple guidelines)
2. **Clear Feedback:** Card flip animation, haptic feedback, text prompts
3. **No Harsh Errors:** Locked card re-tap → silent ignore (no red error modal)
4. **Accessibility:** VoiceOver + Dynamic Type + high contrast (inherited from Phase 1)

### Performance Notes

- LazyVGrid defers rendering off-screen cards (handles 8-player games smoothly)
- Card flip animation is 0.3s (60 FPS on iPhone 13+, smooth on iPhone 11)
- No timers or async work other than card reveal dwell (1.5s auto-hide)

---

## 9. Deliverables Checklist

### For Natasha Romanoff (Frontend)

- [ ] GameScreenView.swift (layout, card grid, turn indicator)
- [ ] CardView.swift (face-down, revealed, locked states)
- [ ] CardBackView.swift (blue back, "?" symbol)
- [ ] CardFrontView.swift (word or "SPY!" text)
- [ ] TurnIndicatorView.swift (player + round display)
- [ ] ActionPromptArea.swift (context-aware text/buttons)
- [ ] EndGameView.swift (game-over modal, Play Again / Return buttons)
- [ ] GameScreenContainer.swift (coordinate GameScreenView + EndGameView)
- [ ] VoiceOver labels and hints for all components
- [ ] Dynamic Type support (all text scales)
- [ ] Haptic feedback integration (card tap, card lock)

### For Tony Stark (Backend/Logic)

- [ ] GameScreenViewModel.swift (state mutations, error handling)
- [ ] Implement `GameScreenViewModel.handleCardTap(index:)` method
- [ ] Implement `GameScreenViewModel.handleCardHide(index:)` method
- [ ] Implement `GameScreenViewModel.handleNextPlayer()` method
- [ ] Implement `GameScreenViewModel.resetGame()` method
- [ ] Wire GameLogic methods (generateCards, selectRandomWord)
- [ ] Ensure GameState mutations are consistent (selectCard ↔ lockCard)
- [ ] Error handling: typed GameError + screenState.error case
- [ ] Auto-hide timer: configurable delay (1.5s default)

### For Bruce Banner (Testing)

- [ ] Unit tests: GameScreenViewModel methods
- [ ] Integration tests: full turn flows (2–8 players)
- [ ] State machine tests: all legal transitions
- [ ] Error handling tests: invalid inputs, recovery
- [ ] Accessibility tests: VoiceOver labels, Dynamic Type
- [ ] Performance tests: frame rate, memory usage
- [ ] Manual playtesting: feel, family appeal, edge cases

---

## 10. Risk Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|---|---|---|
| LazyVGrid layout breaks on iPad | Medium | High | Portrait-only (Phase 1 constraint); iPad comes Phase 3 |
| Card animation jank on older devices | Low | Medium | Test on iPhone 11; optimize if needed (Phase 3) |
| Auto-hide timer conflict with manual hide | Low | Medium | Invalidate timer in handleCardHide; test rapid interactions |
| VoiceOver navigation confusing | Medium | High | Test with accessibility tools; iterate if needed |
| Player wraparound edge case (8 → 0) | Low | Low | Unit test nextPlayer() with 2 and 8 players |
| Touch target too small | Low | High | Design spec: 80×120 pt minimum; QA validates |

---

## Sign-Off

✅ **Architecture is approved and ready for team execution**

This design provides:
- **Zero blockers** for parallel work (Natasha, Tony, Bruce can start simultaneously)
- **Clear separation of concerns** (UI, Logic, Testing)
- **Testable state machine** (exhaustive unit + integration test coverage)
- **Family-first UX** (large targets, clear feedback, accessible)
- **No new dependencies** (SwiftUI-native proven in Phase 1)

**Next Steps:**
1. Natasha: Start GameScreenView implementation (target: 2–3 days)
2. Tony: Implement GameScreenViewModel (target: 2–3 days)
3. Bruce: Write integration + state machine tests in parallel (target: 2–3 days)
4. All: Integration testing, bug fixes (target: 1–2 days)

**Target Phase 2 Completion:** End of Week 2 (all core gameplay functional)

---

**Questions for the team?** Post in #phase-2-architecture on Slack, or reach out to Steve Rogers directly.
