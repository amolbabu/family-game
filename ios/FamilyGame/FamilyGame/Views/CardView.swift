import SwiftUI

// MARK: - CardView
struct CardView: View {
    //MARK: - Properties
    let card: Card
    let cardIndex: Int
    let isCurrentPlayerTurn: Bool
    let onTap: (Int) -> Void
    
    @State private var isPressed = false
    
    //MARK: - Body
    var body: some View {
        // Rendering log for diagnostics
        print("[TRACE] \(Date()) CardView: Rendering card \(cardIndex) - isRevealed: \(card.isRevealed), isLocked: \(card.isLocked)")
        Button(action: {
            // Log tap intent, card content, and forward to parent
            let contentDesc: String
            switch card.content {
            case .spy:
                contentDesc = "SPY"
            case .word(let w):
                contentDesc = "WORD(\(w))"
            }
            print("[TRACE] \(Date()) CardView.tap: Tapped index \(cardIndex) - content: \(contentDesc), isRevealed: \(card.isRevealed), isLocked: \(card.isLocked), isCurrentPlayerTurn: \(isCurrentPlayerTurn)")
            if !card.isLocked && isCurrentPlayerTurn {
                onTap(cardIndex)
            }
        }) {
            ZStack {"}}]}``
                // Card background
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardBackgroundColor)
                    .stroke(cardBorderColor, lineWidth: 2)
                
                // Card content
                VStack(spacing: 8) {
                    if card.isRevealed {
                        cardContentView
                            .transition(.scale.combined(with: .opacity)) // smooth reveal transition
                    } else {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .transition(.scale.combined(with: .opacity))
                        
                        Text("Tap to reveal")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .opacity(0.8)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 100)
            .scaleEffect(isPressed && !card.isLocked ? 0.97 : 1.0)
            .opacity(isPressed && !card.isLocked ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed) // tap feedback
            .animation(.easeInOut(duration: 0.3), value: card.isRevealed) // animate reveal changes
        }
        .disabled(card.isLocked || !isCurrentPlayerTurn)
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            isPressed = pressing && !card.isLocked && isCurrentPlayerTurn
        }) {}
        .accessibilityLabel("Card \(cardIndex + 1)")
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(card.isLocked ? .isButton : [])
    }
    
    //MARK: - Content
    @ViewBuilder
    private var cardContentView: some View {
        switch card.content {
        case .word(let word):
            Text(word)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        case .spy:
            VStack(spacing: 4) {
                Text("SPY!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Image(systemName: "eye.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
        }
    }
    
    //MARK: - Helpers
    private var cardBackgroundColor: Color {
        if card.isLocked {
            return Color(.systemGray4)
        } else if card.isRevealed {
            return Color.blue
        } else {
            return Color(.systemBlue)
        }
    }
    
    private var cardBorderColor: Color {
        if card.isLocked {
            return Color(.systemGray3)
        } else {
            return Color.blue.opacity(0.5)
        }
    }
    
    private var accessibilityHint: String {
        if card.isLocked {
            return "This card has been revealed and locked"
        } else if card.isRevealed {
            return "Card is revealed. Tap to hide and lock it"
        } else {
            return "Tap to reveal the card content"
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        // Unrevealed card
        CardView(
            card: Card(content: .word("France"), isRevealed: false, isLocked: false),
            cardIndex: 0,
            isCurrentPlayerTurn: true,
            onTap: { _ in }
        )
        
        // Revealed card with word
        CardView(
            card: Card(content: .word("France"), isRevealed: true, isLocked: false),
            cardIndex: 1,
            isCurrentPlayerTurn: true,
            onTap: { _ in }
        )
        
        // Revealed card with SPY
        CardView(
            card: Card(content: .spy, isRevealed: true, isLocked: false),
            cardIndex: 2,
            isCurrentPlayerTurn: true,
            onTap: { _ in }
        )
        
        // Locked card
        CardView(
            card: Card(content: .word("France"), isRevealed: false, isLocked: true),
            cardIndex: 3,
            isCurrentPlayerTurn: true,
            onTap: { _ in }
        )
    }
    .padding()
}
