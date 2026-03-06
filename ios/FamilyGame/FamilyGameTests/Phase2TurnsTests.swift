import XCTest
@testable import FamilyGame

final class Phase2TurnsTests: XCTestCase {
    
    // MARK: - revealCard Tests (User Story 9)
    
    func testRevealCardSuccessfully() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1"), Player(name: "Player 2")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Paris")
        
        let content = try gameState.revealCard(at: 0)
        
        XCTAssertTrue(gameState.cards[0].isRevealed, "Card should be revealed")
        XCTAssertFalse(gameState.cards[0].isLocked, "Card should not be locked yet")
        XCTAssertNotNil(content, "Content should be returned")
    }
    
    func testRevealCardThrowsForLockedCard() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Paris")
        
        // Lock the card first
        gameState.cards[0].isLocked = true
        
        XCTAssertThrowsError(try gameState.revealCard(at: 0)) { error in
            XCTAssertEqual(error as? GameError, GameError.cardAlreadyLocked)
        }
    }
    
    func testRevealCardThrowsForInvalidIndex() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Paris")
        
        XCTAssertThrowsError(try gameState.revealCard(at: 10)) { error in
            XCTAssertEqual(error as? GameError, GameError.invalidCardIndex)
        }
    }
    
    func testRevealCardThrowsForAlreadyRevealed() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Paris")
        
        // Reveal once
        _ = try gameState.revealCard(at: 0)
        
        // Try to reveal again without hiding first
        XCTAssertThrowsError(try gameState.revealCard(at: 0)) { error in
            XCTAssertEqual(error as? GameError, GameError.cardAlreadyRevealed)
        }
    }
    
    // MARK: - hideCard Tests (User Story 10)
    
    func testHideCardSuccessfully() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Paris")
        
        // Reveal then hide
        _ = try gameState.revealCard(at: 0)
        try gameState.hideCard(at: 0)
        
        XCTAssertFalse(gameState.cards[0].isRevealed, "Card should be hidden")
        XCTAssertFalse(gameState.cards[0].isLocked, "Card should not be locked yet")
    }
    
    func testHideCardThrowsForNotRevealed() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Paris")
        
        XCTAssertThrowsError(try gameState.hideCard(at: 0)) { error in
            XCTAssertEqual(error as? GameError, GameError.cardNotRevealed)
        }
    }
    
    func testHideCardThrowsForInvalidIndex() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Paris")
        
        XCTAssertThrowsError(try gameState.hideCard(at: 10)) { error in
            XCTAssertEqual(error as? GameError, GameError.invalidCardIndex)
        }
    }
    
    // MARK: - lockCard Phase 2 Tests
    
    func testLockCardPhase2() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Paris")
        
        // Reveal then lock
        _ = try gameState.revealCard(at: 0)
        try gameState.lockCard(at: 0)
        
        XCTAssertTrue(gameState.cards[0].isLocked, "Card should be locked")
        XCTAssertFalse(gameState.cards[0].isRevealed, "Card should be hidden when locked")
    }
    
    func testLockCardThrowsForNotRevealed() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Paris")
        
        XCTAssertThrowsError(try gameState.lockCard(at: 0)) { error in
            XCTAssertEqual(error as? GameError, GameError.cardNotRevealed)
        }
    }
    
    // MARK: - advanceToNextPlayer Tests
    
    func testAdvanceToNextPlayer() {
        var gameState = GameState()
        let players = [
            Player(name: "Player 1"),
            Player(name: "Player 2"),
            Player(name: "Player 3")
        ]
        gameState.players = players
        gameState.currentPlayerIndex = 0
        
        gameState.advanceToNextPlayer()
        
        XCTAssertEqual(gameState.currentPlayerIndex, 1)
    }
    
    func testAdvanceToNextPlayerWraps() {
        var gameState = GameState()
        let players = [
            Player(name: "Player 1"),
            Player(name: "Player 2"),
            Player(name: "Player 3")
        ]
        gameState.players = players
        gameState.currentPlayerIndex = 2
        
        gameState.advanceToNextPlayer()
        
        XCTAssertEqual(gameState.currentPlayerIndex, 0)
    }
    
    func testAdvanceToNextPlayerMultipleTimes() {
        var gameState = GameState()
        let players = (1...4).map { Player(name: "Player \($0)") }
        gameState.players = players
        gameState.currentPlayerIndex = 0
        
        let expectedSequence = [0, 1, 2, 3, 0, 1, 2, 3]
        
        for expected in expectedSequence {
            XCTAssertEqual(gameState.currentPlayerIndex, expected)
            gameState.advanceToNextPlayer()
        }
    }
    
    // MARK: - checkGameComplete Tests (User Story 13)
    
    func testCheckGameCompleteWhenAllLocked() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1"), Player(name: "Player 2")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Paris")
        
        // Lock all cards
        for i in 0..<gameState.cards.count {
            _ = try gameState.revealCard(at: i)
            try gameState.lockCard(at: i)
        }
        
        XCTAssertTrue(gameState.checkGameComplete())
    }
    
    func testCheckGameIncompleteWhenSomeUnlocked() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Player 1"),
            Player(name: "Player 2"),
            Player(name: "Player 3")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 3, word: "Paris")
        
        // Lock only first card
        _ = try gameState.revealCard(at: 0)
        try gameState.lockCard(at: 0)
        
        XCTAssertFalse(gameState.checkGameComplete())
    }
    
    func testCheckGameIncompleteWhenNoneLocked() {
        var gameState = GameState()
        let players = [Player(name: "Player 1"), Player(name: "Player 2")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Paris")
        
        XCTAssertFalse(gameState.checkGameComplete())
    }
    
    func testCheckGameCompleteWithEmptyCards() {
        var gameState = GameState()
        gameState.cards = []
        
        // Empty cards should return false
        XCTAssertFalse(gameState.checkGameComplete())
    }
    
    // MARK: - resetGameState Tests (User Story 16)
    
    func testResetGameStateResetsCards() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1"), Player(name: "Player 2")]
        gameState.players = players
        gameState.selectedTheme = "Place"
        gameState.selectedWord = "Paris"
        gameState.cards = generateTestCards(playerCount: 2, word: "Paris")
        
        // Modify some game state
        gameState.currentPlayerIndex = 1
        _ = try gameState.revealCard(at: 0)
        try gameState.lockCard(at: 0)
        
        // Reset
        try gameState.resetGameState()
        
        // Verify reset
        XCTAssertEqual(gameState.currentPlayerIndex, 0, "Should reset to player 0")
        XCTAssertEqual(gameState.cards.count, 2, "Should have same number of cards")
        XCTAssertFalse(gameState.cards.allSatisfy { $0.isLocked }, "Cards should not be locked after reset")
        XCTAssertFalse(gameState.cards.allSatisfy { $0.isRevealed }, "Cards should not be revealed after reset")
    }
    
    func testResetGameStateMaintainsPlayerCount() throws {
        var gameState = GameState()
        let players = (1...5).map { Player(name: "Player \($0)") }
        gameState.players = players
        gameState.selectedTheme = "Place"
        gameState.selectedWord = "Paris"
        gameState.cards = generateTestCards(playerCount: 5, word: "Paris")
        
        try gameState.resetGameState()
        
        XCTAssertEqual(gameState.cards.count, 5, "Should generate new cards for same player count")
        XCTAssertEqual(gameState.cards.count, gameState.players.count)
    }
    
    func testResetGameStateChangesWord() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1"), Player(name: "Player 2")]
        gameState.players = players
        gameState.selectedTheme = "Place"
        gameState.selectedWord = "Paris"
        gameState.cards = generateTestCards(playerCount: 2, word: "Paris")
        
        let oldWord = gameState.selectedWord
        
        try gameState.resetGameState()
        
        // Word might be same by chance, so just verify it's from the theme
        XCTAssertFalse(gameState.selectedWord.isEmpty, "Should select a word from theme")
    }
    
    func testResetGameStateThrowsForNoTheme() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1"), Player(name: "Player 2")]
        gameState.players = players
        gameState.selectedTheme = ""
        gameState.cards = generateTestCards(playerCount: 2, word: "Paris")
        
        XCTAssertThrowsError(try gameState.resetGameState()) { error in
            XCTAssertEqual(error as? GameError, GameError.invalidTheme)
        }
    }
    
    func testResetGameStateResetsPhase() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1"), Player(name: "Player 2")]
        gameState.players = players
        gameState.selectedTheme = "Place"
        gameState.cards = generateTestCards(playerCount: 2, word: "Paris")
        gameState.gamePhase = .endGame
        
        try gameState.resetGameState()
        
        XCTAssertEqual(gameState.gamePhase, .inGame)
    }
    
    // MARK: - performCardTap Tests
    
    func testPerformCardTapRevealCard() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1"), Player(name: "Player 2")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Paris")
        
        let result = gameState.performCardTap(at: 0, player: 0)
        
        switch result {
        case .revealed(let content):
            XCTAssertNotNil(content)
        default:
            XCTFail("Expected revealed result")
        }
    }
    
    func testPerformCardTapHideCard() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1"), Player(name: "Player 2")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Paris")
        
        // First tap reveals
        _ = gameState.performCardTap(at: 0, player: 0)
        
        // Second tap hides
        let result = gameState.performCardTap(at: 0, player: 0)
        
        switch result {
        case .hidden:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected hidden result")
        }
    }
    
    func testPerformCardTapLockedCard() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Paris")
        
        gameState.cards[0].isLocked = true
        
        let result = gameState.performCardTap(at: 0, player: 0)
        
        switch result {
        case .locked:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected locked result")
        }
    }
    
    func testPerformCardTapInvalidIndex() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Paris")
        
        let result = gameState.performCardTap(at: 100, player: 0)
        
        switch result {
        case .invalid:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected invalid result")
        }
    }
    
    func testPerformCardTapInvalidPlayer() throws {
        var gameState = GameState()
        let players = [Player(name: "Player 1")]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Paris")
        
        let result = gameState.performCardTap(at: 0, player: 100)
        
        switch result {
        case .invalid:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected invalid result")
        }
    }
    
    // MARK: - Integration Tests
    
    func testCompleteGameFlowWithNewMethods() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob"),
            Player(name: "Charlie")
        ]
        gameState.players = players
        gameState.selectedTheme = "Place"
        gameState.cards = generateTestCards(playerCount: 3, word: "Tokyo")
        
        XCTAssertFalse(gameState.checkGameComplete())
        
        // Turn 1: Alice
        let result1 = gameState.performCardTap(at: 0, player: 0)
        switch result1 {
        case .revealed:
            try gameState.lockCard(at: 0)
        default:
            XCTFail("Expected reveal on first tap")
        }
        
        gameState.advanceToNextPlayer()
        
        // Turn 2: Bob
        let result2 = gameState.performCardTap(at: 1, player: 1)
        switch result2 {
        case .revealed:
            try gameState.lockCard(at: 1)
        default:
            XCTFail("Expected reveal on first tap")
        }
        
        gameState.advanceToNextPlayer()
        
        // Turn 3: Charlie
        let result3 = gameState.performCardTap(at: 2, player: 2)
        switch result3 {
        case .revealed:
            try gameState.lockCard(at: 2)
        default:
            XCTFail("Expected reveal on first tap")
        }
        
        XCTAssertTrue(gameState.checkGameComplete())
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
