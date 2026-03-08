import SwiftUI

extension Color {
    static let appPrimary = Color.blue
    static let appAccent = Color.green
    static let appBackground = Color(.systemBackground)
}

extension LinearGradient {
    static let appGradientBorder = LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing)
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(LinearGradient.appGradientBorder, lineWidth: configuration.isPressed ? 2 : 0)
                    .opacity(configuration.isPressed ? 1 : 0)
            )
    }
}
