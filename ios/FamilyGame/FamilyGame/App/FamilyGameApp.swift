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
                    // Placeholder for GameScreenView (to be built by Tony Stark)
                    GameScreenPlaceholder()
                }
            }
            .environment(appState)
        }
    }
}

struct GameScreenPlaceholder: View {
    @Environment(AppState.self) var appState
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Game Screen")
                .font(.title)
            
            Text("Players: \(appState.playerNames.joined(separator: ", "))")
                .font(.body)
                .padding()
            
            Text("Theme: \(appState.selectedTheme.rawValue)")
                .font(.body)
            
            Button(action: { appState.resetGame() }) {
                Text("Back to Welcome")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(8)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
