import Foundation

enum GamePhase: String, Codable {
    case setup
    case inGame
    case endGame
}

struct GameState: Codable, Equatable {
    var gamePhase: GamePhase = .setup
    var players: [Player] = []
    var currentPlayerIndex: Int = 0
    var cards: [Card] = []
    var revealedCards: Set<Int> = []
    var selectedTheme: String = ""
    var selectedWord: String = ""
    var gameStartTime: Date?
    var previouslySelectedWord: String?
    
    init() {}
    
    init(players: [Player], theme: String, word: String) {
        self.players = players
        self.selectedTheme = theme
        self.selectedWord = word
        self.gamePhase = .inGame
        self.gameStartTime = Date()
    }
    
    // MARK: - Original Phase 1 Methods (kept for compatibility)
    
    mutating func selectCard(at index: Int, byPlayer playerIndex: Int) throws -> CardContent {
        guard index >= 0 && index < cards.count else {
            throw GameError.invalidCardIndex
        }
        guard !cards[index].isLocked else {
            throw GameError.cardAlreadyLocked
        }
        guard playerIndex >= 0 && playerIndex < players.count else {
            throw GameError.invalidPlayerIndex
        }
        
        cards[index].isRevealed = true
        return cards[index].content
    }
    
    mutating func nextPlayer() {
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
    }
    
    func isGameComplete() -> Bool {
        guard !cards.isEmpty else { return false }
        return revealedCards.count == cards.count
    }
    
    // MARK: - Phase 2: Enhanced Turn-Based Mechanics
    
    /// Reveals a card at the specified index (first tap)
    /// Validates that the card is available and not already revealed
    /// - Parameter index: Index of the card to reveal
    /// - Returns: The content of the revealed card
    /// - Throws: GameError if card is invalid, locked, or already revealed
    mutating func revealCard(at index: Int) throws -> CardContent {
        guard TurnValidator.isValidCardIndex(index, in: cards.count) else {
            throw GameError.invalidCardIndex
        }
        
        guard TurnValidator.canRevealCard(cards[index]) else {
            if cards[index].isLocked {
                throw GameError.cardAlreadyLocked
            }
            if cards[index].isRevealed {
                throw GameError.cardAlreadyRevealed
            }
            throw GameError.cardUnavailable
        }
        
        cards[index].isRevealed = true
        return cards[index].content
    }
    
    /// Hides a card that is currently revealed (second tap)
    /// Card transitions from revealed to locked, preventing reopening
    /// - Parameter index: Index of the card to hide
    /// - Throws: GameError if card is not revealed or is invalid
    mutating func hideCard(at index: Int) throws {
        guard TurnValidator.isValidCardIndex(index, in: cards.count) else {
            throw GameError.invalidCardIndex
        }
        
        guard TurnValidator.canHideCard(cards[index]) else {
            throw GameError.cardNotRevealed
        }
        
        cards[index].isRevealed = false
    }
    
    /// Locks a card that is currently revealed
    /// Locked cards cannot be reopened by any player
    /// - Parameter index: Index of the card to lock
    /// - Throws: GameError if card is not revealed or is invalid
    mutating func lockCard(at index: Int) throws {
        guard TurnValidator.isValidCardIndex(index, in: cards.count) else {
            throw GameError.invalidCardIndex
        }
        
        guard TurnValidator.canLockCard(cards[index]) else {
            throw GameError.cardNotRevealed
        }
        
        cards[index].isLocked = true
        cards[index].isRevealed = false
        revealedCards.insert(index)
    }
    
    /// Advances to the next player in turn order
    /// Wraps around from last player back to first
    mutating func advanceToNextPlayer() {
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
    }
    
    /// Checks if all cards have been locked (game is over)
    /// - Returns: true if every card in the game is locked
    func checkGameComplete() -> Bool {
        guard !cards.isEmpty else { return false }
        return cards.allSatisfy { $0.isLocked }
    }
    
    /// Resets the game state for a replay with the same players and theme
    /// Generates new spy position and random word from the theme
    /// Excludes the previously selected word to prevent consecutive games with the same word
    /// - Returns: A fresh GameState ready to play
    /// - Throws: GameError if card generation fails or theme is invalid
    mutating func resetGameState() throws {
        // Keep: players, selectedTheme
        // Reset: cards (new spy position), selectedWord (new random word), gamePhase, currentPlayerIndex
        
        guard !selectedTheme.isEmpty else {
            throw GameError.invalidTheme
        }
        
        // Generate new word from theme, excluding the previously selected word
        selectedWord = try GameLogic.selectRandomWord(from: selectedTheme, excluding: previouslySelectedWord)
        
        // Store the newly selected word as the previous selection for next game
        previouslySelectedWord = selectedWord
        
        // Generate new cards with new spy position
        cards = try GameLogic.generateCards(
            playerCount: players.count,
            theme: selectedTheme,
            word: selectedWord
        )
        
        // Reset game state
        currentPlayerIndex = 0
        revealedCards.removeAll()
        gamePhase = .inGame
        gameStartTime = Date()
    }
    
    /// Performs a card tap and returns the result
    /// This is the main method for UI to call - handles all state transitions atomically
    /// - Parameters:
    ///   - index: Index of the card being tapped
    ///   - playerIndex: Index of the current player tapping the card
    /// - Returns: TapResult enum indicating what happened (revealed, locked, hidden, or invalid)
    mutating func performCardTap(at index: Int, player playerIndex: Int) -> TapResult {
        // Validate indices
        guard TurnValidator.isValidCardIndex(index, in: cards.count) else {
            return .invalid(error: "Invalid card index")
        }
        
        guard TurnValidator.isValidPlayerIndex(playerIndex, in: players.count) else {
            return .invalid(error: "Invalid player index")
        }
        
        // Check if card is locked
        guard !cards[index].isLocked else {
            return .locked(message: "This card has already been used")
        }
        
        // If card is already revealed, hide it (second tap)
        if cards[index].isRevealed {
            do {
                try hideCard(at: index)
                return .hidden
            } catch {
                return .invalid(error: "Could not hide card: \(error.localizedDescription)")
            }
        }
        
        // If card is not revealed, reveal it (first tap)
        do {
            let content = try revealCard(at: index)
            return .revealed(content)
        } catch {
            return .invalid(error: "Could not reveal card: \(error.localizedDescription)")
        }
    }
}

enum GameError: Error, Equatable {
    case invalidCardIndex
    case cardAlreadyLocked
    case cardAlreadyRevealed
    case cardNotRevealed
    case cardUnavailable
    case invalidPlayerIndex
    case noCardsGenerated
    case invalidTheme
}
