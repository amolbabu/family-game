import SwiftUI

@main
struct FamilyGameApp: App {
    @State private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                switch appState.currentScreen {
                case .welcome:
                    WelcomeScreenView()
                case .setup:
                    SetupScreenView()
                case .game:
                    GameScreenView()
                case .endGame:
                    EndGameScreenView(
                        totalPlayers: appState.playerCount,
                        themeName: appState.selectedTheme.rawValue
                    )
                }
            }
            .environment(appState)
        }
    }
}
