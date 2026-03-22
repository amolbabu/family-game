import Foundation

// MARK: - AppState
enum AppScreen {
    case welcome
    case setup
    case game
    case endGame
}

enum Theme: String, CaseIterable {
    case place = "Place"
    case country = "Country"
    case things = "Things"
    case random = "Random"
}

@available(iOS 17.0, macOS 14.0, *)
@Observable
class AppState {
    //MARK: - Properties
    var currentScreen: AppScreen = .welcome
    var playerCount: Int = 3
    var playerNames: [String] = []
    var selectedTheme: Theme = .country
    
    //MARK: - Initialization
    init() {
        updatePlayerNames(for: playerCount)
    }
    
    //MARK: - Mutations
    func updatePlayerNames(for count: Int) {
        playerNames = (1...count).map { "Player \($0)" }
    }
    
    func setPlayerCount(_ count: Int) {
        playerCount = count
        updatePlayerNames(for: count)
        print("[AppState] Player count set to \(count)")
    }
    
    func updatePlayerName(_ index: Int, to name: String) {
        if index >= 0 && index < playerNames.count {
            playerNames[index] = name
            print("[AppState] Player \(index) name updated to '\(name)'")
        }
    }
    
    func startGame() {
        currentScreen = .game
        print("[Game] startGame called - players: \(playerNames), theme: \(selectedTheme.rawValue)")
    }
    
    func goToSetup() {
        currentScreen = .setup
        print("[Navigation] goToSetup called")
    }
    
    func resetGame() {
        currentScreen = .welcome
        playerCount = 3
        selectedTheme = .country
        updatePlayerNames(for: playerCount)
        print("[AppState] resetGame called - reset to defaults")
    }
    
    func goToEndGame() {
        currentScreen = .endGame
        print("[Navigation] goToEndGame called")
    }
}
