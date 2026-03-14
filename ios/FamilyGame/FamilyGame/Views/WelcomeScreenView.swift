import SwiftUI

struct WelcomeScreenView: View {
    @Environment(AppState.self) var appState
    
    var body: some View {
        ZStack {
            // Colorful gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.7, blue: 0.5),  // Warm orange
                    Color(red: 1.0, green: 0.85, blue: 0.3)  // Golden yellow
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Decorative top elements
                HStack(spacing: 20) {
                    Circle()
                        .fill(Color(red: 0.3, green: 0.8, blue: 1.0))
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .fill(Color(red: 1.0, green: 0.4, blue: 0.6))
                        .frame(width: 40, height: 40)
                    
                    Circle()
                        .fill(Color(red: 0.4, green: 0.9, blue: 0.7))
                        .frame(width: 45, height: 45)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Banner text
                VStack(spacing: 12) {
                    Text("Family Game")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 3)
                        .accessibilityLabel("Family Game")
                    
                    Text("A game for everyone")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.95))
                }
                
                // Family-friendly image placeholder with colors
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 140, height: 140)
                    
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 70, weight: .semibold))
                        .foregroundColor(.white)
                }
                .accessibilityLabel("Three people representing family players")
                
                Spacer()
                
                // Start Game button with vibrant styling
                Button(action: {
                    appState.goToSetup()
                }) {
                    Text("Start Game")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        )
                }
                .padding(.horizontal, 28)
                .accessibilityLabel("Start Game")
                .accessibilityHint("Tap to proceed to the player setup screen")
                
                Spacer()
                    .frame(height: 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    WelcomeScreenView()
        .environment(appState)
}
