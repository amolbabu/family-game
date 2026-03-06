import SwiftUI

struct WelcomeScreenView: View {
    @Environment(AppState.self) var appState
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Banner text
            Text("Family Game")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .accessibilityLabel("Family Game")
            
            // Family-friendly image placeholder
            Image(systemName: "person.3.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .accessibilityLabel("Three people representing family players")
            
            Text("A game for everyone")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Start Game button
            Button(action: {
                appState.goToSetup()
            }) {
                Text("Start Game")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .accessibilityLabel("Start Game")
            .accessibilityHint("Tap to proceed to the player setup screen")
            
            Spacer()
                .frame(height: 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    WelcomeScreenView()
        .environment(appState)
}
