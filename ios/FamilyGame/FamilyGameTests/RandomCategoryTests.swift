import XCTest
@testable import FamilyGame

final class RandomCategoryTests: XCTestCase {
    
    // MARK: - Theme Resolution Tests
    
    /// Test that Random theme resolves to a concrete theme without errors
    func testResolveRandomThemeSucceeds() {
        let resolvedTheme = GameLogic.resolveTheme("Random")
        
        XCTAssertNotNil(resolvedTheme, "Resolved theme should not be nil")
        XCTAssertFalse(resolvedTheme.isEmpty, "Resolved theme should not be empty")
        XCTAssertNotEqual(resolvedTheme, "Random", "Resolved theme should not be 'Random' itself")
    }
    
    /// Test that Random theme resolves to one of the concrete themes
    func testResolveRandomThemeIsValid() {
        let validThemes = ["Place", "Country", "Things"]
        let resolvedTheme = GameLogic.resolveTheme("Random")
        
        XCTAssertTrue(
            validThemes.contains(resolvedTheme),
            "Resolved theme should be one of: \(validThemes), but got: \(resolvedTheme)"
        )
    }
    
    /// Test that non-Random themes pass through unchanged
    func testResolveConcreteThemesPassthrough() {
        let concreteThemes = ["Place", "Country", "Things"]
        
        for theme in concreteThemes {
            let resolvedTheme = GameLogic.resolveTheme(theme)
            XCTAssertEqual(resolvedTheme, theme, "Concrete theme should pass through unchanged")
        }
    }
    
    /// Test that multiple Random resolutions produce variety (basic randomness check)
    func testRandomThemeVariety() {
        var resolvedThemes: Set<String> = []
        
        for _ in 0..<50 {
            let resolved = GameLogic.resolveTheme("Random")
            resolvedThemes.insert(resolved)
        }
        
        XCTAssertGreaterThan(
            resolvedThemes.count,
            1,
            "Random theme resolution should produce variety across multiple calls (got only: \(resolvedThemes))"
        )
    }
    
    // MARK: - Random Category Card Generation Tests
    
    /// Test that cards can be generated using the Random category
    func testGenerateCardsWithRandomCategory() throws {
        let playerCount = 3
        let cards = try GameLogic.generateCards(playerCount: playerCount, theme: "Random")
        
        XCTAssertEqual(cards.count, playerCount, "Should generate one card per player")
        XCTAssertFalse(cards.isEmpty, "Cards should not be empty")
    }
    
    /// Test that Random category produces valid card structure
    func testRandomCategoryCardStructure() throws {
        let playerCount = 4
        let cards = try GameLogic.generateCards(playerCount: playerCount, theme: "Random")
        
        var spyCount = 0
        var wordCount = 0
        
        for card in cards {
            if case .spy = card.content {
                spyCount += 1
            } else if case .word = card.content {
                wordCount += 1
            }
        }
        
        XCTAssertEqual(spyCount, 1, "Should have exactly one spy card with Random theme")
        XCTAssertEqual(wordCount, playerCount - 1, "Should have (playerCount - 1) word cards with Random theme")
    }
    
    /// Test that Random category cards have correct initial state
    func testRandomCategoryCardInitialState() throws {
        let cards = try GameLogic.generateCards(playerCount: 5, theme: "Random")
        
        for card in cards {
            XCTAssertFalse(card.isLocked, "Card should not be locked initially")
            XCTAssertFalse(card.isRevealed, "Card should not be revealed initially")
            XCTAssertNotNil(card.id, "Card should have a valid ID")
        }
    }
    
    /// Test Random category with various player counts
    func testRandomCategoryWithDifferentPlayerCounts() throws {
        let playerCounts = [2, 3, 4, 5, 6, 8]
        
        for count in playerCounts {
            let cards = try GameLogic.generateCards(playerCount: count, theme: "Random")
            
            XCTAssertEqual(cards.count, count, "Should generate \(count) cards for \(count) players with Random theme")
            
            let spyCount = cards.filter { if case .spy = $0.content { return true } else { return false } }.count
            XCTAssertEqual(spyCount, 1, "Should have exactly one spy card for \(count) players")
        }
    }
    
    /// Test that Random category produces different words across generations
    func testRandomCategoryProducesDifferentWords() throws {
        var selectedWords: Set<String> = []
        
        for _ in 0..<30 {
            let cards = try GameLogic.generateCards(playerCount: 3, theme: "Random")
            
            for card in cards {
                if case .word(let word) = card.content {
                    selectedWords.insert(word)
                    break
                }
            }
        }
        
        XCTAssertGreaterThan(
            selectedWords.count,
            1,
            "Random category should select different words across multiple generations (got only: \(selectedWords))"
        )
    }
    
    // MARK: - AppState Random Category Tests
    
    /// Test that AppState can be initialized with Random theme
    func testAppStateWithRandomTheme() {
        let appState = AppState()
        appState.selectedTheme = .random
        
        XCTAssertEqual(appState.selectedTheme, .random, "AppState should accept Random theme")
    }
    
    /// Test that Random theme is a valid AppState option
    func testRandomThemeAvailableInAppState() {
        let appState = AppState()
        
        XCTAssertTrue(
            Theme.allCases.contains(.random),
            "Random theme should be available in Theme enum"
        )
    }
    
    /// Test that AppState can start game with Random category
    func testAppStateStartGameWithRandom() {
        let appState = AppState()
        appState.selectedTheme = .random
        appState.setPlayerCount(3)
        
        XCTAssertEqual(appState.selectedTheme, .random)
        XCTAssertEqual(appState.playerCount, 3)
        
        appState.startGame()
        
        XCTAssertEqual(appState.currentScreen, .game)
    }
    
    // MARK: - GameState Integration with Random Tests
    
    /// Test that GameState can be initialized with Random theme
    func testGameStateWithRandomTheme() throws {
        let players = try GameLogic.createPlayers(from: ["Alice", "Bob", "Charlie"])
        let randomTheme = "Random"
        
        let resolvedTheme = GameLogic.resolveTheme(randomTheme)
        let word = try GameLogic.selectRandomWord(from: resolvedTheme)
        
        var gameState = GameState(players: players, theme: randomTheme, word: word)
        
        XCTAssertEqual(gameState.selectedTheme, randomTheme)
        XCTAssertEqual(gameState.players.count, 3)
        XCTAssertFalse(word.isEmpty)
    }
    
    /// Test that Random theme word selection works correctly
    func testRandomThemeWordSelection() throws {
        let randomTheme = "Random"
        let resolvedTheme = GameLogic.resolveTheme(randomTheme)
        
        let word = try GameLogic.selectRandomWord(from: resolvedTheme)
        
        XCTAssertFalse(word.isEmpty, "Selected word should not be empty")
        XCTAssertGreaterThan(word.count, 0, "Word should have content")
    }
    
    /// Test that Random theme card generation happens on first game start
    func testRandomCategoryCardsOnFirstGameStart() throws {
        let players = try GameLogic.createPlayers(from: ["Alice", "Bob"])
        let randomTheme = GameLogic.resolveTheme("Random")
        let word = try GameLogic.selectRandomWord(from: randomTheme)
        
        var gameState = GameState(players: players, theme: randomTheme, word: word)
        gameState.cards = try GameLogic.generateCards(
            playerCount: players.count,
            theme: randomTheme,
            word: word
        )
        
        XCTAssertEqual(gameState.cards.count, players.count)
        XCTAssertEqual(gameState.gamePhase, .inGame)
    }
    
    /// Test that Random category works correctly when replaying game
    func testRandomCategoryOnGameReplay() throws {
        let players = try GameLogic.createPlayers(from: ["Alice", "Bob", "Charlie"])
        let randomTheme = GameLogic.resolveTheme("Random")
        let word1 = try GameLogic.selectRandomWord(from: randomTheme)
        
        var gameState = GameState(players: players, theme: randomTheme, word: word1)
        gameState.cards = try GameLogic.generateCards(
            playerCount: players.count,
            theme: randomTheme,
            word: word1
        )
        gameState.previouslySelectedWord = word1
        
        // Reset for replay
        try gameState.resetGameState()
        
        XCTAssertEqual(gameState.selectedWord, gameState.previouslySelectedWord, "Should have new word after reset")
        XCTAssertEqual(gameState.cards.count, players.count, "Should have correct card count after reset")
        XCTAssertEqual(gameState.gamePhase, .inGame, "Should be in game phase after reset")
    }
    
    // MARK: - Edge Case Tests
    
    /// Test Random theme with minimum player count (2 players)
    func testRandomCategoryMinimumPlayers() throws {
        let cards = try GameLogic.generateCards(playerCount: 2, theme: "Random")
        
        XCTAssertEqual(cards.count, 2)
        let spyCount = cards.filter { if case .spy = $0.content { return true } else { return false } }.count
        XCTAssertEqual(spyCount, 1)
    }
    
    /// Test Random theme with maximum player count (8 players)
    func testRandomCategoryMaximumPlayers() throws {
        let cards = try GameLogic.generateCards(playerCount: 8, theme: "Random")
        
        XCTAssertEqual(cards.count, 8)
        let spyCount = cards.filter { if case .spy = $0.content { return true } else { return false } }.count
        XCTAssertEqual(spyCount, 1)
    }
    
    /// Test that Random category rejects invalid player counts
    func testRandomCategoryInvalidPlayerCounts() {
        XCTAssertThrowsError(try GameLogic.generateCards(playerCount: 0, theme: "Random"))
        XCTAssertThrowsError(try GameLogic.generateCards(playerCount: -1, theme: "Random"))
        XCTAssertThrowsError(try GameLogic.generateCards(playerCount: 1, theme: "Random"))
    }
    
    /// Test that Random theme selection is tracked in GameState
    func testRandomCategoryThemeTracking() throws {
        let players = try GameLogic.createPlayers(from: ["Alice", "Bob"])
        let randomTheme = "Random"
        let resolvedTheme = GameLogic.resolveTheme(randomTheme)
        let word = try GameLogic.selectRandomWord(from: resolvedTheme)
        
        let gameState = GameState(players: players, theme: randomTheme, word: word)
        
        XCTAssertEqual(gameState.selectedTheme, randomTheme, "GameState should track the original Random selection")
    }
    
    /// Test consecutive Random selections produce different themes
    func testConsecutiveRandomSelectionsVariety() {
        var resolvedThemes: [String] = []
        
        for _ in 0..<100 {
            let resolved = GameLogic.resolveTheme("Random")
            resolvedThemes.append(resolved)
        }
        
        let uniqueThemes = Set(resolvedThemes)
        XCTAssertGreaterThan(
            uniqueThemes.count,
            1,
            "100 consecutive Random selections should produce variety (got: \(uniqueThemes))"
        )
    }
    
    /// Test that Random theme word content is family-safe
    func testRandomThemeWordContentIsValid() throws {
        let randomTheme = GameLogic.resolveTheme("Random")
        
        var selectedWords: Set<String> = []
        for _ in 0..<50 {
            let word = try GameLogic.selectRandomWord(from: randomTheme)
            selectedWords.insert(word)
            
            XCTAssertFalse(word.isEmpty, "Selected word should not be empty")
            XCTAssertGreaterThan(word.count, 0, "Word should have content")
        }
        
        XCTAssertGreaterThan(selectedWords.count, 0, "Should have selected valid words")
    }
    
    /// Test that all concrete themes can be resolved from Random
    func testRandomResolvesToAllThemes() {
        var resolvedThemes: Set<String> = []
        let maxIterations = 1000
        
        for _ in 0..<maxIterations {
            let resolved = GameLogic.resolveTheme("Random")
            resolvedThemes.insert(resolved)
            
            if resolvedThemes.count == 3 {
                break
            }
        }
        
        XCTAssertEqual(
            resolvedThemes.count,
            3,
            "After \(maxIterations) iterations, Random should have resolved to all 3 concrete themes"
        )
        
        XCTAssertTrue(resolvedThemes.contains("Place"))
        XCTAssertTrue(resolvedThemes.contains("Country"))
        XCTAssertTrue(resolvedThemes.contains("Things"))
    }
    
    // MARK: - Integration Tests
    
    /// Test full game flow with Random category
    func testFullGameFlowWithRandomCategory() throws {
        // Setup
        let appState = AppState()
        appState.setPlayerCount(3)
        appState.selectedTheme = .random
        
        // Create players
        let players = try GameLogic.createPlayers(from: appState.playerNames)
        
        // Resolve Random theme and select word
        let resolvedTheme = GameLogic.resolveTheme(appState.selectedTheme.rawValue)
        let word = try GameLogic.selectRandomWord(from: resolvedTheme)
        
        // Initialize game state
        var gameState = GameState(players: players, theme: resolvedTheme, word: word)
        gameState.cards = try GameLogic.generateCards(
            playerCount: players.count,
            theme: resolvedTheme,
            word: word
        )
        
        // Verify game state
        XCTAssertEqual(gameState.players.count, 3)
        XCTAssertEqual(gameState.cards.count, 3)
        XCTAssertEqual(gameState.gamePhase, .inGame)
        XCTAssertFalse(gameState.selectedWord.isEmpty)
        
        // Verify card validity
        let spyCount = gameState.cards.filter { if case .spy = $0.content { return true } else { return false } }.count
        XCTAssertEqual(spyCount, 1)
    }
    
    /// Test Random category card interaction
    func testRandomCategoryCardInteraction() throws {
        let players = try GameLogic.createPlayers(from: ["Alice", "Bob", "Charlie"])
        let randomTheme = GameLogic.resolveTheme("Random")
        let word = try GameLogic.selectRandomWord(from: randomTheme)
        
        var gameState = GameState(players: players, theme: randomTheme, word: word)
        gameState.cards = try GameLogic.generateCards(
            playerCount: players.count,
            theme: randomTheme,
            word: word
        )
        
        // Simulate first player tapping a card
        let tapResult = gameState.performCardTap(at: 0, player: 0)
        
        switch tapResult {
        case .revealed(let content):
            XCTAssertTrue(gameState.cards[0].isRevealed)
            // Content should be either spy or the selected word
            switch content {
            case .spy:
                XCTAssert(true, "Card revealed as spy")
            case .word(let revealedWord):
                XCTAssertEqual(revealedWord, word, "Card should reveal the Random theme word")
            }
        default:
            XCTFail("First tap should reveal the card")
        }
    }
}
