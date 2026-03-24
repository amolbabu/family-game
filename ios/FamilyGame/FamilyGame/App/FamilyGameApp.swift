import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
@main
struct FamilyGameApp: App {
    @State private var appState = AppState()
    
    @available(iOS 17.0, macOS 14.0, *)
    var body: some Scene {
        WindowGroup {
            ZStack {
                #if os(iOS)
                Color(UIColor.systemBackground).ignoresSafeArea()
                #else
                Color(.controlBackgroundColor).ignoresSafeArea()
                #endif
                
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
            .ignoresSafeArea()
            .environment(appState)
        }
    }
}
