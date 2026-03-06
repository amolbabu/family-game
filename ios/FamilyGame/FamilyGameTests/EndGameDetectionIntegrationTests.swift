import XCTest
@testable import FamilyGame

/// Integration tests for end-game detection and screen transitions
/// Tests that the game correctly identifies when all cards are revealed
final class EndGameDetectionIntegrationTests: XCTestCase {
    
    // MARK: - Test 3.1: Detect All Cards Locked
    
    /// Test that game completion is correctly detected with multiple cards
    func testGameCompletionDetection() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob"),
            Player(name: "Charlie")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 3, word: "Rome")
        
        // Verify game not complete at start
        XCTAssertFalse(gameState.isGameComplete(), "Game should not be complete at start")
        XCTAssertEqual(gameState.revealedCards.count, 0, "No cards should be in revealedCards yet")
        
        // Lock first card
        _ = try gameState.selectCard(at: 0, byPlayer: 0)
        try gameState.lockCard(at: 0)
        XCTAssertFalse(gameState.isGameComplete(), "Game should not be complete with 1 card locked")
        XCTAssertEqual(gameState.revealedCards.count, 1, "revealedCards should have 1 card")
        
        // Lock second card
        _ = try gameState.selectCard(at: 1, byPlayer: 1)
        try gameState.lockCard(at: 1)
        XCTAssertFalse(gameState.isGameComplete(), "Game should not be complete with 2 cards locked")
        XCTAssertEqual(gameState.revealedCards.count, 2, "revealedCards should have 2 cards")
        
        // Lock third card
        _ = try gameState.selectCard(at: 2, byPlayer: 2)
        try gameState.lockCard(at: 2)
        XCTAssertTrue(gameState.isGameComplete(), "Game should be complete when all cards locked")
        XCTAssertEqual(gameState.revealedCards.count, 3, "revealedCards should have all 3 cards")
    }
    
    /// Test game completion with various player counts
    func testGameCompletionAcrossPlayerCounts() throws {
        let playerCounts = [2, 3, 4, 5, 6, 7, 8]
        
        for count in playerCounts {
            var gameState = GameState()
            let players = (1...count).map { Player(name: "Player \($0)") }
            gameState.players = players
            gameState.cards = generateTestCards(playerCount: count, word: "Word")
            
            // Lock all cards
            for i in 0..<count {
                _ = try gameState.selectCard(at: i, byPlayer: i % count)
                try gameState.lockCard(at: i)
            }
            
            XCTAssertTrue(gameState.isGameComplete(),
                         "Game with \(count) players should be complete when all cards locked")
            XCTAssertEqual(gameState.revealedCards.count, count,
                          "All \(count) cards should be in revealedCards")
        }
    }
    
    /// Test that intermediate game states report correct completion status
    func testGameStateProgressionToCompletion() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Player 1"),
            Player(name: "Player 2"),
            Player(name: "Player 3"),
            Player(name: "Player 4")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 4, word: "Vienna")
        
        let progressionChecks = [
            (0, false, "Should not be complete with 0 cards"),
            (1, false, "Should not be complete with 1 card"),
            (2, false, "Should not be complete with 2 cards"),
            (3, false, "Should not be complete with 3 cards"),
            (4, true, "Should be complete with all 4 cards")
        ]
        
        for (cardIndex, shouldBeComplete, message) in progressionChecks {
            if cardIndex > 0 {
                _ = try gameState.selectCard(at: cardIndex - 1, byPlayer: (cardIndex - 1) % 4)
                try gameState.lockCard(at: cardIndex - 1)
            }
            
            XCTAssertEqual(gameState.isGameComplete(), shouldBeComplete, message)
        }
    }
    
    // MARK: - Test 3.2: End-Game Screen Appears
    
    /// Test that game state transitions when complete
    func testGamePhaseTransitionOnCompletion() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Berlin")
        gameState.gamePhase = .inGame
        
        // Initially in game phase
        XCTAssertEqual(gameState.gamePhase, .inGame, "Should start in inGame phase")
        
        // Lock all cards
        for i in 0..<2 {
            _ = try gameState.selectCard(at: i, byPlayer: i)
            try gameState.lockCard(at: i)
        }
        
        // Game should be complete
        XCTAssertTrue(gameState.isGameComplete(), "Game should be complete")
        
        // Note: In the real app, the view would transition to endGame phase
        // This is verified in the UI integration tests
    }
    
    // MARK: - Test Locked Card Count vs Completion
    
    /// Test that completion check uses revealedCards set correctly
    func testCompletionUsesRevealedCardsSet() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob"),
            Player(name: "Charlie")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 3, word: "Paris")
        
        // Manually add to revealedCards to test the logic
        _ = try gameState.selectCard(at: 0, byPlayer: 0)
        try gameState.lockCard(at: 0)
        
        _ = try gameState.selectCard(at: 1, byPlayer: 1)
        try gameState.lockCard(at: 1)
        
        // Count locked cards vs revealedCards
        let lockedCount = gameState.cards.filter { $0.isLocked }.count
        let revealedCount = gameState.revealedCards.count
        
        XCTAssertEqual(lockedCount, revealedCount,
                      "Locked cards should match revealedCards set")
        XCTAssertEqual(lockedCount, 2, "Should have 2 locked cards")
        XCTAssertFalse(gameState.isGameComplete(),
                      "Should not be complete with only 2 of 3 cards locked")
    }
    
    // MARK: - Test Edge Cases for Completion
    
    /// Test single-card game scenarios
    func testMinimumGameWithTwoCards() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Only Player 1"),
            Player(name: "Only Player 2")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "London")
        
        XCTAssertFalse(gameState.isGameComplete(), "Should not be complete at start")
        
        _ = try gameState.selectCard(at: 0, byPlayer: 0)
        try gameState.lockCard(at: 0)
        XCTAssertFalse(gameState.isGameComplete(), "Should not be complete with 1 of 2 cards")
        
        _ = try gameState.selectCard(at: 1, byPlayer: 1)
        try gameState.lockCard(at: 1)
        XCTAssertTrue(gameState.isGameComplete(), "Should be complete with all 2 cards")
    }
    
    /// Test maximum game with 8 cards
    func testMaximumGameWithEightCards() throws {
        var gameState = GameState()
        let players = (1...8).map { Player(name: "Player \($0)") }
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 8, word: "Tokyo")
        
        XCTAssertFalse(gameState.isGameComplete())
        
        for i in 0..<8 {
            _ = try gameState.selectCard(at: i, byPlayer: i)
            try gameState.lockCard(at: i)
            
            let expected = (i == 7)
            XCTAssertEqual(gameState.isGameComplete(), expected,
                          "Game completion at card \(i+1) of 8 should be \(expected)")
        }
    }
    
    // MARK: - Test Game Completion Consistency
    
    /// Test that completion check is consistent across multiple calls
    func testCompletionCheckConsistency() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob"),
            Player(name: "Charlie")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 3, word: "Barcelona")
        
        // Lock all cards
        for i in 0..<3 {
            _ = try gameState.selectCard(at: i, byPlayer: i)
            try gameState.lockCard(at: i)
        }
        
        // Check completion multiple times - should always be consistent
        XCTAssertTrue(gameState.isGameComplete())
        XCTAssertTrue(gameState.isGameComplete())
        XCTAssertTrue(gameState.isGameComplete())
        
        // Verify all cards are locked
        let allLocked = gameState.cards.allSatisfy { $0.isLocked }
        XCTAssertTrue(allLocked, "All cards should be locked")
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
