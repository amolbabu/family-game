import Foundation

enum AppScreen {
    case welcome
    case setup
    case game
}

enum Theme: String, CaseIterable {
    case place = "Place"
    case country = "Country"
    case things = "Things"
}

@Observable
class AppState {
    var currentScreen: AppScreen = .welcome
    var playerCount: Int = 3
    var playerNames: [String] = []
    var selectedTheme: Theme = .country
    
    init() {
        updatePlayerNames(for: playerCount)
    }
    
    func updatePlayerNames(for count: Int) {
        playerNames = (1...count).map { "Player \($0)" }
    }
    
    func setPlayerCount(_ count: Int) {
        playerCount = count
        updatePlayerNames(for: count)
    }
    
    func updatePlayerName(_ index: Int, to name: String) {
        if index >= 0 && index < playerNames.count {
            playerNames[index] = name
        }
    }
    
    func startGame() {
        currentScreen = .game
    }
    
    func goToSetup() {
        currentScreen = .setup
    }
    
    func resetGame() {
        currentScreen = .welcome
        playerCount = 3
        selectedTheme = .country
        updatePlayerNames(for: playerCount)
    }
}
