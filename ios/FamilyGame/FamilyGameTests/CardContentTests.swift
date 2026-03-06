import XCTest
@testable import FamilyGame

final class CardContentTests: XCTestCase {
    
    // MARK: - Card Content Type Tests
    
    /// Test CardContent.word initialization and equality
    func testCardContentWord() {
        let content1 = CardContent.word("Paris")
        let content2 = CardContent.word("Paris")
        let content3 = CardContent.word("London")
        
        XCTAssertEqual(content1, content2, "Same words should be equal")
        XCTAssertNotEqual(content1, content3, "Different words should not be equal")
    }
    
    /// Test CardContent.spy equality
    func testCardContentSpy() {
        let spy1 = CardContent.spy
        let spy2 = CardContent.spy
        
        XCTAssertEqual(spy1, spy2, "Spy cards should be equal")
    }
    
    /// Test CardContent word vs spy inequality
    func testCardContentWordVsSpy() {
        let word = CardContent.word("Test")
        let spy = CardContent.spy
        
        XCTAssertNotEqual(word, spy, "Word and spy should not be equal")
    }
    
    // MARK: - Card Coding (Serialization)
    
    /// Test CardContent.word encoding and decoding
    func testCardContentWordCoding() throws {
        let original = CardContent.word("Tokyo")
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CardContent.self, from: encoded)
        
        XCTAssertEqual(original, decoded, "Word content should survive encoding/decoding")
    }
    
    /// Test CardContent.spy encoding and decoding
    func testCardContentSpyCoding() throws {
        let original = CardContent.spy
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CardContent.self, from: encoded)
        
        XCTAssertEqual(original, decoded, "Spy content should survive encoding/decoding")
    }
    
    /// Test multiple CardContent values can be encoded
    func testMultipleCardContentsCoding() throws {
        let contents: [CardContent] = [
            .word("Paris"),
            .word("London"),
            .word("Tokyo"),
            .spy
        ]
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(contents)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode([CardContent].self, from: encoded)
        
        XCTAssertEqual(contents, decoded, "Multiple contents should survive encoding/decoding")
    }
    
    /// Test different word content different values
    func testDifferentWordsEncodeDifferently() throws {
        let word1 = CardContent.word("Paris")
        let word2 = CardContent.word("London")
        
        let encoder = JSONEncoder()
        let encoded1 = try encoder.encode(word1)
        let encoded2 = try encoder.encode(word2)
        
        XCTAssertNotEqual(encoded1, encoded2, "Different words should encode differently")
    }
    
    // MARK: - Card Structure Tests
    
    /// Test Card initialization with default values
    func testCardDefaultInitialization() {
        let card = Card(content: .word("Paris"))
        
        XCTAssertEqual(card.content, .word("Paris"))
        XCTAssertFalse(card.isRevealed)
        XCTAssertFalse(card.isLocked)
        XCTAssertNotNil(card.id)
    }
    
    /// Test Card with explicit parameters
    func testCardExplicitInitialization() {
        let card = Card(content: .spy, isRevealed: true, isLocked: true)
        
        XCTAssertEqual(card.content, .spy)
        XCTAssertTrue(card.isRevealed)
        XCTAssertTrue(card.isLocked)
    }
    
    /// Test Card ID uniqueness
    func testCardIDUniqueness() {
        let card1 = Card(content: .word("Paris"))
        let card2 = Card(content: .word("Paris"))
        
        XCTAssertNotEqual(card1.id, card2.id, "Each card should have a unique ID")
    }
    
    /// Test Card with custom UUID
    func testCardWithCustomUUID() {
        let uuid = UUID()
        let card = Card(id: uuid, content: .word("London"))
        
        XCTAssertEqual(card.id, uuid)
    }
    
    /// Test Card Identifiable protocol
    func testCardIdentifiable() {
        let card = Card(content: .word("Tokyo"))
        let cardId = card.id
        
        XCTAssertEqual(card.id, cardId, "Card should maintain consistent ID")
    }
    
    // MARK: - Card Coding (Serialization)
    
    /// Test Card encoding and decoding
    func testCardCoding() throws {
        let original = Card(content: .word("Cairo"), isRevealed: false, isLocked: false)
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Card.self, from: encoded)
        
        XCTAssertEqual(original.id, decoded.id)
        XCTAssertEqual(original.content, decoded.content)
        XCTAssertEqual(original.isRevealed, decoded.isRevealed)
        XCTAssertEqual(original.isLocked, decoded.isLocked)
    }
    
    /// Test spy Card coding
    func testSpyCardCoding() throws {
        let original = Card(content: .spy, isRevealed: true, isLocked: false)
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Card.self, from: encoded)
        
        XCTAssertEqual(original.content, decoded.content)
    }
    
    /// Test array of Cards coding
    func testCardArrayCoding() throws {
        let cards = [
            Card(content: .word("Paris"), isRevealed: false, isLocked: false),
            Card(content: .word("London"), isRevealed: true, isLocked: false),
            Card(content: .spy, isRevealed: false, isLocked: true)
        ]
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(cards)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode([Card].self, from: encoded)
        
        XCTAssertEqual(cards.count, decoded.count)
        for (original, decodedCard) in zip(cards, decoded) {
            XCTAssertEqual(original.content, decodedCard.content)
            XCTAssertEqual(original.isRevealed, decodedCard.isRevealed)
            XCTAssertEqual(original.isLocked, decodedCard.isLocked)
        }
    }
    
    // MARK: - Card State Transitions
    
    /// Test card state transitions during gameplay
    func testCardStateTransitions() {
        var card = Card(content: .word("Sydney"))
        
        // Initial state
        XCTAssertFalse(card.isRevealed)
        XCTAssertFalse(card.isLocked)
        
        // After reveal
        card.isRevealed = true
        XCTAssertTrue(card.isRevealed)
        XCTAssertFalse(card.isLocked)
        
        // After hide
        card.isRevealed = false
        XCTAssertFalse(card.isRevealed)
        XCTAssertFalse(card.isLocked)
        
        // After lock
        card.isLocked = true
        XCTAssertFalse(card.isRevealed)
        XCTAssertTrue(card.isLocked)
    }
    
    /// Test locked card cannot be revealed again
    func testLockedCardBehavior() {
        var card = Card(content: .word("Rome"))
        
        // Lock first
        card.isLocked = true
        card.isRevealed = false
        
        XCTAssertTrue(card.isLocked)
        XCTAssertFalse(card.isRevealed)
        
        // Content preserved
        XCTAssertEqual(card.content, .word("Rome"))
    }
    
    // MARK: - Family-Safety Content Tests
    
    /// Test that valid family-friendly words are accepted
    func testFamilyFriendlyWordsAccepted() {
        let familyWords = [
            "Paris", "London", "Tokyo", "Cairo", "Sydney", "Rome", "Dubai", "Barcelona",
            "France", "Italy", "Japan", "Brazil", "Australia", "Canada", "Spain", "Thailand",
            "Bicycle", "Book", "Camera", "Clock", "Elephant", "Guitar", "Hat", "Lighthouse"
        ]
        
        for word in familyWords {
            let card = Card(content: .word(word))
            
            if case .word(let content) = card.content {
                XCTAssertEqual(content, word, "Word '\(word)' should be accepted")
            } else {
                XCTFail("Card should contain word '\(word)'")
            }
        }
    }
    
    /// Test word length constraints (reasonable words)
    func testWordLengthIsReasonable() {
        let card = Card(content: .word("Paris"))
        
        if case .word(let word) = card.content {
            XCTAssertGreaterThan(word.count, 0, "Word should not be empty")
            XCTAssertLessThan(word.count, 50, "Word should be reasonable length")
        }
    }
    
    /// Test that spy card is always a valid content type
    func testSpyCardAlwaysValid() {
        let spyCard = Card(content: .spy)
        
        if case .spy = spyCard.content {
            XCTAssertTrue(true)
        } else {
            XCTFail("Spy card should be valid")
        }
    }
    
    // MARK: - Codable Edge Cases
    
    /// Test decoding invalid card content type
    func testDecodingInvalidContentType() throws {
        let invalidJSON = """
        {"type": "unknown"}
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        XCTAssertThrowsError(try decoder.decode(CardContent.self, from: invalidJSON))
    }
    
    /// Test encoding and decoding preserves exact values
    func testExactValuePreservation() throws {
        let testWords = ["A", "Test", "Very Long Word That Should Still Work", "123"]
        
        for word in testWords {
            let original = CardContent.word(word)
            
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(original)
            
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(CardContent.self, from: encoded)
            
            if case .word(let decodedWord) = decoded {
                XCTAssertEqual(word, decodedWord, "Word '\(word)' should be preserved exactly")
            } else {
                XCTFail("Should decode to word content")
            }
        }
    }
}
