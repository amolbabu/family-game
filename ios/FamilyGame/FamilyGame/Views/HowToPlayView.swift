import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
struct HowToPlayView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Warm gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.sunnyYellow.opacity(0.3),
                    Color.warmOrange.opacity(0.2),
                    Color.energeticPink.opacity(0.15)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("How to Play 🕵️")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(.deepNavy)
                            .multilineTextAlignment(.center)
                        
                        Text("SPY Family Edition")
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundColor(.warmOrange)
                    }
                    .padding(.top, 32)
                    .padding(.bottom, 8)
                    
                    // Objective
                    InstructionCard(
                        icon: "🎯",
                        title: "Objective",
                        description: "Agents know the secret word — the SPY doesn't. Can you catch the SPY before they blend in?"
                    )
                    
                    // How to Play Steps
                    VStack(spacing: 16) {
                        Text("How to Play")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.deepNavy)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                        
                        InstructionStepCard(
                            number: "1",
                            emoji: "📱",
                            text: "Players take turns viewing the card — everyone else looks away"
                        )
                        
                        InstructionStepCard(
                            number: "2",
                            emoji: "🔤",
                            text: "Most players see a SECRET WORD (e.g., \"Castle\", \"Pizza\"). One player sees \"SPY\" instead"
                        )
                        
                        InstructionStepCard(
                            number: "3",
                            emoji: "💬",
                            text: "Everyone gives a clue that proves they know the word — without actually saying it!"
                        )
                        
                        InstructionStepCard(
                            number: "4",
                            emoji: "🕵️",
                            text: "The SPY listens carefully and tries to blend in without knowing the word"
                        )
                        
                        InstructionStepCard(
                            number: "5",
                            emoji: "🗳️",
                            text: "After discussion, everyone votes on who they think is the SPY"
                        )
                    }
                    
                    // Winning
                    InstructionCard(
                        icon: "🏆",
                        title: "Who Wins?",
                        description: "Catch the SPY → all agents win! SPY avoids detection → the SPY wins!"
                    )
                    
                    // Tips
                    VStack(spacing: 12) {
                        Text("Pro Tips")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.deepNavy)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                        
                        TipCard(
                            emoji: "🤫",
                            text: "Make your clue specific enough to prove you know the word — but vague enough that the SPY can't guess it!"
                        )
                        
                        TipCard(
                            emoji: "👀",
                            text: "Watch for hesitation! The SPY doesn't know the word, so their clue might be suspiciously generic"
                        )
                        
                        TipCard(
                            emoji: "👶",
                            text: "Younger players can give their clue first so they aren't influenced by others"
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
                                                Color.playfulBlue,
                                                Color.playfulBlue.opacity(0.85)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: .playfulBlue.opacity(0.4), radius: 8, x: 0, y: 4)
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                    .accessibilityLabel("Close")
                    .accessibilityHint("Dismiss instructions and return to welcome screen")
                }
            }
        }
    }
}

// MARK: - Supporting Views

@available(iOS 17.0, macOS 14.0, *)
struct InstructionCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 48))
            
            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.deepNavy)
            
            Text(description)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.deepNavy.opacity(0.8))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 24)
    }
}

@available(iOS 17.0, macOS 14.0, *)
struct InstructionStepCard: View {
    let number: String
    let emoji: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Step number badge
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.warmOrange,
                                Color.energeticPink
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Text(number)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Text(emoji)
                .font(.system(size: 28))
            
            Text(text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.deepNavy)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
        .padding(.horizontal, 24)
    }
}

@available(iOS 17.0, macOS 14.0, *)
struct TipCard: View {
    let emoji: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 24))
            
            Text(text)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.deepNavy.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.sunnyYellow.opacity(0.3), lineWidth: 2)
                )
        )
        .padding(.horizontal, 24)
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview {
    HowToPlayView()
}
