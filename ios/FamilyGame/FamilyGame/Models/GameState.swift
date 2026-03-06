import Foundation

enum GamePhase: String, Codable {
    case setup
    case inGame
    case endGame
}

struct GameState: Codable {
    var gamePhase: GamePhase = .setup
    var players: [Player] = []
    var currentPlayerIndex: Int = 0
    var cards: [Card] = []
    var revealedCards: Set<Int> = []
    var selectedTheme: String = ""
    var selectedWord: String = ""
    var gameStartTime: Date?
    
    init() {}
    
    init(players: [Player], theme: String, word: String) {
        self.players = players
        self.selectedTheme = theme
        self.selectedWord = word
        self.gamePhase = .inGame
        self.gameStartTime = Date()
    }
    
    mutating func selectCard(at index: Int, byPlayer playerIndex: Int) throws -> CardContent {
        guard index >= 0 && index < cards.count else {
            throw GameError.invalidCardIndex
        }
        guard !cards[index].isLocked else {
            throw GameError.cardAlreadyLocked
        }
        guard playerIndex >= 0 && playerIndex < players.count else {
            throw GameError.invalidPlayerIndex
        }
        
        cards[index].isRevealed = true
        return cards[index].content
    }
    
    mutating func lockCard(at index: Int) throws {
        guard index >= 0 && index < cards.count else {
            throw GameError.invalidCardIndex
        }
        cards[index].isRevealed = false
        cards[index].isLocked = true
        revealedCards.insert(index)
    }
    
    mutating func nextPlayer() {
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
    }
    
    func isGameComplete() -> Bool {
        return revealedCards.count == cards.count
    }
}

enum GameError: Error {
    case invalidCardIndex
    case cardAlreadyLocked
    case invalidPlayerIndex
    case noCardsGenerated
}
