import Foundation

/// Encapsulates turn-based game validation rules
/// Prevents invalid state transitions and provides clear error messages
struct TurnValidator {
    
    // MARK: - Card Index Validation
    
    /// Validates that a card index is within valid range
    static func isValidCardIndex(_ index: Int, in cardCount: Int) -> Bool {
        return index >= 0 && index < cardCount
    }
    
    /// Validates that a player index is valid
    static func isValidPlayerIndex(_ index: Int, in playerCount: Int) -> Bool {
        return index >= 0 && index < playerCount
    }
    
    // MARK: - Card State Validation
    
    /// Checks if a card is available for revealing
    /// A card must not be locked and must not be already revealed
    static func canRevealCard(_ card: Card) -> Bool {
        return !card.isLocked && !card.isRevealed
    }
    
    /// Checks if a card is currently revealed and can be hidden
    static func canHideCard(_ card: Card) -> Bool {
        return card.isRevealed && !card.isLocked
    }
    
    /// Checks if a revealed card can be locked
    static func canLockCard(_ card: Card) -> Bool {
        return card.isRevealed
    }
    
    // MARK: - Turn State Validation
    
    /// Checks if player is attempting to tap a card during their turn
    static func isPlayersTurn(_ playerIndex: Int, currentPlayerIndex: Int) -> Bool {
        return playerIndex == currentPlayerIndex
    }
    
    /// Checks if there is another card currently revealed that must be hidden first
    /// User should not be able to reveal multiple cards simultaneously
    static func hasRevealedCard(in cards: [Card]) -> Bool {
        return cards.contains { $0.isRevealed }
    }
    
    /// Counts how many cards are still available (not locked)
    static func availableCardCount(in cards: [Card]) -> Int {
        return cards.filter { !$0.isLocked }.count
    }
}
