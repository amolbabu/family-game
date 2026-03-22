import Foundation

class GameLogic {
    
    // MARK: - Card Generation
    
    /// Generates cards for the game
    /// - Parameters:
    ///   - playerCount: Number of players (number of cards to generate)
    ///   - theme: Theme name to select word from
    ///   - word: Specific word to use (if nil, randomly selects from theme)
    /// - Returns: Array of cards with exactly one spy card
    static func generateCards(
        playerCount: Int,
        theme: String,
        word: String? = nil
    ) throws -> [Card] {
        guard playerCount > 0 else {
            throw GameLogicError.invalidPlayerCount
        }
        
        // Determine the word to use
        var selectedWord = word
        if selectedWord == nil {
            selectedWord = try selectRandomWord(from: theme)
        }
        
        guard let finalWord = selectedWord else {
            throw GameLogicError.noWordSelected
        }
        
        // Generate spy position randomly
        let spyIndex = Int.random(in: 0..<playerCount)
        
        // Create cards
        var cards: [Card] = []
        for index in 0..<playerCount {
            let content: CardContent
            if index == spyIndex {
                content = .spy
            } else {
                content = .word(finalWord)
            }
            // Build the card and log its initial state with timestamp
            let card = Card(content: content, isRevealed: false, isLocked: false)
            let isSpy: Bool
            if case .spy = content {
                isSpy = true
            } else {
                isSpy = false
            }
            print("[TRACE] \(Date()) GameLogic.generateCards: Creating card \(index) - spy: \(isSpy), isRevealed: \(card.isRevealed)")
            cards.append(card)
        }
        
        return cards
    }
    
    // MARK: - Word Selection
    
    /// Selects a random word from a theme
    /// - Parameters:
    ///   - theme: Theme name
    ///   - excluding: Optional word to exclude from selection (prevents consecutive use)
    /// - Returns: Random word from theme
    static func selectRandomWord(from theme: String, excluding excludedWord: String? = nil) throws -> String {
        guard let words = ThemeManager.shared.getWords(forTheme: theme) else {
            throw GameLogicError.themeNotFound(theme)
        }
        
        guard !words.isEmpty else {
            throw GameLogicError.emptyTheme(theme)
        }
        
        // Filter out the excluded word if provided
        let availableWords = excludedWord != nil ? words.filter { $0 != excludedWord } : words
        
        guard !availableWords.isEmpty else {
            throw GameLogicError.noWordSelected
        }
        
        guard let randomWord = availableWords.randomElement() else {
            throw GameLogicError.noWordSelected
        }
        
        return randomWord
    }
    
    // MARK: - Player Setup
    
    /// Creates players from names
    /// - Parameter names: Array of player names
    /// - Returns: Array of Player objects with randomly assigned spy role
    static func createPlayers(from names: [String]) throws -> [Player] {
        guard !names.isEmpty else {
            throw GameLogicError.invalidPlayerCount
        }
        
        // Assign one random player as spy
        let spyIndex = Int.random(in: 0..<names.count)
        
        var players: [Player] = []
        for (index, name) in names.enumerated() {
            let role: PlayerRole = index == spyIndex ? .spy : .normal
            players.append(Player(name: name, role: role))
        }
        
        return players
    }
}

enum GameLogicError: Error, LocalizedError {
    case invalidPlayerCount
    case themeNotFound(String)
    case emptyTheme(String)
    case noWordSelected
    
    var errorDescription: String? {
        switch self {
        case .invalidPlayerCount:
            return "Invalid player count. Must be at least 1."
        case .themeNotFound(let theme):
            return "Theme '\(theme)' not found."
        case .emptyTheme(let theme):
            return "Theme '\(theme)' has no words."
        case .noWordSelected:
            return "Failed to select a word."
        }
    }
}
