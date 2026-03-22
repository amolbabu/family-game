import SwiftUI
#if os(iOS)
import UIKit
#endif

@available(iOS 14.0, macOS 10.15, *)
extension Color {
    static let appPrimary = Color.blue
    static let appAccent = Color.green
    #if os(iOS)
    static let appBackground = Color(UIColor.systemBackground)
    #else
    static let appBackground = Color(.controlBackgroundColor)
    #endif
}

@available(iOS 14.0, macOS 10.15, *)
extension LinearGradient {
    static let appGradientBorder = LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing)
}

@available(iOS 14.0, macOS 10.15, *)
struct PressableButtonStyle: ButtonStyle {
    @available(iOS 14.0, macOS 10.15, *)
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
