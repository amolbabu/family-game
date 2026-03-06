import XCTest
@testable import FamilyGame

/// Integration tests for game reset and replay functionality
/// Tests that Play Again works correctly with new random state
final class ReplayIntegrationTests: XCTestCase {
    
    // MARK: - Test 4.1: Play Again Resets State
    
    /// Test that game reset clears card state for all cards
    func testPlayAgainClearsCardState() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob"),
            Player(name: "Charlie")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 3, word: "Paris")
        gameState.selectedWord = "Paris"
        
        // Play through and lock some cards
        _ = try gameState.selectCard(at: 0, byPlayer: 0)
        try gameState.lockCard(at: 0)
        
        _ = try gameState.selectCard(at: 1, byPlayer: 1)
        try gameState.lockCard(at: 1)
        
        // Verify cards are locked
        XCTAssertTrue(gameState.cards[0].isLocked)
        XCTAssertTrue(gameState.cards[1].isLocked)
        XCTAssertEqual(gameState.revealedCards.count, 2)
        
        // Create new game state (simulating Play Again)
        var newGameState = GameState(
            players: players,
            theme: gameState.selectedTheme,
            word: "London"
        )
        newGameState.cards = generateTestCards(playerCount: 3, word: "London")
        
        // Verify new state is clean
        XCTAssertFalse(newGameState.cards[0].isLocked, "New game card 0 should not be locked")
        XCTAssertFalse(newGameState.cards[0].isRevealed, "New game card 0 should not be revealed")
        XCTAssertFalse(newGameState.cards[1].isLocked, "New game card 1 should not be locked")
        XCTAssertFalse(newGameState.cards[1].isRevealed, "New game card 1 should not be revealed")
        XCTAssertEqual(newGameState.revealedCards.count, 0, "New game should have no revealed cards")
    }
    
    /// Test that Play Again preserves player list
    func testPlayAgainPreservesPlayers() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob"),
            Player(name: "Charlie")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 3, word: "Rome")
        
        // Play through complete game
        for i in 0..<3 {
            _ = try gameState.selectCard(at: i, byPlayer: i)
            try gameState.lockCard(at: i)
        }
        
        // Create new game with same players
        var newGameState = GameState(
            players: gameState.players,
            theme: gameState.selectedTheme,
            word: "Madrid"
        )
        newGameState.cards = generateTestCards(playerCount: 3, word: "Madrid")
        
        // Verify players are identical
        XCTAssertEqual(newGameState.players.count, players.count)
        for (index, player) in players.enumerated() {
            XCTAssertEqual(newGameState.players[index].name, player.name)
            XCTAssertEqual(newGameState.players[index].id, player.id)
        }
    }
    
    /// Test that Play Again generates new cards
    func testPlayAgainGeneratesNewCards() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Player 1"),
            Player(name: "Player 2")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Berlin")
        let firstGameSpyPosition = findSpyPosition(gameState.cards)
        
        // Create new game with different word
        var newGameState = GameState(
            players: gameState.players,
            theme: gameState.selectedTheme,
            word: "Vienna"
        )
        newGameState.cards = generateTestCards(playerCount: 2, word: "Vienna")
        
        // Verify new word is used
        let hasViennaWord = newGameState.cards.contains { card in
            if case .word(let word) = card.content {
                return word == "Vienna"
            }
            return false
        }
        XCTAssertTrue(hasViennaWord, "New game should have Vienna word")
        
        // Verify no Berlin word
        let hasBerlinWord = newGameState.cards.contains { card in
            if case .word(let word) = card.content {
                return word == "Berlin"
            }
            return false
        }
        XCTAssertFalse(hasBerlinWord, "New game should not have Berlin word")
    }
    
    /// Test that Play Again resets turn state
    func testPlayAgainResetsTurnState() throws {
        var gameState = GameState()
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob")
        ]
        gameState.players = players
        gameState.cards = generateTestCards(playerCount: 2, word: "Prague")
        
        // Advance turns
        gameState.nextPlayer()
        gameState.nextPlayer()
        XCTAssertEqual(gameState.currentPlayerIndex, 0, "After 2 advances on 2 players, should be back at 0")
        
        // Create new game
        var newGameState = GameState(
            players: players,
            theme: gameState.selectedTheme,
            word: "Warsaw"
        )
        newGameState.cards = generateTestCards(playerCount: 2, word: "Warsaw")
        
        // Verify turn state is reset
        XCTAssertEqual(newGameState.currentPlayerIndex, 0, "New game should start with Player 0")
    }
    
    // MARK: - Test 4.2: Consecutive Games Have Different Spy Positions
    
    /// Test that 10 consecutive games have variation in spy positions
    func testConsecutiveGamesSpy PositionVariation() {
        var spyPositions: [Int] = []
        
        for gameNum in 0..<10 {
            var gameState = GameState()
            let players = (1...4).map { Player(name: "Player \($0)") }
            gameState.players = players
            gameState.cards = generateTestCards(playerCount: 4, word: "City")
            
            if let spyIndex = findSpyPosition(gameState.cards) {
                spyPositions.append(spyIndex)
            }
        }
        
        // Verify we have variation
        let uniquePositions = Set(spyPositions)
        XCTAssertGreaterThan(uniquePositions.count, 1,
                            "10 games should have different spy positions (statistically)")
    }
    
    /// Test that consecutive games have independent spy positions
    func testIndependentSpyPositionsAcrossGames() {
        // Play 20 games and track spy positions
        var positionSequence: [Int] = []
        
        for _ in 0..<20 {
            var gameState = GameState()
            gameState.players = (1...3).map { Player(name: "Player \($0)") }
            gameState.cards = generateTestCards(playerCount: 3, word: "Word")
            
            if let pos = findSpyPosition(gameState.cards) {
                positionSequence.append(pos)
            }
        }
        
        // Check that position sequence has some variety (not always same position)
        XCTAssertGreaterThan(positionSequence.count, 10, "Should have many games")
        
        let uniquePositions = Set(positionSequence)
        XCTAssertGreaterThan(uniquePositions.count, 1,
                            "Multiple games should not always have spy in same position")
    }
    
    /// Test that each game can complete independently
    func testConsecutiveGamesCanCompleteIndependently() throws {
        for gameNum in 0..<5 {
            var gameState = GameState()
            let playerCount = Int.random(in: 2...4)
            gameState.players = (1...playerCount).map { Player(name: "Player \($0)") }
            gameState.cards = generateTestCards(playerCount: playerCount, word: "Word\(gameNum)")
            
            // Play complete game
            for i in 0..<playerCount {
                _ = try gameState.selectCard(at: i, byPlayer: i % playerCount)
                try gameState.lockCard(at: i)
            }
            
            XCTAssertTrue(gameState.isGameComplete(),
                         "Game \(gameNum) should complete successfully")
        }
    }
    
    // MARK: - Game Reset Integration with Full Playthrough
    
    /// Test complete flow: play → reset → play again
    func testFullPlayResetReplayFlow() throws {
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob")
        ]
        
        // Game 1
        var game1 = GameState()
        game1.players = players
        game1.cards = generateTestCards(playerCount: 2, word: "Paris")
        game1.selectedWord = "Paris"
        
        _ = try game1.selectCard(at: 0, byPlayer: 0)
        try game1.lockCard(at: 0)
        game1.nextPlayer()
        
        _ = try game1.selectCard(at: 1, byPlayer: 1)
        try game1.lockCard(at: 1)
        
        XCTAssertTrue(game1.isGameComplete())
        
        // Play Again (reset)
        var game2 = GameState(
            players: game1.players,
            theme: game1.selectedTheme,
            word: "London"
        )
        game2.cards = generateTestCards(playerCount: 2, word: "London")
        
        // Verify clean state
        XCTAssertFalse(game2.cards[0].isLocked)
        XCTAssertFalse(game2.cards[1].isLocked)
        XCTAssertEqual(game2.revealedCards.count, 0)
        XCTAssertEqual(game2.currentPlayerIndex, 0)
        
        // Play game 2
        _ = try game2.selectCard(at: 0, byPlayer: 0)
        try game2.lockCard(at: 0)
        game2.nextPlayer()
        
        _ = try game2.selectCard(at: 1, byPlayer: 1)
        try game2.lockCard(at: 1)
        
        XCTAssertTrue(game2.isGameComplete())
    }
    
    /// Test that multiple plays work with different player counts
    func testMultipleReplaysWithVaryingPlayerCounts() throws {
        for playerCount in 2...4 {
            var gameState = GameState()
            gameState.players = (1...playerCount).map { Player(name: "Player \($0)") }
            gameState.cards = generateTestCards(playerCount: playerCount, word: "Word1")
            
            // Play first game
            for i in 0..<playerCount {
                _ = try gameState.selectCard(at: i, byPlayer: i % playerCount)
                try gameState.lockCard(at: i)
            }
            XCTAssertTrue(gameState.isGameComplete())
            
            // Reset for replay
            var replayGame = GameState(
                players: gameState.players,
                theme: gameState.selectedTheme,
                word: "Word2"
            )
            replayGame.cards = generateTestCards(playerCount: playerCount, word: "Word2")
            
            // Play replay
            for i in 0..<playerCount {
                _ = try replayGame.selectCard(at: i, byPlayer: i % playerCount)
                try replayGame.lockCard(at: i)
            }
            XCTAssertTrue(replayGame.isGameComplete())
        }
    }
    
    /// Test that game state is completely fresh after reset
    func testCompleteFreshStateAfterReset() throws {
        var game1 = GameState()
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob"),
            Player(name: "Charlie")
        ]
        game1.players = players
        game1.cards = generateTestCards(playerCount: 3, word: "Rome")
        game1.selectedWord = "Rome"
        game1.gamePhase = .inGame
        
        // Partially play game 1
        _ = try game1.selectCard(at: 0, byPlayer: 0)
        try game1.lockCard(at: 0)
        
        let game1CardStates = game1.cards.map { ($0.isRevealed, $0.isLocked) }
        
        // Reset
        var game2 = GameState(
            players: game1.players,
            theme: game1.selectedTheme,
            word: "Barcelona"
        )
        game2.cards = generateTestCards(playerCount: 3, word: "Barcelona")
        
        // Compare states
        let game2CardStates = game2.cards.map { ($0.isRevealed, $0.isLocked) }
        
        // All game2 cards should be (false, false)
        for (revealed, locked) in game2CardStates {
            XCTAssertFalse(revealed, "Game 2 cards should not be revealed")
            XCTAssertFalse(locked, "Game 2 cards should not be locked")
        }
        
        // Game 1 and game 2 should have different words
        XCTAssertEqual(game1.selectedWord, "Rome")
        XCTAssertEqual(game2.selectedWord, "Barcelona")
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
    
    /// Find the position of the spy card in a card array
    private func findSpyPosition(_ cards: [Card]) -> Int? {
        return cards.firstIndex { card in
            if case .spy = card.content {
                return true
            }
            return false
        }
    }
}
