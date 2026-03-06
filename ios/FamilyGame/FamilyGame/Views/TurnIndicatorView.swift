import SwiftUI

struct TurnIndicatorView: View {
    let currentPlayer: Player
    let playerIndex: Int
    let totalPlayers: Int
    let cardsRemaining: Int
    let lockedCardCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Current turn indicator
            HStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(currentPlayer.name)'s Turn")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Player \(playerIndex + 1) of \(totalPlayers)")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(currentPlayer.name)'s turn")
            .accessibilityValue("Player \(playerIndex + 1) of \(totalPlayers)")
            
            // Cards remaining indicator
            HStack(spacing: 16) {
                VStack(alignment: .center, spacing: 4) {
                    Image(systemName: "square.stack.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.green)
                    
                    Text("\(cardsRemaining)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Remaining")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                
                VStack(alignment: .center, spacing: 4) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                    
                    Text("\(lockedCardCount)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Locked")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Game status")
            .accessibilityValue("\(cardsRemaining) cards remaining, \(lockedCardCount) cards locked")
        }
        .padding(12)
    }
}

#Preview {
    TurnIndicatorView(
        currentPlayer: Player(name: "Alice", role: .normal),
        playerIndex: 0,
        totalPlayers: 3,
        cardsRemaining: 3,
        lockedCardCount: 0
    )
    .padding()
    .background(Color(.systemBackground))
}
