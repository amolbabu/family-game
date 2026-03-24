import SwiftUI
#if os(iOS)
import UIKit
#endif

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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .environment(appState)
            #if os(iOS)
            .onAppear {
                // Force UIWindow background to match the app so no black
                // pixels are ever visible on iPhone 16's Dynamic Island area
                // or home indicator area.
                for scene in UIApplication.shared.connectedScenes {
                    if let ws = scene as? UIWindowScene {
                        for window in ws.windows {
                            window.backgroundColor = UIColor.systemBackground
                        }
                    }
                }
            }
            #endif
        }
    }
}
