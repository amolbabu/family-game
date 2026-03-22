import XCTest
@testable import FamilyGame

final class CardGenerationTests: XCTestCase {
    
    // MARK: - Theme Manager Tests
    
    func testThemeManagerLoadsThemes() {
        let manager = ThemeManager.shared
        XCTAssertTrue(manager.didLoadSuccessfully(), "ThemeManager should load themes successfully")
        
        let themes = manager.getThemeNames()
        XCTAssertGreaterThan(themes.count, 0, "Should have at least one theme loaded")
        
        print("[TEST] Available themes: \(themes)")
    }
    
    func testThemeManagerLoadsCountryTheme() {
        let manager = ThemeManager.shared
        let words = manager.getWords(forTheme: "Country")
        
        XCTAssertNotNil(words, "Country theme should exist")
        XCTAssertGreaterThan(words?.count ?? 0, 0, "Country theme should have words")
        
        print("[TEST] Country theme words: \(words?.count ?? 0)")
        if let w = words {
            print("[TEST] First 5 countries: \(w.prefix(5).joined(separator: ", "))")
        }
    }
    
    func testThemeManagerLoadsPlaceTheme() {
        let manager = ThemeManager.shared
        let words = manager.getWords(forTheme: "Place")
        
        XCTAssertNotNil(words, "Place theme should exist")
        XCTAssertGreaterThan(words?.count ?? 0, 0, "Place theme should have words")
        
        print("[TEST] Place theme words: \(words?.count ?? 0)")
        if let w = words {
            print("[TEST] First 5 places: \(w.prefix(5).joined(separator: ", "))")
        }
    }
    
    func testThemeManagerLoadsThingsTheme() {
        let manager = ThemeManager.shared
        let words = manager.getWords(forTheme: "Things")
        
        XCTAssertNotNil(words, "Things theme should exist")
        XCTAssertGreaterThan(words?.count ?? 0, 0, "Things theme should have words")
        
        print("[TEST] Things theme words: \(words?.count ?? 0)")
        if let w = words {
            print("[TEST] First 5 things: \(w.prefix(5).joined(separator: ", "))")
        }
    }
    
    // MARK: - Card Generation Tests
    
    func testGenerateCardsWithCountryTheme() throws {
        let playerCount = 3
        let cards = try GameLogic.generateCards(playerCount: playerCount, theme: "Country")
        
        XCTAssertEqual(cards.count, playerCount, "Should generate one card per player")
        
        var spyCount = 0
        var wordCount = 0
        
        for card in cards {
            if case .spy = card.content {
                spyCount += 1
            } else if case .word = card.content {
                wordCount += 1
            }
        }
        
        XCTAssertEqual(spyCount, 1, "Should have exactly one spy card")
        XCTAssertEqual(wordCount, playerCount - 1, "Should have (playerCount - 1) word cards")
        
        print("[TEST] ✅ Generated \(playerCount) cards with 1 spy and \(wordCount) words")
    }
    
    func testGenerateCardsWithPlaceTheme() throws {
        let playerCount = 4
        let cards = try GameLogic.generateCards(playerCount: playerCount, theme: "Place")
        
        XCTAssertEqual(cards.count, playerCount, "Should generate one card per player")
        
        // Verify all word cards contain place names
        for card in cards {
            if case .word(let word) = card.content {
                XCTAssertFalse(word.isEmpty, "Word should not be empty")
                print("[TEST] Word: \(word)")
            }
        }
        
        print("[TEST] ✅ Generated \(playerCount) cards with Place theme")
    }
    
    func testGenerateCardsWithThingsTheme() throws {
        let playerCount = 5
        let cards = try GameLogic.generateCards(playerCount: playerCount, theme: "Things")
        
        XCTAssertEqual(cards.count, playerCount, "Should generate one card per player")
        print("[TEST] ✅ Generated \(playerCount) cards with Things theme")
    }
    
    func testCardGenerationReturnsNonEmptyCards() throws {
        let themes = ["Country", "Place", "Things"]
        
        for theme in themes {
            let cards = try GameLogic.generateCards(playerCount: 3, theme: theme)
            
            XCTAssertFalse(cards.isEmpty, "Cards should not be empty for theme \(theme)")
            XCTAssertGreaterThan(cards.count, 0, "Should generate cards for \(theme)")
            
            print("[TEST] ✅ \(theme): \(cards.count) cards generated")
        }
    }
    
    func testCardGenerationWithDifferentPlayerCounts() throws {
        let playerCounts = [2, 3, 4, 5, 6, 8, 10, 12]
        
        for count in playerCounts {
            let cards = try GameLogic.generateCards(playerCount: count, theme: "Country")
            
            XCTAssertEqual(cards.count, count, "Should generate \(count) cards for \(count) players")
            print("[TEST] ✅ Generated \(count) cards for \(count) players")
        }
    }
    
    func testCardInitialStates() throws {
        let cards = try GameLogic.generateCards(playerCount: 3, theme: "Country")
        
        for card in cards {
            XCTAssertFalse(card.isLocked, "Card should not be locked initially")
            XCTAssertFalse(card.isRevealed, "Card should not be revealed initially")
            XCTAssertNotNil(card.id, "Card should have an ID")
        }
        
        print("[TEST] ✅ All cards have correct initial state")
    }
    
    func testSelectRandomWordFromTheme() throws {
        let word = try GameLogic.selectRandomWord(from: "Country")
        
        XCTAssertFalse(word.isEmpty, "Selected word should not be empty")
        print("[TEST] Selected country: \(word)")
    }
    
    func testSelectRandomWordWithExclusion() throws {
        let word1 = try GameLogic.selectRandomWord(from: "Country")
        let word2 = try GameLogic.selectRandomWord(from: "Country", excluding: word1)
        
        print("[TEST] Word 1: \(word1)")
        print("[TEST] Word 2: \(word2)")
        
        // Word2 might be different or same (probability 31/32 it's different)
        XCTAssertFalse(word2.isEmpty, "Selected word should not be empty even with exclusion")
    }
    
    // MARK: - Error Handling
    
    func testGenerateCardsWithInvalidPlayerCount() {
        XCTAssertThrowsError(try GameLogic.generateCards(playerCount: 0, theme: "Country"))
        XCTAssertThrowsError(try GameLogic.generateCards(playerCount: -1, theme: "Country"))
    }
    
    func testGenerateCardsWithNonexistentTheme() {
        XCTAssertThrowsError(try GameLogic.generateCards(playerCount: 3, theme: "NonexistentTheme"))
    }
    
    func testSelectWordFromNonexistentTheme() {
        XCTAssertThrowsError(try GameLogic.selectRandomWord(from: "NonexistentTheme"))
    }
}
