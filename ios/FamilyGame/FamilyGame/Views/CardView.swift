import SwiftUI

struct CardView: View {
    let card: Card
    let cardIndex: Int
    let isCurrentPlayerTurn: Bool
    let onTap: (Int) -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            if !card.isLocked && isCurrentPlayerTurn {
                onTap(cardIndex)
            }
        }) {
            ZStack {
                // Card background
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardBackgroundColor)
                    .stroke(cardBorderColor, lineWidth: 2)
                
                // Card content
                VStack(spacing: 8) {
                    if card.isRevealed {
                        cardContentView
                    } else {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                        
                        Text("Tap to reveal")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .opacity(0.8)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 100)
            .opacity(isPressed && !card.isLocked ? 0.7 : 1.0)
        }
        .disabled(card.isLocked || !isCurrentPlayerTurn)
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            isPressed = pressing && !card.isLocked && isCurrentPlayerTurn
        }) {}
        .accessibilityLabel("Card \(cardIndex + 1)")
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(card.isLocked ? .isButton : [])
    }
    
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
