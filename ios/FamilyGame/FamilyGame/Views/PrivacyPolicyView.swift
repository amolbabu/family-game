import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.deepNavy.opacity(0.08),
                    Color.softPurple.opacity(0.15),
                    Color.playfulBlue.opacity(0.10)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Text("🔒")
                                .font(.system(size: 38))
                            Text("Privacy Policy")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(.deepNavy)
                        }
                        .multilineTextAlignment(.center)
                    }
                    .padding(.top, 32)
                    .padding(.bottom, 8)

                    // Policy content
                    VStack(spacing: 20) {
                        PolicyCard(
                            text: "We do not collect, store, or share any personal information from users of the App."
                        )

                        PolicyCard(
                            text: "The App is designed to be played offline with friends and does not require users to create an account or provide any personal data."
                        )
                    }

                    // Close Button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Close")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.deepNavy,
                                                Color.softPurple
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: .deepNavy.opacity(0.35), radius: 8, x: 0, y: 4)
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                    .accessibilityLabel("Close")
                    .accessibilityHint("Dismiss privacy policy and return to welcome screen")
                }
            }
        }
    }
}

@available(iOS 17.0, macOS 14.0, *)
private struct PolicyCard: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundColor(.deepNavy.opacity(0.85))
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal, 24)
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview {
    PrivacyPolicyView()
}
