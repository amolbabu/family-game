import SwiftUI
#if os(iOS)
import UIKit
#endif

// MARK: - TurnIndicatorView
@available(iOS 14.0, macOS 13.0, *)
struct TurnIndicatorView: View {
    //MARK: - Properties
    let currentPlayer: Player
    let playerIndex: Int
    let totalPlayers: Int
    let cardsRemaining: Int
    let lockedCardCount: Int
    
    //MARK: - Body
    @available(iOS 14.0, macOS 13.0, *)
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Current turn indicator
            HStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.blue)
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 0.3), value: playerIndex) // animate when player changes
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(currentPlayer.name)'s Turn")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .animation(.easeInOut(duration: 0.3), value: currentPlayer.name)
                    
                    Text("Player \(playerIndex + 1) of \(totalPlayers)")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                        .animation(.easeInOut(duration: 0.3), value: playerIndex)
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
            
            // Ultra-compact inline stats
            HStack(spacing: 8) {
                Label("\(cardsRemaining)", systemImage: "square.stack.fill")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.green)
                
                Text("·")
                    .foregroundColor(.secondary)
                
                Label("\(lockedCardCount)", systemImage: "lock.fill")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.red)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(6)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Game status")
            .accessibilityValue("\(cardsRemaining) cards remaining, \(lockedCardCount) cards locked")
        }
        .padding(12)
    }
}

@available(iOS 14.0, macOS 13.0, *)
#Preview {
    TurnIndicatorView(
        currentPlayer: Player(name: "Alice", role: .normal),
        playerIndex: 0,
        totalPlayers: 3,
        cardsRemaining: 3,
        lockedCardCount: 0
    )
    .padding()
    #if os(iOS)
    .background(Color(UIColor.systemBackground))
    #else
    .background(Color(.controlBackgroundColor))
    #endif
}
