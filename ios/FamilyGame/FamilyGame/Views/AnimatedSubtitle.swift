import SwiftUI

@available(macOS 10.15, *)
struct AnimatedSubtitle: View {
    @State private var appear = false
    var body: some View {
        Text("A game for everyone")
            .font(.custom("Baloo2-Medium", size: 26).weight(.medium))
            .kerning(1)
            .foregroundColor(.deepNavy.opacity(0.85))
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 10)
            .animation(.easeOut(duration: 0.5).delay(0.2), value: appear)
            .onAppear { appear = true }
    }
}
