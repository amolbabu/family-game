import XCTest
@testable import FamilyGame

/// Integration tests for turn mechanics and player progression
/// Tests card reveal/hide/lock transitions and turn advancement logic
final class TurnMechanicsIntegrationTests: XCTestCase {
    
    // MARK: - Card State Transitions
    
    /// Test card state progression: revealed → locked
    func testCardStateTransition() throws {
        var gameState = GameState()
        let players = [Player(name: "Alice")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Rome")
        
        let card = gameState.cards[0]
        
        // Initial state
        XCTAssertFalse(card.isRevealed, "Card should start unrevealed")
        XCTAssertFalse(card.isLocked, "Card should start unlocked")
        
        // After reveal
        _ = try gameState.selectCard(at: 0, byPlayer: 0)
        XCTAssertTrue(gameState.cards[0].isRevealed, "Card should be revealed after select")
        XCTAssertFalse(gameState.cards[0].isLocked, "Card should still be unlocked after reveal")
        
        // After lock
        try gameState.lockCard(at: 0)
        XCTAssertFalse(gameState.cards[0].isRevealed, "Card should be hidden after lock")
        XCTAssertTrue(gameState.cards[0].isLocked, "Card should be locked after lock")
    }
    
    /// Test that revealed cards are tracked correctly
    func testRevealedCardsTracking() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Madrid")
        
        XCTAssertEqual(gameState.revealedCards.count, 0, "Should start with no revealed cards")
        
        // Reveal first card
        _ = try gameState.selectCard(at: 0, byPlayer: 0)
        // Note: revealedCards is updated on lock, not on reveal
        XCTAssertEqual(gameState.revealedCards.count, 0, "revealedCards updated on lock")
        
        // Lock first card
        try gameState.lockCard(at: 0)
        XCTAssertEqual(gameState.revealedCards.count, 1, "revealedCards should have 1 card")
        XCTAssertTrue(gameState.revealedCards.contains(0), "revealedCards should contain card 0")
        
        // Reveal second card
        _ = try gameState.selectCard(at: 1, byPlayer: 1)
        XCTAssertEqual(gameState.revealedCards.count, 1, "revealedCards count unchanged after reveal")
        
        // Lock second card
        try gameState.lockCard(at: 1)
        XCTAssertEqual(gameState.revealedCards.count, 2, "revealedCards should have 2 cards")
        XCTAssertTrue(gameState.revealedCards.contains(0), "revealedCards should still contain card 0")
        XCTAssertTrue(gameState.revealedCards.contains(1), "revealedCards should contain card 1")
    }
    
    // MARK: - Player Index Wrapping
    
    /// Test that player index wraps correctly for 2 players
    func testPlayerIndexWrapAround2Players() {
        var gameState = GameState()
        gameState.players = [
            Player(name: "Alice"),
            Player(name: "Bob")
        ]
        
        XCTAssertEqual(gameState.currentPlayerIndex, 0)
        gameState.nextPlayer()
        XCTAssertEqual(gameState.currentPlayerIndex, 1)
        gameState.nextPlayer()
        XCTAssertEqual(gameState.currentPlayerIndex, 0, "Should wrap back to player 0")
    }
    
    /// Test that player index wraps correctly for 5 players
    func testPlayerIndexWrapAround5Players() {
        var gameState = GameState()
        gameState.players = (1...5).map { Player(name: "Player \($0)") }
        
        let expectedSequence = [0, 1, 2, 3, 4, 0, 1, 2]
        
        for expected in expectedSequence {
            XCTAssertEqual(gameState.currentPlayerIndex, expected)
            gameState.nextPlayer()
        }
    }
    
    /// Test that player index wraps correctly for 8 players (maximum)
    func testPlayerIndexWrapAround8PlayersMaximum() {
        var gameState = GameState()
        gameState.players = (1...8).map { Player(name: "Player \($0)") }
        
        // Full rotation plus extra
        for i in 0..<10 {
            let expectedIndex = i % 8
            XCTAssertEqual(gameState.currentPlayerIndex, expectedIndex,
                          "Player index should be \(expectedIndex) at iteration \(i)")
            gameState.nextPlayer()
        }
    }
    
    // MARK: - Turn Order Consistency
    
    /// Test that turn order is consistent across a full game
    func testTurnOrderConsistency() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob"),
            Player(name: "Charlie"),
            Player(name: "David")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 4, word: "Prague")
        
        let expectedTurnOrder = [0, 1, 2, 3]
        
        for (cardIndex, expectedPlayer) in expectedTurnOrder.enumerated() {
            XCTAssertEqual(gameState.currentPlayerIndex, expectedPlayer,
                          "Card \(cardIndex) should be played by Player \(expectedPlayer)")
            
            _ = try gameState.selectCard(at: cardIndex, byPlayer: expectedPlayer)
            try gameState.lockCard(at: cardIndex)
            
            gameState.nextPlayer()
        }
    }
    
    /// Test that players maintain correct turn order after errors
    func testTurnOrderAfterError() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Vienna")
        
        // Current player should be 0
        XCTAssertEqual(gameState.currentPlayerIndex, 0)
        
        // Try invalid action
        _ = try? gameState.selectCard(at: 0, byPlayer: 0)
        // Lock it
        try gameState.lockCard(at: 0)
        
        // Manually advance (app logic would do this on valid play)
        gameState.nextPlayer()
        
        // Should now be player 1
        XCTAssertEqual(gameState.currentPlayerIndex, 1)
    }
    
    // MARK: - Multiple Reveal Attempts
    
    /// Test that multiple cards can be revealed in sequence by different players
    func testMultipleCardReveals() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Player 1"),
            Player(name: "Player 2"),
            Player(name: "Player 3"),
            Player(name: "Player 4")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 4, word: "Berlin")
        
        // Each player reveals a different card
        for i in 0..<4 {
            let currentPlayer = gameState.currentPlayerIndex
            
            _ = try gameState.selectCard(at: i, byPlayer: currentPlayer)
            XCTAssertTrue(gameState.cards[i].isRevealed,
                         "Card \(i) should be revealed by Player \(currentPlayer)")
            
            try gameState.lockCard(at: i)
            gameState.nextPlayer()
        }
        
        // All cards should be locked
        let allLocked = gameState.cards.allSatisfy { $0.isLocked }
        XCTAssertTrue(allLocked, "All cards should be locked after full game")
    }
    
    // MARK: - Rapid Turns
    
    /// Test rapid consecutive turns work correctly
    func testRapidConecutiveTurns() throws {
        var gameState = GameState()
        let players = (1...3).map { Player(name: "Player \($0)") }
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 3, word: "London")
        
        // Simulate rapid play
        for cardIndex in 0..<3 {
            _ = try gameState.selectCard(at: cardIndex, byPlayer: gameState.currentPlayerIndex)
            try gameState.lockCard(at: cardIndex)
            gameState.nextPlayer()
        }
        
        XCTAssertTrue(gameState.isGameComplete())
    }
    
    // MARK: - Game State Integrity During Turn Flow
    
    /// Test that game state remains consistent throughout a full game
    func testGameStateIntegrityFullGame() throws {
        var gameState = GameState()
        let players = (1...4).map { Player(name: "Player \($0)") }
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 4, word: "Dublin")
        
        let initialPlayerCount = gameState.players.count
        let initialCardCount = gameState.cards.count
        
        // Play complete game
        for i in 0..<4 {
            let playerBeforeTurn = gameState.currentPlayerIndex
            
            _ = try gameState.selectCard(at: i, byPlayer: playerBeforeTurn)
            try gameState.lockCard(at: i)
            
            // Verify state hasn't been corrupted
            XCTAssertEqual(gameState.players.count, initialPlayerCount)
            XCTAssertEqual(gameState.cards.count, initialCardCount)
            
            gameState.nextPlayer()
        }
        
        // Final verification
        XCTAssertTrue(gameState.isGameComplete())
        XCTAssertEqual(gameState.players.count, initialPlayerCount)
        XCTAssertEqual(gameState.cards.count, initialCardCount)
    }
    
    /// Test that single-card reveals between locks work correctly
    func testSingleCardRevealBetweenLocks() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 3, word: "Athens")
        
        // Sequence: reveal, lock, reveal, lock, reveal, lock
        for cardIndex in 0..<3 {
            XCTAssertEqual(gameState.currentPlayerIndex, cardIndex % 2)
            
            // Reveal
            let content = try gameState.selectCard(at: cardIndex, byPlayer: gameState.currentPlayerIndex)
            XCTAssertTrue(gameState.cards[cardIndex].isRevealed)
            
            // Verify we can see the content
            switch content {
            case .word(let word):
                XCTAssertEqual(word, "Athens")
            case .spy:
                XCTAssertTrue(true, "Spy card revealed")
            }
            
            // Lock
            try gameState.lockCard(at: cardIndex)
            XCTAssertTrue(gameState.cards[cardIndex].isLocked)
            
            gameState.nextPlayer()
        }
        
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
