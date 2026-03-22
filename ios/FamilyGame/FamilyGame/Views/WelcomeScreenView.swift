import SwiftUI

@available(macOS 10.15, *)
struct WelcomeScreenView: View {
    @Environment(AppState.self) var appState
    
    var body: some View {
        ZStack {
            DecorativeBackground()
            VStack {
                Spacer(minLength: 40)
                // Title at top third
                AnimatedTitle()
                    .padding(.top, 32)
                // Subtitle below title
                AnimatedSubtitle()
                    .padding(.top, 20)
                // Family-friendly icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 120, height: 120)
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 60, weight: .semibold))
                        .foregroundColor(.deepNavy.opacity(0.85))
                }
                .accessibilityLabel("Three people representing family players")
                .padding(.top, 32)
                // CTA Button
                VibrantButton(title: "Start Game") {
                    appState.goToSetup()
                }
                .padding(.top, 32)
                .accessibilityHint("Tap to proceed to the player setup screen")
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 24)

        }
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    WelcomeScreenView()
        .environment(appState)
}
