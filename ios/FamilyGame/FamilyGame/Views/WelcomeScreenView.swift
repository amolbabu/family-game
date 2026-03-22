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
            
            VStack(spacing: 24) {
                Spacer(minLength: 20)
                
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
                .padding(.top, 8)
                
                Spacer(minLength: 16)
                
                // Banner text
                VStack(spacing: 12) {
                    Text("Family Game")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 3)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .accessibilityLabel("Family Game")
                    
                    Text("A game for everyone")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.95))
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                }
                
                // Family-friendly image placeholder with colors
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 60, weight: .semibold))
                        .foregroundColor(.white)
                }
                .accessibilityLabel("Three people representing family players")
                
                Spacer(minLength: 16)
                
                // Start Game button with vibrant styling
                Button(action: {
                    appState.goToSetup()
                }) {
                    Text("Start Game")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        )
                }
                .padding(.horizontal, 24)
                .accessibilityLabel("Start Game")
                .accessibilityHint("Tap to proceed to the player setup screen")
                
                Spacer(minLength: 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 4)
        }
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    WelcomeScreenView()
        .environment(appState)
}
