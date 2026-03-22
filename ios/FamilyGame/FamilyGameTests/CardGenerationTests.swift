import XCTest
@testable import FamilyGame

final class CardGenerationTests: XCTestCase {
    
    // MARK: - Theme Manager Tests
    
    func testThemeManagerLoadsCountryTheme() {
        let manager = ThemeManager.shared
        let words = manager.getWords(forTheme: "Country")
        
        XCTAssertNotNil(words, "Country theme should exist")
        XCTAssertGreaterThan(words?.count ?? 0, 0, "Country theme should have words")
        XCTAssertGreaterThanOrEqual(words?.count ?? 0, 30, "Country theme should have at least 30 countries")
    }
    
    func testThemeManagerLoadsPlaceTheme() {
        let manager = ThemeManager.shared
        let words = manager.getWords(forTheme: "Place")
        
        XCTAssertNotNil(words, "Place theme should exist")
        XCTAssertGreaterThan(words?.count ?? 0, 0, "Place theme should have words")
        XCTAssertGreaterThanOrEqual(words?.count ?? 0, 20, "Place theme should have at least 20 places")
    }
    
    func testThemeManagerLoadsThingsTheme() {
        let manager = ThemeManager.shared
        let words = manager.getWords(forTheme: "Things")
        
        XCTAssertNotNil(words, "Things theme should exist")
        XCTAssertGreaterThan(words?.count ?? 0, 0, "Things theme should have words")
    }
    
    // MARK: - Card Generation Tests
    
    func testGenerateCardsWithCountryTheme() throws {
        let playerCount = 3
        let cards = try GameLogic.generateCards(playerCount: playerCount, theme: "Country")
        
        XCTAssertEqual(cards.count, playerCount, "Should generate one card per player")
        XCTAssertFalse(cards.isEmpty, "Cards should not be empty")
        
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
    }
    
    func testGenerateCardsWithPlaceTheme() throws {
        let playerCount = 4
        let cards = try GameLogic.generateCards(playerCount: playerCount, theme: "Place")
        
        XCTAssertEqual(cards.count, playerCount, "Should generate one card per player")
        XCTAssertFalse(cards.isEmpty, "Cards should not be empty")
    }
    
    func testGenerateCardsWithThingsTheme() throws {
        let playerCount = 5
        let cards = try GameLogic.generateCards(playerCount: playerCount, theme: "Things")
        
        XCTAssertEqual(cards.count, playerCount, "Should generate one card per player")
        XCTAssertFalse(cards.isEmpty, "Cards should not be empty")
    }
    
    func testCardGenerationWithDifferentPlayerCounts() throws {
        let playerCounts = [2, 3, 4, 5, 6, 8, 10, 12]
        
        for count in playerCounts {
            let cards = try GameLogic.generateCards(playerCount: count, theme: "Country")
            
            XCTAssertEqual(cards.count, count, "Should generate \(count) cards for \(count) players")
            XCTAssertFalse(cards.isEmpty, "Cards should not be empty for \(count) players")
        }
    }
    
    func testCardInitialStates() throws {
        let cards = try GameLogic.generateCards(playerCount: 3, theme: "Country")
        
        for card in cards {
            XCTAssertFalse(card.isLocked, "Card should not be locked initially")
            XCTAssertFalse(card.isRevealed, "Card should not be revealed initially")
            XCTAssertNotNil(card.id, "Card should have an ID")
        }
    }
    
    func testSelectRandomWordFromTheme() throws {
        let word = try GameLogic.selectRandomWord(from: "Country")
        
        XCTAssertFalse(word.isEmpty, "Selected word should not be empty")
        XCTAssertGreaterThan(word.count, 0, "Word should have content")
    }
    
    func testSelectRandomWordWithExclusion() throws {
        let word1 = try GameLogic.selectRandomWord(from: "Country")
        let word2 = try GameLogic.selectRandomWord(from: "Country", excluding: word1)
        
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
    
    // MARK: - Place Theme Content Tests
    
    func testPlaceThemeContainsVenues() throws {
        let manager = ThemeManager.shared
        guard let places = manager.getWords(forTheme: "Place") else {
            XCTFail("Place theme should exist")
            return
        }
        
        // Verify actual venue names are there
        let expectedVenues = ["Airport", "Hotel", "Hospital", "Coffee Shop", "Shopping Mall", "Toilet", "Restaurant"]
        for venue in expectedVenues {
            XCTAssertTrue(places.contains(venue), "Place theme should contain '\(venue)'")
        }
    }
    
    // MARK: - Country Theme Content Tests
    
    func testCountryThemeHasVariety() throws {
        let manager = ThemeManager.shared
        guard let countries = manager.getWords(forTheme: "Country") else {
            XCTFail("Country theme should exist")
            return
        }
        
        // Verify we have countries from different regions
        let expectedCountries = ["France", "Japan", "Brazil", "Egypt", "Australia"]
        for country in expectedCountries {
            XCTAssertTrue(countries.contains(country), "Country theme should contain '\(country)'")
        }
    }
}

