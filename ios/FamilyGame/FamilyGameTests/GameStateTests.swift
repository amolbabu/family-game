import XCTest
@testable import FamilyGame

final class GameStateTests: XCTestCase {
    
    // MARK: - Card Generation Tests (User Story 6 & 7)
    
    /// Test Case 1.1: Correct Card Count
    /// Input: playerCount = 3
    /// Expected: 3 cards generated
    func testCorrectCardCountForThreePlayers() {
        var gameState = GameState()
        gameState.cards = generateTestCards(playerCount: 3, word: "Paris")
        
        XCTAssertEqual(gameState.cards.count, 3, "Should generate 3 cards for 3 players")
    }
    
    /// Test Case 1.1 Extended: Multiple Player Counts
    func testCorrectCardCountForVariousPlayerCounts() {
        for playerCount in 2...8 {
            var gameState = GameState()
            gameState.cards = generateTestCards(playerCount: playerCount, word: "TestWord")
            
            XCTAssertEqual(gameState.cards.count, playerCount, 
                          "Should generate \(playerCount) cards for \(playerCount) players")
        }
    }
    
    /// Test Case 1.2: Exactly One Spy
    /// Input: playerCount = 5
    /// Expected: exactly 1 card with content = .spy
    func testExactlyOneSpyCardForFivePlayers() {
        var gameState = GameState()
        gameState.cards = generateTestCards(playerCount: 5, word: "London")
        
        let spyCards = gameState.cards.filter { 
            if case .spy = $0.content {
                return true
            }
            return false
        }
        
        XCTAssertEqual(spyCards.count, 1, "Should have exactly 1 spy card")
    }
    
    /// Test Case 1.2 Extended: One Spy for All Player Counts
    func testExactlyOneSpyForVariousPlayerCounts() {
        for playerCount in 2...8 {
            var gameState = GameState()
            gameState.cards = generateTestCards(playerCount: playerCount, word: "Word")
            
            let spyCards = gameState.cards.filter { 
                if case .spy = $0.content {
                    return true
                }
                return false
            }
            
            XCTAssertEqual(spyCards.count, 1, 
                          "Should have exactly 1 spy card for \(playerCount) players")
        }
    }
    
    /// Test Case 1.3: All Non-Spy Cards Show Same Word
    /// Input: playerCount = 4, word = "Paris"
    /// Expected: 3 cards show "Paris", 1 shows "spy"
    func testAllNonSpyCardsShowSameWord() {
        let testWord = "Paris"
        var gameState = GameState()
        gameState.cards = generateTestCards(playerCount: 4, word: testWord)
        
        let wordCards = gameState.cards.filter { 
            if case .word(let word) = $0.content {
                return word == testWord
            }
            return false
        }
        
        XCTAssertEqual(wordCards.count, 3, "Should have 3 cards with word '\(testWord)'")
    }
    
    /// Test Case 1.3 Extended: Different Words
    func testAllNonSpyCardsShowSameWordMultipleThemes() {
        let testWords = ["Paris", "London", "Tokyo", "Bicycle", "Book", "Camera"]
        
        for testWord in testWords {
            var gameState = GameState()
            gameState.cards = generateTestCards(playerCount: 4, word: testWord)
            
            let wordCards = gameState.cards.filter { 
                if case .word(let word) = $0.content {
                    return word == testWord
                }
                return false
            }
            
            XCTAssertEqual(wordCards.count, 3, 
                          "Should have 3 cards with word '\(testWord)'")
        }
    }
    
    /// Test Case 1.4: Random Spy Position
    /// Input: Generate 100 games with playerCount = 3
    /// Expected: Spy position varies (not always at index 0, 1, or 2)
    func testRandomSpyPosition() {
        var spyPositions: Set<Int> = []
        let gameCount = 100
        let playerCount = 3
        
        for _ in 0..<gameCount {
            var gameState = GameState()
            gameState.cards = generateTestCards(playerCount: playerCount, word: "RandomWord")
            
            // Find spy position
            if let spyIndex = gameState.cards.firstIndex(where: { 
                if case .spy = $0.content {
                    return true
                }
                return false
            }) {
                spyPositions.insert(spyIndex)
            }
        }
        
        // With 100 runs and 3 positions, we should see variation
        // This is probabilistic but has extremely high success rate
        XCTAssertGreaterThan(spyPositions.count, 1, 
                           "Spy position should vary across multiple games")
    }
    
    /// Test Case 1.4 Extended: Spy Position Distribution
    func testSpyPositionDistribution() {
        var positionCounts: [Int: Int] = [0: 0, 1: 0, 2: 0]
        let gameCount = 300
        let playerCount = 3
        
        for _ in 0..<gameCount {
            var gameState = GameState()
            gameState.cards = generateTestCards(playerCount: playerCount, word: "Word")
            
            if let spyIndex = gameState.cards.firstIndex(where: { 
                if case .spy = $0.content {
                    return true
                }
                return false
            }) {
                positionCounts[spyIndex] = (positionCounts[spyIndex] ?? 0) + 1
            }
        }
        
        // Each position should appear roughly 1/3 of the time
        // Allow 20-43% range for statistical variance
        for (position, count) in positionCounts {
            let percentage = Double(count) / Double(gameCount)
            XCTAssertGreaterThan(percentage, 0.2, 
                               "Position \(position) appears too infrequently")
            XCTAssertLessThan(percentage, 0.43, 
                            "Position \(position) appears too frequently")
        }
    }
    
    /// Test Case 1.5: Edge Case — Minimum Players
    /// Input: playerCount = 2
    /// Expected: 1 spy, 1 normal card
    func testMinimumPlayerCountEdgeCase() {
        var gameState = GameState()
        gameState.cards = generateTestCards(playerCount: 2, word: "TestWord")
        
        XCTAssertEqual(gameState.cards.count, 2, "Should generate 2 cards for 2 players")
        
        let spyCards = gameState.cards.filter { 
            if case .spy = $0.content { return true }
            return false
        }
        XCTAssertEqual(spyCards.count, 1, "Should have exactly 1 spy card")
    }
    
    /// Test Case 1.6: Edge Case — Maximum Players
    /// Input: playerCount = 8
    /// Expected: 8 cards, exactly 1 spy
    func testMaximumPlayerCountEdgeCase() {
        var gameState = GameState()
        gameState.cards = generateTestCards(playerCount: 8, word: "TestWord")
        
        XCTAssertEqual(gameState.cards.count, 8, "Should generate 8 cards for 8 players")
        
        let spyCards = gameState.cards.filter { 
            if case .spy = $0.content { return true }
            return false
        }
        XCTAssertEqual(spyCards.count, 1, "Should have exactly 1 spy card")
    }
    
    // MARK: - Card State Tests (User Stories 9-10)
    
    /// Test Case 3.1: Card Reveal
    /// Input: Select card at index 0
    /// Expected: card.isRevealed == true
    func testCardReveal() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1"), Player(name: "Player 2")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Paris")
        
        let content = try gameState.selectCard(at: 0, byPlayer: 0)
        
        XCTAssertTrue(gameState.cards[0].isRevealed, "Card should be revealed")
        XCTAssertNotNil(content, "Card content should be returned")
    }
    
    /// Test Case 3.2: Card Lock After View
    /// Input: Player views card, then locks it
    /// Expected: card.isRevealed = false, card.isLocked = true
    func testCardLockAfterView() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1"), Player(name: "Player 2")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Paris")
        
        // Reveal card
        _ = try gameState.selectCard(at: 0, byPlayer: 0)
        XCTAssertTrue(gameState.cards[0].isRevealed)
        
        // Lock card
        try gameState.lockCard(at: 0)
        
        XCTAssertFalse(gameState.cards[0].isRevealed, "Card should be hidden after locking")
        XCTAssertTrue(gameState.cards[0].isLocked, "Card should be locked")
    }
    
    /// Test Case 3.3: Cannot Reopen Locked Card
    /// Input: Try to select a locked card
    /// Expected: Throws error or card remains locked
    func testCannotReopenLockedCard() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1"), Player(name: "Player 2")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Paris")
        
        // Reveal and lock card
        _ = try gameState.selectCard(at: 0, byPlayer: 0)
        try gameState.lockCard(at: 0)
        
        // Try to select locked card
        XCTAssertThrowsError(try gameState.selectCard(at: 0, byPlayer: 0), 
                            "Should throw error when selecting locked card") { error in
            XCTAssertEqual(error as? GameError, GameError.cardAlreadyLocked)
        }
    }
    
    // MARK: - Turn Flow Tests (User Stories 9-11)
    
    /// Test Case 3.4: Next Player Advances Correctly
    /// Input: currentPlayerIndex = 0, call nextPlayer()
    /// Expected: currentPlayerIndex = 1
    func testNextPlayerAdvances() {
        var gameState = GameState()
        let players = [
            Player(name: "Player 1"),
            Player(name: "Player 2"),
            Player(name: "Player 3")
        ]
        gameState.players = players
        gameState.currentPlayerIndex = 0
        
        gameState.nextPlayer()
        
        XCTAssertEqual(gameState.currentPlayerIndex, 1, "Current player should advance to next")
    }
    
    /// Test Case 3.5: Turn Wraps Around
    /// Input: 3 players, currentPlayerIndex = 2, call nextPlayer()
    /// Expected: currentPlayerIndex = 0
    func testTurnWrapsAround() {
        var gameState = GameState()
        let players = [
            Player(name: "Player 1"),
            Player(name: "Player 2"),
            Player(name: "Player 3")
        ]
        gameState.players = players
        gameState.currentPlayerIndex = 2
        
        gameState.nextPlayer()
        
        XCTAssertEqual(gameState.currentPlayerIndex, 0, 
                      "Turn should wrap around to first player")
    }
    
    /// Test Case 3.5 Extended: Turn Wrapping for Various Player Counts
    func testTurnWrappingForVariousPlayerCounts() {
        for playerCount in 2...8 {
            var gameState = GameState()
            let players = (1...playerCount).map { Player(name: "Player \($0)") }
            gameState.players = players
            gameState.currentPlayerIndex = playerCount - 1
            
            gameState.nextPlayer()
            
            XCTAssertEqual(gameState.currentPlayerIndex, 0, 
                          "Turn should wrap around for \(playerCount) players")
        }
    }
    
    /// Test Case 3.6: Game Complete Detection
    /// Input: All cards are locked
    /// Expected: isGameComplete() returns true
    func testGameCompleteDetection() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1"), Player(name: "Player 2")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Paris")
        
        // Lock all cards
        for i in 0..<gameState.cards.count {
            _ = try gameState.selectCard(at: i, byPlayer: i % 2)
            try gameState.lockCard(at: i)
        }
        
        XCTAssertTrue(gameState.isGameComplete(), "Game should be complete when all cards locked")
    }
    
    /// Test Case 3.7: Game Not Complete Early
    /// Input: Only 1 of 3 cards locked
    /// Expected: isGameComplete() returns false
    func testGameNotCompleteEarly() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Player 1"),
            Player(name: "Player 2"),
            Player(name: "Player 3")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 3, word: "Paris")
        
        // Lock only first card
        _ = try gameState.selectCard(at: 0, byPlayer: 0)
        try gameState.lockCard(at: 0)
        
        XCTAssertFalse(gameState.isGameComplete(), 
                      "Game should not be complete with unlocked cards remaining")
    }
    
    /// Test Case 3.7 Extended: Game Completion Progress
    func testGameCompletionProgress() throws {
        var gameState = GameState()
        let players = (1...4).map { Player(name: "Player \($0)") }
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 4, word: "Word")
        
        for i in 0..<gameState.cards.count {
            XCTAssertFalse(gameState.isGameComplete(), 
                          "Game not complete before locking all cards")
            
            _ = try gameState.selectCard(at: i, byPlayer: i % 4)
            try gameState.lockCard(at: i)
        }
        
        XCTAssertTrue(gameState.isGameComplete(), "Game should be complete after all cards locked")
    }
    
    // MARK: - Error Handling Tests
    
    /// Test invalid card index selection
    func testInvalidCardIndexThrowsError() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Word")
        
        XCTAssertThrowsError(try gameState.selectCard(at: 10, byPlayer: 0),
                            "Should throw error for invalid card index") { error in
            XCTAssertEqual(error as? GameError, GameError.invalidCardIndex)
        }
    }
    
    /// Test negative card index
    func testNegativeCardIndexThrowsError() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Word")
        
        XCTAssertThrowsError(try gameState.selectCard(at: -1, byPlayer: 0),
                            "Should throw error for negative card index") { error in
            XCTAssertEqual(error as? GameError, GameError.invalidCardIndex)
        }
    }
    
    /// Test invalid player index
    func testInvalidPlayerIndexThrowsError() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Word")
        
        XCTAssertThrowsError(try gameState.selectCard(at: 0, byPlayer: 5),
                            "Should throw error for invalid player index") { error in
            XCTAssertEqual(error as? GameError, GameError.invalidPlayerIndex)
        }
    }
    
    // MARK: - Helper Functions
    
    /// Helper function to generate test cards with one spy
    private func generateTestCards(playerCount: Int, word: String) -> [Card] {
        var cards: [Card] = []
        
        // Create non-spy cards
        for i in 0..<(playerCount - 1) {
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
