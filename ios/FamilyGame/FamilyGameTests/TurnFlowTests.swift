import XCTest
@testable import FamilyGame

final class TurnFlowTests: XCTestCase {
    
    // MARK: - Card Reveal Sequence Tests
    
    /// Test complete reveal and lock sequence
    func testCompleteRevealAndLockSequence() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob"),
            Player(name: "Charlie")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 3, word: "Tokyo")
        
        // Alice reveals first card
        let content1 = try gameState.selectCard(at: 0, byPlayer: 0)
        XCTAssertTrue(gameState.cards[0].isRevealed)
        XCTAssertFalse(gameState.cards[0].isLocked)
        
        // Alice locks card
        try gameState.lockCard(at: 0)
        XCTAssertFalse(gameState.cards[0].isRevealed)
        XCTAssertTrue(gameState.cards[0].isLocked)
        
        // Move to next player
        gameState.nextPlayer()
        XCTAssertEqual(gameState.currentPlayerIndex, 1)
        
        // Bob reveals a different card
        let content2 = try gameState.selectCard(at: 1, byPlayer: 1)
        XCTAssertTrue(gameState.cards[1].isRevealed)
        XCTAssertFalse(gameState.cards[1].isLocked)
    }
    
    /// Test player cannot select same card twice in one turn
    func testPlayerCannotSelectSameCardTwice() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1"), Player(name: "Player 2")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "London")
        
        // First selection
        _ = try gameState.selectCard(at: 0, byPlayer: 0)
        
        // Lock the card
        try gameState.lockCard(at: 0)
        
        // Try to select same card again
        XCTAssertThrowsError(try gameState.selectCard(at: 0, byPlayer: 0))
    }
    
    // MARK: - Multi-Player Turn Progression
    
    /// Test turn progression through all players
    func testTurnProgressionThroughAllPlayers() {
        var gameState = GameState()
        let players = (1...4).map { Player(name: "Player \($0)") }
        gameState.players = players
        
        for expectedIndex in 0..<4 {
            XCTAssertEqual(gameState.currentPlayerIndex, expectedIndex,
                          "Should be on Player \(expectedIndex + 1)")
            gameState.nextPlayer()
        }
        
        // After completing full rotation, should be back at start
        XCTAssertEqual(gameState.currentPlayerIndex, 0, "Should wrap around to Player 1")
    }
    
    /// Test turn progression across multiple rounds
    func testTurnProgressionMultipleRounds() {
        var gameState = GameState()
        let players = (1...3).map { Player(name: "Player \($0)") }
        gameState.players = players
        gameState.currentPlayerIndex = 0
        
        let expectedSequence = [0, 1, 2, 0, 1, 2, 0]
        
        for expected in expectedSequence {
            XCTAssertEqual(gameState.currentPlayerIndex, expected)
            gameState.nextPlayer()
        }
    }
    
    // MARK: - Card Locking Persistence
    
    /// Test locked cards remain locked across turns
    func testLockedCardsPersistAcrossTurns() throws {
        var gameState = GameState()
        let players = (1...3).map { Player(name: "Player \($0)") }
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 3, word: "Paris")
        
        // Player 1 reveals and locks card 0
        _ = try gameState.selectCard(at: 0, byPlayer: 0)
        try gameState.lockCard(at: 0)
        let isLockedAfterTurn1 = gameState.cards[0].isLocked
        
        // Move through several turns
        for _ in 0..<5 {
            gameState.nextPlayer()
        }
        
        // Card should still be locked
        XCTAssertTrue(isLockedAfterTurn1 && gameState.cards[0].isLocked,
                     "Card should remain locked across multiple turns")
    }
    
    /// Test multiple cards can be locked simultaneously
    func testMultipleCardsLockedSimultaneously() throws {
        var gameState = GameState()
        let players = (1...4).map { Player(name: "Player \($0)") }
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 4, word: "Word")
        
        // Lock cards 0 and 2
        _ = try gameState.selectCard(at: 0, byPlayer: 0)
        try gameState.lockCard(at: 0)
        
        gameState.nextPlayer()
        
        _ = try gameState.selectCard(at: 2, byPlayer: 1)
        try gameState.lockCard(at: 2)
        
        XCTAssertTrue(gameState.cards[0].isLocked)
        XCTAssertTrue(gameState.cards[2].isLocked)
        XCTAssertFalse(gameState.cards[1].isLocked)
        XCTAssertFalse(gameState.cards[3].isLocked)
    }
    
    // MARK: - Game State Transitions
    
    /// Test game transitions from partial to complete state
    func testGameStateTransitionFromPartialToComplete() throws {
        var gameState = GameState()
        let players = (1...3).map { Player(name: "Player \($0)") }
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 3, word: "Word")
        
        // After 0 cards locked
        XCTAssertFalse(gameState.isGameComplete())
        
        // Lock first card
        _ = try gameState.selectCard(at: 0, byPlayer: 0)
        try gameState.lockCard(at: 0)
        XCTAssertFalse(gameState.isGameComplete())
        
        // Lock second card
        gameState.nextPlayer()
        _ = try gameState.selectCard(at: 1, byPlayer: 1)
        try gameState.lockCard(at: 1)
        XCTAssertFalse(gameState.isGameComplete())
        
        // Lock final card
        gameState.nextPlayer()
        _ = try gameState.selectCard(at: 2, byPlayer: 2)
        try gameState.lockCard(at: 2)
        XCTAssertTrue(gameState.isGameComplete())
    }
    
    // MARK: - Card Content Preservation
    
    /// Test that card content is preserved through reveal/lock cycle
    func testCardContentPreservedThroughCycle() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "TestWord")
        
        let originalContent = gameState.cards[0].content
        
        // Reveal and lock
        _ = try gameState.selectCard(at: 0, byPlayer: 0)
        try gameState.lockCard(at: 0)
        
        // Content should be unchanged
        XCTAssertEqual(gameState.cards[0].content, originalContent,
                      "Card content should be preserved after reveal/lock cycle")
    }
    
    /// Test spy card content is correctly preserved
    func testSpyCardContentPreserved() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 3, word: "Paris")
        
        // Find spy card
        if let spyIndex = gameState.cards.firstIndex(where: { 
            if case .spy = $0.content { return true }
            return false
        }) {
            let content = try gameState.selectCard(at: spyIndex, byPlayer: 0)
            
            if case .spy = content {
                XCTAssertTrue(true)
            } else {
                XCTFail("Revealed card should be spy")
            }
            
            try gameState.lockCard(at: spyIndex)
            
            if case .spy = gameState.cards[spyIndex].content {
                XCTAssertTrue(true)
            } else {
                XCTFail("Locked card should still be spy")
            }
        } else {
            XCTFail("Should have found spy card")
        }
    }
    
    // MARK: - Edge Cases
    
    /// Test behavior with 2 players (minimum)
    func testMinimumPlayerTurnFlow() throws {
        var gameState = GameState()
        let players = [Player(name: "Alice"), Player(name: "Bob")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Cairo")
        
        XCTAssertEqual(gameState.currentPlayerIndex, 0)
        gameState.nextPlayer()
        XCTAssertEqual(gameState.currentPlayerIndex, 1)
        gameState.nextPlayer()
        XCTAssertEqual(gameState.currentPlayerIndex, 0)
    }
    
    /// Test behavior with 8 players (maximum)
    func testMaximumPlayerTurnFlow() throws {
        var gameState = GameState()
        let players = (1...8).map { Player(name: "Player \($0)") }
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 8, word: "Word")
        
        for i in 0..<8 {
            XCTAssertEqual(gameState.currentPlayerIndex, i)
            gameState.nextPlayer()
        }
        XCTAssertEqual(gameState.currentPlayerIndex, 0)
    }
    
    /// Test all cards in large game can be locked
    func testAllCardsCanBeLockedInLargeGame() throws {
        var gameState = GameState()
        let players = (1...8).map { Player(name: "Player \($0)") }
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 8, word: "Word")
        
        for i in 0..<8 {
            _ = try gameState.selectCard(at: i, byPlayer: i % 8)
            try gameState.lockCard(at: i)
            gameState.nextPlayer()
        }
        
        XCTAssertTrue(gameState.isGameComplete())
    }
    
    // MARK: - Card Availability Tests
    
    /// Test all cards start as available
    func testAllCardsStartAsAvailable() {
        var gameState = GameState()
        let players = (1...4).map { Player(name: "Player \($0)") }
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 4, word: "Word")
        
        let availableCards = gameState.cards.filter { !$0.isLocked }
        XCTAssertEqual(availableCards.count, 4)
    }
    
    /// Test available card count decreases as cards are locked
    func testAvailableCardCountDecreases() throws {
        var gameState = GameState()
        let players = (1...5).map { Player(name: "Player \($0)") }
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 5, word: "Word")
        
        for i in 0..<5 {
            let availableBefore = gameState.cards.filter { !$0.isLocked }.count
            
            _ = try gameState.selectCard(at: i, byPlayer: i % 5)
            try gameState.lockCard(at: i)
            
            let availableAfter = gameState.cards.filter { !$0.isLocked }.count
            XCTAssertEqual(availableAfter, availableBefore - 1)
        }
    }
    
    // MARK: - Sequence Verification
    
    /// Test a complete game sequence
    func testCompleteGameSequence() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob"),
            Player(name: "Charlie")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 3, word: "Barcelona")
        
        // Game setup
        XCTAssertFalse(gameState.isGameComplete())
        XCTAssertEqual(gameState.currentPlayerIndex, 0)
        
        // Round 1: Each player selects a card
        for turn in 0..<3 {
            XCTAssertEqual(gameState.currentPlayerIndex, turn)
            
            _ = try gameState.selectCard(at: turn, byPlayer: turn)
            XCTAssertTrue(gameState.cards[turn].isRevealed)
            
            try gameState.lockCard(at: turn)
            XCTAssertTrue(gameState.cards[turn].isLocked)
            XCTAssertFalse(gameState.cards[turn].isRevealed)
            
            gameState.nextPlayer()
        }
        
        // Game should be complete
        XCTAssertTrue(gameState.isGameComplete())
    }
    
    /// Test that all revealed cards during game are tracked
    func testAllRevealedCardsTracked() throws {
        var gameState = GameState()
        let players = (1...4).map { Player(name: "Player \($0)") }
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 4, word: "Word")
        
        var revealedIndices: Set<Int> = []
        
        for i in 0..<4 {
            _ = try gameState.selectCard(at: i, byPlayer: i)
            revealedIndices.insert(i)
            try gameState.lockCard(at: i)
        }
        
        XCTAssertEqual(gameState.revealedCards, revealedIndices)
    }
    
    // MARK: - Helper Functions
    
    private func generateTestCards(playerCount: Int, word: String) -> [Card] {
        var cards: [Card] = []
        
        for _ in 0..<(playerCount - 1) {
            let card = Card(content: .word(word), isRevealed: false, isLocked: false)
            cards.append(card)
        }
        
        let spyPosition = Int.random(in: 0...playerCount - 1)
        let spyCard = Card(content: .spy, isRevealed: false, isLocked: false)
        cards.insert(spyCard, at: spyPosition)
        
        return cards
    }
}
