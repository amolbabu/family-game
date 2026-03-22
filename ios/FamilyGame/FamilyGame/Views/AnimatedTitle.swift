import SwiftUI

@available(iOS 14.0, macOS 11.0, *)
struct AnimatedTitle: View {
    @State private var appear = false
    @available(iOS 14.0, macOS 11.0, *)
    var body: some View {
        Text("Family Game")
            .font(.custom("Baloo2-Bold", size: 48).weight(.bold))
            .kerning(1.5)
            .foregroundColor(.deepNavy)
            .shadow(color: .playfulBlue.opacity(0.18), radius: 8, x: 0, y: 4)
            .opacity(appear ? 1 : 0)
            .scaleEffect(appear ? 1 : 0.85)
            .offset(y: appear ? 0 : -30)
            .animation(.interpolatingSpring(stiffness: 180, damping: 14).delay(0.1), value: appear)
            .onAppear { appear = true }
            .accessibilityLabel("Family Game")
    }
}
