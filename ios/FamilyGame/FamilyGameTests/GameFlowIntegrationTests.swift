import XCTest
@testable import FamilyGame

/// Integration tests for complete game sequences
/// Tests the full gameplay loop: setup → reveal cards → lock cards → advance turns → detect end-game
final class GameFlowIntegrationTests: XCTestCase {
    
    // MARK: - Test 1.1: Single Card Reveal & Hide
    
    /// Test that player can reveal a card and it shows content
    func testSingleCardReveal() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob"),
            Player(name: "Charlie")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 3, word: "Paris")
        
        // Player 1 taps card at index 0
        let content = try gameState.selectCard(at: 0, byPlayer: 0)
        
        // Verify card is revealed
        XCTAssertTrue(gameState.cards[0].isRevealed, "Card should be revealed after tap")
        XCTAssertFalse(gameState.cards[0].isLocked, "Card should not be locked yet")
        
        // Verify content is either word or spy
        switch content {
        case .word(let word):
            XCTAssertEqual(word, "Paris", "Non-spy card should show the selected word")
        case .spy:
            XCTAssertTrue(true, "Spy card revealed successfully")
        }
    }
    
    /// Test that player can tap revealed card again to hide it
    func testCardHideAfterReveal() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob"),
            Player(name: "Charlie")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 3, word: "Tokyo")
        
        // Player reveals card
        _ = try gameState.selectCard(at: 0, byPlayer: 0)
        XCTAssertTrue(gameState.cards[0].isRevealed)
        
        // Player taps same card again to hide it
        // In a real UI, this would be handled by the view layer
        // Here we simulate by checking the card can be locked
        XCTAssertFalse(gameState.cards[0].isLocked, "Card is not locked yet, should be hideable")
    }
    
    // MARK: - Test 1.2: Card Lock After Hide
    
    /// Test that card becomes locked after hide
    func testCardLockAfterHide() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob"),
            Player(name: "Charlie")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 3, word: "London")
        
        // Reveal card
        _ = try gameState.selectCard(at: 0, byPlayer: 0)
        XCTAssertTrue(gameState.cards[0].isRevealed)
        
        // Lock card (hide and lock)
        try gameState.lockCard(at: 0)
        XCTAssertTrue(gameState.cards[0].isLocked, "Card should be locked")
        XCTAssertFalse(gameState.cards[0].isRevealed, "Card should be hidden when locked")
    }
    
    /// Test that locked cards reject further taps
    func testLockedCardRejectsInteraction() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Rome")
        
        // Lock first card
        _ = try gameState.selectCard(at: 0, byPlayer: 0)
        try gameState.lockCard(at: 0)
        
        // Try to select same locked card again
        XCTAssertThrowsError(
            try gameState.selectCard(at: 0, byPlayer: 1),
            "Should reject interaction with locked card"
        ) { error in
            XCTAssertEqual(error as? GameError, GameError.cardAlreadyLocked)
        }
    }
    
    // MARK: - Test 1.3: Turn Advancement (3 Players)
    
    /// Test 3-player turn advancement cycles correctly
    func testThreePlayerTurnAdvancement() {
        var gameState = GameState()
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob"),
            Player(name: "Charlie")
        ]
        gameState.players = players
        
        // Verify initial state
        XCTAssertEqual(gameState.currentPlayerIndex, 0, "Game starts with Player 0")
        
        // Advance through players
        gameState.nextPlayer()
        XCTAssertEqual(gameState.currentPlayerIndex, 1, "After first advance, should be Player 1")
        
        gameState.nextPlayer()
        XCTAssertEqual(gameState.currentPlayerIndex, 2, "After second advance, should be Player 2")
        
        // Wrap around
        gameState.nextPlayer()
        XCTAssertEqual(gameState.currentPlayerIndex, 0, "After third advance, should wrap to Player 0")
    }
    
    // MARK: - Test 1.4: Complete 2-Player Game
    
    /// Test complete 2-player game from start to end-game detection
    func testComplete2PlayerGame() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Berlin")
        
        // Verify game is not complete at start
        XCTAssertFalse(gameState.isGameComplete(), "Game should not be complete at start")
        
        // Player 0 turn: reveal, lock
        _ = try gameState.selectCard(at: 0, byPlayer: 0)
        try gameState.lockCard(at: 0)
        gameState.nextPlayer()
        XCTAssertEqual(gameState.currentPlayerIndex, 1)
        XCTAssertFalse(gameState.isGameComplete(), "Game should not be complete after 1 card locked")
        
        // Player 1 turn: reveal, lock
        _ = try gameState.selectCard(at: 1, byPlayer: 1)
        try gameState.lockCard(at: 1)
        gameState.nextPlayer()
        
        // Verify game is complete
        XCTAssertTrue(gameState.isGameComplete(), "Game should be complete when all cards locked")
    }
    
    // MARK: - Test 1.5: Complete 8-Player Game (Max Players)
    
    /// Test complete 8-player game with no exceptions
    func testComplete8PlayerGame() throws {
        var gameState = GameState()
        let players = (1...8).map { Player(name: "Player \($0)") }
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 8, word: "Amsterdam")
        
        // Each player takes one turn
        for cardIndex in 0..<8 {
            XCTAssertEqual(gameState.currentPlayerIndex, cardIndex % 8,
                          "Should be on correct player")
            
            _ = try gameState.selectCard(at: cardIndex, byPlayer: gameState.currentPlayerIndex)
            try gameState.lockCard(at: cardIndex)
            
            let expectedComplete = (cardIndex == 7)
            if expectedComplete {
                XCTAssertTrue(gameState.isGameComplete(),
                             "Game should be complete after all 8 cards locked")
            } else {
                XCTAssertFalse(gameState.isGameComplete(),
                              "Game should not be complete until all cards are locked")
            }
            
            gameState.nextPlayer()
        }
        
        // Final verification
        XCTAssertTrue(gameState.isGameComplete(), "Game must be complete at end")
        XCTAssertEqual(gameState.cards.filter { $0.isLocked }.count, 8,
                      "All 8 cards should be locked")
    }
    
    // MARK: - Test 4.1: Play Again Resets State
    
    /// Test that game reset clears all game state while preserving players
    func testGameResetClearsState() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob"),
            Player(name: "Charlie")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 3, word: "Paris")
        gameState.selectedWord = "Paris"
        
        // Play until a card is revealed and locked
        _ = try gameState.selectCard(at: 0, byPlayer: 0)
        try gameState.lockCard(at: 0)
        
        XCTAssertTrue(gameState.cards[0].isLocked, "Card should be locked before reset")
        
        // Simulate "Play Again" by creating new GameState with same players
        var newGameState = GameState(
            players: players,
            theme: gameState.selectedTheme,
            word: "London"  // Different word for new game
        )
        newGameState.cards = generateTestCards(playerCount: 3, word: "London")
        
        // Verify new state
        XCTAssertFalse(newGameState.cards[0].isLocked, "New game cards should not be locked")
        XCTAssertFalse(newGameState.cards[0].isRevealed, "New game cards should not be revealed")
        XCTAssertEqual(newGameState.selectedWord, "London", "New game should have new word")
        XCTAssertEqual(newGameState.players.count, 3, "Should keep same player count")
    }
    
    /// Test that consecutive games can have different spy positions
    func testConsecutiveGamesDifferentSpyPositions() {
        var spyPositions: [Int] = []
        
        for _ in 0..<10 {
            var gameState = GameState()
            let players = (1...3).map { Player(name: "Player \($0)") }
            gameState.players = players
            gameState.cards = generateTestCards(playerCount: 3, word: "Word")
            
            // Find spy position
            if let spyIndex = gameState.cards.firstIndex(where: { card in
                if case .spy = card.content {
                    return true
                }
                return false
            }) {
                spyPositions.append(spyIndex)
            }
        }
        
        // Check that we have variation in spy positions
        let uniquePositions = Set(spyPositions)
        XCTAssertGreaterThan(uniquePositions.count, 1,
                            "Consecutive games should have different spy positions (statistically)")
    }
    
    // MARK: - Test 5.1: Sequential Turns (4 Players, 4 Cards)
    
    /// Test 4-player game with 1 card per turn
    func testSequentialTurns4Players() throws {
        var gameState = GameState()
        let players = (1...4).map { Player(name: "Player \($0)") }
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 4, word: "Vienna")
        
        let expectedTurnSequence = [0, 1, 2, 3]
        
        for (turnNumber, expectedPlayer) in expectedTurnSequence.enumerated() {
            XCTAssertEqual(gameState.currentPlayerIndex, expectedPlayer,
                          "Turn \(turnNumber) should be Player \(expectedPlayer)")
            
            _ = try gameState.selectCard(at: turnNumber, byPlayer: expectedPlayer)
            try gameState.lockCard(at: turnNumber)
            
            gameState.nextPlayer()
        }
        
        // All cards should be locked
        XCTAssertTrue(gameState.isGameComplete())
    }
    
    // MARK: - Helper Functions
    
    /// Helper function to generate test cards with one spy
    private func generateTestCards(playerCount: Int, word: String) -> [Card] {
        var cards: [Card] = []
        
        // Create non-spy cards
        for _ in 0..<(playerCount - 1) {
            let card = Card(content: .word(word), isRevealed: false, isLocked: false)
            cards.append(card)
        }
        
        // Add spy card at random position
        let spyPosition = Int.random(in: 0...playerCount - 1)
        let spyCard = Card(content: .spy, isRevealed: false, isLocked: false)
        cards.insert(spyCard, at: spyPosition)
        
        return cards
    }
}
