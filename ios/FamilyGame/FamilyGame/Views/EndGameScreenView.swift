import SwiftUI

// MARK: - EndGameScreenView
struct EndGameScreenView: View {
    //MARK: - Environment
    @Environment(AppState.self) var appState
    let totalPlayers: Int
    let themeName: String
    
    //MARK: - Body
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Celebration icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
                .accessibilityLabel("Game complete")
                .scaleEffect(1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: totalPlayers)
            
            // Title
            Text("All Cards Revealed!")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .animation(.easeInOut(duration: 0.35), value: themeName)
            
            // Description
            VStack(spacing: 8) {
                Text("The card reveal phase is complete.")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    
                Text("Now it's time for discussion — who's the spy?")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            
            // Game summary
            VStack(spacing: 12) {
                HStack {
                    Label("Players", systemImage: "person.2.fill")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                    
                    Spacer()
                    
                    Text("\(totalPlayers)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Label("Theme", systemImage: "sparkles")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                    
                    Spacer()
                    
                    Text(themeName)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 12) {
                Button(action: {
                    print("[Game] Play Again tapped - resetting game")
                    appState.resetGame()
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Play Again")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.green)
                    .cornerRadius(12)
                }
                .accessibilityLabel("Play Again")
                .accessibilityHint("Tap to return to the welcome screen and start a new game")
                
                Button(action: {
                    print("[Game] Change Settings tapped - going to setup")
                    appState.goToSetup()
                }) {
                    HStack {
                        Image(systemName: "gearshape.fill")
                        Text("Change Settings")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .accessibilityLabel("Change Settings")
                .accessibilityHint("Tap to go back to the setup screen and change player names or theme")
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .bottom)
        .transition(.scale.combined(with: .opacity))
        .animation(.easeInOut(duration: 0.35), value: totalPlayers)
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    EndGameScreenView(totalPlayers: 3, themeName: "Country")
        .environment(appState)
}
