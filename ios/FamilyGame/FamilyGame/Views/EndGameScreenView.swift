import SwiftUI
#if os(iOS)
import UIKit
#endif

// MARK: - EndGameScreenView
@available(iOS 17.0, macOS 14.0, *)
struct EndGameScreenView: View {
    //MARK: - Environment
    @available(iOS 17.0, macOS 14.0, *)
    @Environment(AppState.self) var appState
    let totalPlayers: Int
    let themeName: String
    
    //MARK: - Body
    @available(iOS 17.0, macOS 14.0, *)
    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 16)
            
            // Celebration icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(.green)
                .accessibilityLabel("Game complete")
                .scaleEffect(1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: totalPlayers)
            
            // Title
            Text("All Cards Revealed!")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .animation(.easeInOut(duration: 0.35), value: themeName)
            
            // Description
            VStack(spacing: 6) {
                Text("The card reveal phase is complete.")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    
                Text("Now it's time for discussion — who's the spy?")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            
            // Game summary
            VStack(spacing: 10) {
                HStack {
                    Label("Players", systemImage: "person.2.fill")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                    
                    Spacer()
                    
                    Text("\(totalPlayers)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Label("Theme", systemImage: "sparkles")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                    
                    Spacer()
                    
                    Text(themeName)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                        .lineLimit(1)
                }
            }
            .padding(10)
            #if os(iOS)
            .background(Color(UIColor.systemGray6))
            #else
            .background(Color(.controlBackgroundColor))
            #endif
            .cornerRadius(8)
            .padding(.horizontal, 20)
            
            Spacer(minLength: 16)
            
            // Action buttons
            VStack(spacing: 10) {
                Button(action: {
                    print("[Game] Play Again tapped - resetting game")
                    appState.resetGame()
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Play Again")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .cornerRadius(12)
                }
                .accessibilityLabel("Play Again")
                .accessibilityHint("Tap to return to the welcome screen and start a new game")
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #if os(iOS)
        .background(Color(UIColor.systemBackground))
        #else
        .background(Color(.controlBackgroundColor))
        #endif
        .ignoresSafeArea(edges: .bottom)
        .transition(.scale.combined(with: .opacity))
        .animation(.easeInOut(duration: 0.35), value: totalPlayers)
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview {
    @Previewable @State var appState = AppState()
    EndGameScreenView(totalPlayers: 3, themeName: "Country")
        .environment(appState)
}
