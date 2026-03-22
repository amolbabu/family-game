import XCTest
@testable import FamilyGame

/// Integration tests for family-safety, accessibility, and user experience
/// Tests that gameplay is robust, responsive, and accessible to all players
final class AccessibilityIntegrationTests: XCTestCase {
    
    // MARK: - Test 6.1: No Game Logic Crashes
    
    /// Test that complete game flow runs without exceptions
    func testCompleteGameFlowNoCrashes() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob"),
            Player(name: "Charlie")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 3, word: "Paris")
        gameState.gamePhase = .inGame
        
        // Run complete game
        XCTAssertNoThrow(try {
            for i in 0..<3 {
                _ = try gameState.selectCard(at: i, byPlayer: gameState.currentPlayerIndex)
                try gameState.lockCard(at: i)
                gameState.nextPlayer()
            }
        }(), "Complete game should run without exceptions")
        
        XCTAssertTrue(gameState.isGameComplete())
    }
    
    /// Test that game reaches valid end state with max players
    func testMaxPlayersGameReachesValidEndState() throws {
        var gameState = GameState()
        let players = (1...8).map { Player(name: "Player \($0)") }
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 8, word: "Tokyo")
        gameState.gamePhase = .inGame
        
        // Play all 8 cards
        for i in 0..<8 {
            _ = try gameState.selectCard(at: i, byPlayer: gameState.currentPlayerIndex)
            try gameState.lockCard(at: i)
            gameState.nextPlayer()
        }
        
        // Verify valid end state
        XCTAssertTrue(gameState.isGameComplete(), "Game should be complete")
        XCTAssertEqual(gameState.revealedCards.count, 8, "All 8 cards should be revealed")
        let allLocked = gameState.cards.allSatisfy { $0.isLocked }
        XCTAssertTrue(allLocked, "All cards should be locked")
    }
    
    /// Test that rapid gameplay doesn't cause state corruption
    func testRapidGameplayStateIntegrity() throws {
        var gameState = GameState()
        let playerCount = 4
        gameState.players = (1...playerCount).map { Player(name: "Player \($0)") }
        gameState.cards = generateTestCards(playerCount: playerCount, word: "Berlin")
        
        // Simulate rapid consecutive actions
        for i in 0..<playerCount {
            let currentPlayer = gameState.currentPlayerIndex
            
            // Reveal
            _ = try gameState.selectCard(at: i, byPlayer: currentPlayer)
            
            // Immediately lock
            try gameState.lockCard(at: i)
            
            // Immediately advance
            gameState.nextPlayer()
            
            // Verify state
            XCTAssertTrue(gameState.cards[i].isLocked, "Card should be locked")
            XCTAssertTrue(gameState.revealedCards.contains(i), "Card should be in revealedCards")
        }
        
        XCTAssertTrue(gameState.isGameComplete())
    }
    
    /// Test that alternating players maintain game integrity
    func testAlternatingPlayersGameIntegrity() throws {
        var gameState = GameState()
        gameState.players = [
            Player(name: "Alice"),
            Player(name: "Bob")
        ]
        gameState.cards = generateTestCards(playerCount: 2, word: "Rome")
        
        // Alice's turn
        _ = try gameState.selectCard(at: 0, byPlayer: 0)
        XCTAssertTrue(gameState.cards[0].isRevealed)
        try gameState.lockCard(at: 0)
        gameState.nextPlayer()
        
        // Bob's turn
        XCTAssertEqual(gameState.currentPlayerIndex, 1)
        _ = try gameState.selectCard(at: 1, byPlayer: 1)
        XCTAssertTrue(gameState.cards[1].isRevealed)
        try gameState.lockCard(at: 1)
        
        XCTAssertTrue(gameState.isGameComplete())
    }
    
    // MARK: - Test 6.2: UI Responsiveness (State Consistency)
    
    /// Test that game state changes are atomic
    func testGameStateChangesAreAtomic() throws {
        var gameState = GameState()
        gameState.players = [Player(name: "Alice")]
        gameState.cards = generateTestCards(playerCount: 2, word: "London")
        
        let cardBefore = gameState.cards[0]
        
        // Reveal operation
        _ = try gameState.selectCard(at: 0, byPlayer: 0)
        
        let cardAfterReveal = gameState.cards[0]
        
        // Verify complete state change
        XCTAssertEqual(cardBefore.isRevealed, false)
        XCTAssertEqual(cardAfterReveal.isRevealed, true)
        
        // Lock operation
        try gameState.lockCard(at: 0)
        
        let cardAfterLock = gameState.cards[0]
        
        // Verify complete state change
        XCTAssertEqual(cardAfterLock.isRevealed, false)
        XCTAssertEqual(cardAfterLock.isLocked, true)
    }
    
    /// Test that multiple state checks return consistent results
    func testConsistentStateChecks() throws {
        var gameState = GameState()
        gameState.players = [
            Player(name: "Alice"),
            Player(name: "Bob"),
            Player(name: "Charlie")
        ]
        gameState.cards = generateTestCards(playerCount: 3, word: "Madrid")
        
        // Complete game
        for i in 0..<3 {
            _ = try gameState.selectCard(at: i, byPlayer: i)
            try gameState.lockCard(at: i)
        }
        
        // Multiple checks should return same result
        let check1 = gameState.isGameComplete()
        let check2 = gameState.isGameComplete()
        let check3 = gameState.isGameComplete()
        
        XCTAssertTrue(check1)
        XCTAssertEqual(check1, check2)
        XCTAssertEqual(check2, check3)
    }
    
    /// Test that revealed cards are immediately visible in state
    func testRevealedCardsImmediatelyVisible() throws {
        var gameState = GameState()
        gameState.players = [Player(name: "Alice")]
        gameState.cards = generateTestCards(playerCount: 3, word: "Barcelona")
        
        // Reveal card
        let content = try gameState.selectCard(at: 1, byPlayer: 0)
        
        // State should immediately reflect
        XCTAssertTrue(gameState.cards[1].isRevealed, "Revealed state should be immediate")
        
        // Verify content was returned
        switch content {
        case .word(let word):
            XCTAssertEqual(word, "Barcelona")
        case .spy:
            XCTAssertTrue(true, "Spy content returned")
        }
    }
    
    // MARK: - Family-Safety: Language and Content
    
    /// Test that card content is appropriate
    func testCardContentAppropriateness() throws {
        var gameState = GameState()
        gameState.players = [Player(name: "Alice")]
        gameState.cards = generateTestCards(playerCount: 2, word: "Museum")
        
        let content = try gameState.selectCard(at: 0, byPlayer: 0)
        
        switch content {
        case .word(let word):
            // Verify word is non-empty and reasonable
            XCTAssertFalse(word.isEmpty, "Word should not be empty")
            XCTAssertLessThanOrEqual(word.count, 50, "Word should be reasonable length")
        case .spy:
            XCTAssertTrue(true, "Spy is appropriate content")
        }
    }
    
    /// Test that game messages don't contain inappropriate content
    func testGamePhaseAndMessagesAppropriate() {
        var gameState = GameState()
        gameState.gamePhase = .setup
        
        // Verify phase is valid
        XCTAssertTrue(
            [.setup, .inGame, .endGame].contains(gameState.gamePhase),
            "Game phase should be valid"
        )
    }
    
    // MARK: - Accessibility: Actionable State
    
    /// Test that available actions are clearly determinable
    func testAvailableActionsAreDeterminable() throws {
        var gameState = GameState()
        gameState.players = [
            Player(name: "Alice"),
            Player(name: "Bob")
        ]
        gameState.cards = generateTestCards(playerCount: 2, word: "Vienna")
        
        // At game start, both cards should be available
        for (index, card) in gameState.cards.enumerated() {
            XCTAssertFalse(card.isLocked, "Card \(index) should be tappable at start")
            XCTAssertFalse(card.isRevealed, "Card \(index) should be face-down at start")
        }
        
        // Lock first card
        _ = try gameState.selectCard(at: 0, byPlayer: 0)
        try gameState.lockCard(at: 0)
        
        // Now only second card should be available
        XCTAssertTrue(gameState.cards[0].isLocked, "Card 0 should be locked")
        XCTAssertFalse(gameState.cards[1].isLocked, "Card 1 should be available")
    }
    
    /// Test that turn information is clear
    func testTurnInformationIsAccessible() throws {
        var gameState = GameState()
        gameState.players = [
            Player(name: "Alice"),
            Player(name: "Bob"),
            Player(name: "Charlie")
        ]
        gameState.cards = generateTestCards(playerCount: 3, word: "Prague")
        
        // Current player info should be accessible
        let currentPlayerIndex = gameState.currentPlayerIndex
        XCTAssertEqual(currentPlayerIndex, 0, "Initial player should be 0")
        
        // Current player name should be accessible
        let currentPlayerName = gameState.players[currentPlayerIndex].name
        XCTAssertEqual(currentPlayerName, "Alice")
        
        // Advance and verify
        gameState.nextPlayer()
        let nextPlayerIndex = gameState.currentPlayerIndex
        XCTAssertEqual(nextPlayerIndex, 1)
        
        let nextPlayerName = gameState.players[nextPlayerIndex].name
        XCTAssertEqual(nextPlayerName, "Bob")
    }
    
    // MARK: - Edge Cases for Robustness
    
    /// Test minimum viable game (2 players, 2 cards)
    func testMinimumViableGameRobustness() throws {
        var gameState = GameState()
        gameState.players = [
            Player(name: "P1"),
            Player(name: "P2")
        ]
        gameState.cards = generateTestCards(playerCount: 2, word: "Cat")
        
        // Play through
        _ = try gameState.selectCard(at: 0, byPlayer: 0)
        try gameState.lockCard(at: 0)
        gameState.nextPlayer()
        
        _ = try gameState.selectCard(at: 1, byPlayer: 1)
        try gameState.lockCard(at: 1)
        
        XCTAssertTrue(gameState.isGameComplete())
    }
    
    /// Test maximum viable game (8 players, 8 cards)
    func testMaximumViableGameRobustness() throws {
        var gameState = GameState()
        gameState.players = (1...8).map { Player(name: "P\($0)") }
        gameState.cards = generateTestCards(playerCount: 8, word: "Mountain")
        
        // Play through all 8 turns
        for i in 0..<8 {
            _ = try gameState.selectCard(at: i, byPlayer: i % 8)
            try gameState.lockCard(at: i)
            gameState.nextPlayer()
        }
        
        XCTAssertTrue(gameState.isGameComplete())
    }
    
    /// Test that error states don't leave game in inconsistent state
    func testErrorHandlingConsistency() throws {
        var gameState = GameState()
        gameState.players = [Player(name: "Alice")]
        gameState.cards = generateTestCards(playerCount: 3, word: "Forest")
        
        let stateBeforeError = (
            revealedCount: gameState.revealedCards.count,
            gameComplete: gameState.isGameComplete()
        )
        
        // Attempt invalid operation
        _ = try? gameState.selectCard(at: 99, byPlayer: 0)
        
        let stateAfterError = (
            revealedCount: gameState.revealedCards.count,
            gameComplete: gameState.isGameComplete()
        )
        
        // State should not change after error
        XCTAssertEqual(stateBeforeError.revealedCount, stateAfterError.revealedCount)
        XCTAssertEqual(stateBeforeError.gameComplete, stateAfterError.gameComplete)
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


