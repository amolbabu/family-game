import SwiftUI

@available(iOS 14.0, macOS 12.0, *)
struct VibrantButton: View {
    let title: String
    let action: () -> Void
    @State private var isPressed = false
    @FocusState private var isFocused: Bool
    @available(iOS 14.0, macOS 12.0, *)
    var body: some View {
        Button(action: action) {
            Text(title.uppercased())
                .font(.custom("Baloo2-Bold", size: 20).weight(.bold))
                .foregroundColor(.white)
                .padding(.vertical, 18)
                .padding(.horizontal, 40)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .energeticPink,
                            .livelyGreen
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .playfulBlue.opacity(isPressed ? 0.10 : 0.15), radius: isPressed ? 8 : 16, x: 0, y: 4)
                .scaleEffect(isPressed ? 0.97 : (isFocused ? 1.05 : 1.0))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isFocused ? Color.softPurple : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.01, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.12)) {
                isPressed = pressing
            }
        }, perform: {})
        .focused($isFocused)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
    }
}
