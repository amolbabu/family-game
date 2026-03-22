import XCTest
@testable import FamilyGame

final class AppStateTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    /// Test AppState initializes with default values
    func testAppStateDefaultInitialization() {
        let appState = AppState()
        
        XCTAssertEqual(appState.currentScreen, .welcome)
        XCTAssertEqual(appState.playerCount, 3)
        XCTAssertEqual(appState.selectedTheme, .country)
        XCTAssertEqual(appState.playerNames.count, 3)
    }
    
    /// Test AppState generates correct number of default player names
    func testDefaultPlayerNamesCount() {
        let appState = AppState()
        
        XCTAssertEqual(appState.playerNames.count, appState.playerCount)
    }
    
    /// Test AppState default player names format
    func testDefaultPlayerNamesFormat() {
        let appState = AppState()
        
        let expectedNames = ["Player 1", "Player 2", "Player 3"]
        XCTAssertEqual(appState.playerNames, expectedNames)
    }
    
    // MARK: - Player Count Management Tests
    
    /// Test updating player count to 2 (minimum)
    func testSetPlayerCountMinimum() {
        let appState = AppState()
        appState.setPlayerCount(2)
        
        XCTAssertEqual(appState.playerCount, 2)
        XCTAssertEqual(appState.playerNames.count, 2)
        XCTAssertEqual(appState.playerNames, ["Player 1", "Player 2"])
    }
    
    /// Test updating player count to 8 (maximum)
    func testSetPlayerCountMaximum() {
        let appState = AppState()
        appState.setPlayerCount(8)
        
        XCTAssertEqual(appState.playerCount, 8)
        XCTAssertEqual(appState.playerNames.count, 8)
        
        let expectedNames = (1...8).map { "Player \($0)" }
        XCTAssertEqual(appState.playerNames, expectedNames)
    }
    
    /// Test updating player count at various values
    func testSetPlayerCountVariousValues() {
        let appState = AppState()
        
        for count in 2...8 {
            appState.setPlayerCount(count)
            
            XCTAssertEqual(appState.playerCount, count)
            XCTAssertEqual(appState.playerNames.count, count)
            
            let expectedNames = (1...count).map { "Player \($0)" }
            XCTAssertEqual(appState.playerNames, expectedNames)
        }
    }
    
    /// Test player count increase
    func testPlayerCountIncrease() {
        let appState = AppState()
        appState.setPlayerCount(3)
        
        XCTAssertEqual(appState.playerNames.count, 3)
        
        appState.setPlayerCount(5)
        
        XCTAssertEqual(appState.playerCount, 5)
        XCTAssertEqual(appState.playerNames.count, 5)
    }
    
    /// Test player count decrease
    func testPlayerCountDecrease() {
        let appState = AppState()
        appState.setPlayerCount(6)
        
        XCTAssertEqual(appState.playerNames.count, 6)
        
        appState.setPlayerCount(3)
        
        XCTAssertEqual(appState.playerCount, 3)
        XCTAssertEqual(appState.playerNames.count, 3)
    }
    
    // MARK: - Player Name Management Tests
    
    /// Test updating a player name
    func testUpdatePlayerName() {
        let appState = AppState()
        
        appState.updatePlayerName(0, to: "Alice")
        
        XCTAssertEqual(appState.playerNames[0], "Alice")
        XCTAssertEqual(appState.playerNames[1], "Player 2")
        XCTAssertEqual(appState.playerNames[2], "Player 3")
    }
    
    /// Test updating multiple player names
    func testUpdateMultiplePlayerNames() {
        let appState = AppState()
        
        appState.updatePlayerName(0, to: "Alice")
        appState.updatePlayerName(1, to: "Bob")
        appState.updatePlayerName(2, to: "Charlie")
        
        XCTAssertEqual(appState.playerNames, ["Alice", "Bob", "Charlie"])
    }
    
    /// Test updating with special characters in names
    func testUpdatePlayerNameWithSpecialCharacters() {
        let appState = AppState()
        
        appState.updatePlayerName(0, to: "José")
        appState.updatePlayerName(1, to: "O'Brien")
        appState.updatePlayerName(2, to: "Müller")
        
        XCTAssertEqual(appState.playerNames[0], "José")
        XCTAssertEqual(appState.playerNames[1], "O'Brien")
        XCTAssertEqual(appState.playerNames[2], "Müller")
    }
    
    /// Test that invalid player index is ignored
    func testUpdatePlayerNameInvalidIndex() {
        let appState = AppState()
        let originalNames = appState.playerNames
        
        appState.updatePlayerName(-1, to: "Invalid")
        appState.updatePlayerName(10, to: "Invalid")
        
        XCTAssertEqual(appState.playerNames, originalNames)
    }
    
    /// Test updating player name after changing player count
    func testUpdatePlayerNameAfterCountChange() {
        let appState = AppState()
        appState.setPlayerCount(5)
        
        appState.updatePlayerName(3, to: "David")
        appState.updatePlayerName(4, to: "Eve")
        
        XCTAssertEqual(appState.playerNames[3], "David")
        XCTAssertEqual(appState.playerNames[4], "Eve")
    }
    
    // MARK: - Screen Navigation Tests
    
    /// Test navigation to game screen
    func testStartGame() {
        let appState = AppState()
        
        appState.startGame()
        
        XCTAssertEqual(appState.currentScreen, .game)
    }
    
    /// Test navigation back to setup
    func testGoToSetup() {
        let appState = AppState()
        appState.startGame()
        
        appState.goToSetup()
        
        XCTAssertEqual(appState.currentScreen, .setup)
    }
    
    /// Test navigation from welcome to setup via reset
    func testResetGame() {
        let appState = AppState()
        appState.startGame()
        appState.setPlayerCount(5)
        appState.updatePlayerName(0, to: "Alice")
        
        appState.resetGame()
        
        XCTAssertEqual(appState.currentScreen, .welcome)
        XCTAssertEqual(appState.playerCount, 3)
        XCTAssertEqual(appState.playerNames, ["Player 1", "Player 2", "Player 3"])
        XCTAssertEqual(appState.selectedTheme, .country)
    }
    
    /// Test screen state after multiple navigations
    func testScreenNavigationSequence() {
        let appState = AppState()
        
        XCTAssertEqual(appState.currentScreen, .welcome)
        
        appState.goToSetup()
        XCTAssertEqual(appState.currentScreen, .setup)
        
        appState.startGame()
        XCTAssertEqual(appState.currentScreen, .game)
        
        appState.goToSetup()
        XCTAssertEqual(appState.currentScreen, .setup)
        
        appState.resetGame()
        XCTAssertEqual(appState.currentScreen, .welcome)
    }
    
    // MARK: - Theme Selection Tests
    
    /// Test theme enum cases
    func testThemeEnumCases() {
        let themes: [Theme] = [.place, .country, .things, .random]
        
        XCTAssertEqual(themes[0], .place)
        XCTAssertEqual(themes[1], .country)
        XCTAssertEqual(themes[2], .things)
        XCTAssertEqual(themes[3], .random)
    }
    
    /// Test theme raw values
    func testThemeRawValues() {
        XCTAssertEqual(Theme.place.rawValue, "Place")
        XCTAssertEqual(Theme.country.rawValue, "Country")
        XCTAssertEqual(Theme.things.rawValue, "Things")
        XCTAssertEqual(Theme.random.rawValue, "Random")
    }
    
    /// Test theme selection
    func testThemeSelection() {
        let appState = AppState()
        
        appState.selectedTheme = .place
        XCTAssertEqual(appState.selectedTheme, .place)
        
        appState.selectedTheme = .country
        XCTAssertEqual(appState.selectedTheme, .country)
        
        appState.selectedTheme = .things
        XCTAssertEqual(appState.selectedTheme, .things)
        
        appState.selectedTheme = .random
        XCTAssertEqual(appState.selectedTheme, .random)
    }
    
    /// Test all themes are CaseIterable
    func testThemeCaseIterable() {
        let allThemes = Theme.allCases
        
        XCTAssertEqual(allThemes.count, 4)
        XCTAssertTrue(allThemes.contains(.place))
        XCTAssertTrue(allThemes.contains(.country))
        XCTAssertTrue(allThemes.contains(.things))
        XCTAssertTrue(allThemes.contains(.random))
    }
    
    /// Test theme persistence through gameplay
    func testThemePersistenceAfterGameStart() {
        let appState = AppState()
        appState.selectedTheme = .place
        
        appState.startGame()
        
        XCTAssertEqual(appState.selectedTheme, .place)
    }
    
    // MARK: - Integration Tests
    
    /// Test complete setup flow
    func testCompleteSetupFlow() {
        let appState = AppState()
        
        // Start in welcome
        XCTAssertEqual(appState.currentScreen, .welcome)
        
        // Go to setup
        appState.goToSetup()
        
        // Configure players
        appState.setPlayerCount(4)
        appState.updatePlayerName(0, to: "Alice")
        appState.updatePlayerName(1, to: "Bob")
        appState.updatePlayerName(2, to: "Charlie")
        appState.updatePlayerName(3, to: "David")
        
        // Select theme
        appState.selectedTheme = .place
        
        // Start game
        appState.startGame()
        
        // Verify final state
        XCTAssertEqual(appState.currentScreen, .game)
        XCTAssertEqual(appState.playerCount, 4)
        XCTAssertEqual(appState.playerNames, ["Alice", "Bob", "Charlie", "David"])
        XCTAssertEqual(appState.selectedTheme, .place)
    }
    
    /// Test game reset maintains default initialization
    func testResetGameRestoresDefaults() {
        let appState = AppState()
        
        // Change everything
        appState.setPlayerCount(6)
        appState.updatePlayerName(0, to: "Custom1")
        appState.updatePlayerName(1, to: "Custom2")
        appState.updatePlayerName(2, to: "Custom3")
        appState.updatePlayerName(3, to: "Custom4")
        appState.updatePlayerName(4, to: "Custom5")
        appState.updatePlayerName(5, to: "Custom6")
        appState.selectedTheme = .things
        appState.startGame()
        
        // Reset
        appState.resetGame()
        
        // Verify restoration
        XCTAssertEqual(appState.currentScreen, .welcome)
        XCTAssertEqual(appState.playerCount, 3)
        XCTAssertEqual(appState.selectedTheme, .country)
        XCTAssertEqual(appState.playerNames, ["Player 1", "Player 2", "Player 3"])
    }
    
    /// Test player count change updates names accordingly
    func testPlayerCountChangeUpdatesNames() {
        let appState = AppState()
        
        appState.updatePlayerName(0, to: "Alice")
        appState.updatePlayerName(1, to: "Bob")
        appState.updatePlayerName(2, to: "Charlie")
        
        // Increase count - new names should be added
        appState.setPlayerCount(4)
        XCTAssertEqual(appState.playerNames, ["Player 1", "Player 2", "Player 3", "Player 4"])
        
        // Decrease count - names beyond count should not be accessible
        appState.setPlayerCount(2)
        XCTAssertEqual(appState.playerNames, ["Player 1", "Player 2"])
    }
    
    // MARK: - State Consistency Tests
    
    /// Test player count and names are always synchronized
    func testPlayerCountAndNamesSynchronization() {
        let appState = AppState()
        
        for count in 2...8 {
            appState.setPlayerCount(count)
            XCTAssertEqual(appState.playerNames.count, appState.playerCount)
        }
    }
    
    /// Test player names array always matches count
    func testPlayerNamesArrayConsistency() {
        let appState = AppState()
        
        let randomCount = Int.random(in: 2...8)
        appState.setPlayerCount(randomCount)
        
        XCTAssertEqual(appState.playerNames.count, randomCount)
        
        for i in 0..<appState.playerNames.count {
            XCTAssertFalse(appState.playerNames[i].isEmpty)
        }
    }
}
