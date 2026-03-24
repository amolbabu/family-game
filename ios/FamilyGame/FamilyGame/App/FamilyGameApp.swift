import SwiftUI
#if os(iOS)
import UIKit

// Protocol trick: lets us call safeAreaRegions on UIHostingController<Content>
// without needing to know the generic Content type at compile time.
@available(iOS 16.0, *)
private protocol HostingControllerFix: AnyObject {
    func disableSafeAreaPropagation()
}

@available(iOS 16.0, *)
extension UIHostingController: HostingControllerFix {
    func disableSafeAreaPropagation() {
        safeAreaRegions = []
    }
}
#endif

@available(iOS 17.0, macOS 14.0, *)
@main
struct FamilyGameApp: App {
    @State private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                #if os(iOS)
                Color.white.ignoresSafeArea()
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
            .preferredColorScheme(.light)
            .environment(appState)
            #if os(iOS)
            .onAppear {
                for scene in UIApplication.shared.connectedScenes {
                    guard let ws = scene as? UIWindowScene else { continue }
                    for window in ws.windows {
                        window.backgroundColor = .white
                        if #available(iOS 16.0, *),
                           let hostingVC = window.rootViewController as? any HostingControllerFix {
                            hostingVC.disableSafeAreaPropagation()
                        }
                    }
                }
            }
            #endif
        }
    }
}
