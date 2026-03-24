import SwiftUI
#if os(iOS)
import UIKit
#endif

// MARK: - GameScreenView
@available(iOS 17.0, macOS 14.0, *)
struct GameScreenView: View {
    //MARK: - Environment & State
    @available(iOS 17.0, macOS 14.0, *)
    @Environment(AppState.self) var appState
    @State private var gameState: GameState = GameState()
    @State private var selectedCardIndex: Int? = nil
    @State private var showRevealedCard = false
    @State private var isInitialized = false
    @State private var cardCount: Int = 0  // Trigger for view updates
    
    //MARK: - Computed
    var currentPlayer: Player? {
        guard gameState.currentPlayerIndex < gameState.players.count else {
            return nil
        }
        return gameState.players[gameState.currentPlayerIndex]
    }
    
    var cardsRemaining: Int {
        gameState.cards.filter { !$0.isLocked }.count
    }
    
    var cardColumns: [GridItem] {
        let columnCount = calculateColumnCount()
        return Array(repeating: GridItem(.flexible(), spacing: 8), count: columnCount)
    }
    
    //MARK: - Helpers
    func calculateColumnCount() -> Int {
        let playerCount = gameState.players.count
        switch playerCount {
        case 2, 3:
            return 3
        case 4, 5:
            return 4
        case 6, 7:
            return 4
        case 8:
            return 4
        default:
            return 3
        }
    }
    
    //MARK: - Body
    @available(iOS 17.0, macOS 14.0, *)
    var body: some View {
        // CRITICAL: Ensure initialization happens SYNCHRONOUSLY before rendering
        if !isInitialized {
            initializeGameState()
        }
        
        let _ = print("[GAME-STATE] cards=\(gameState.cards.count), players=\(gameState.players.count), isInit=\(isInitialized)")
        
        return ZStack {
            if gameState.isGameComplete() {
                EndGameScreenView(
                    totalPlayers: gameState.players.count,
                    themeName: gameState.selectedTheme
                )
                .transition(.scale.combined(with: .opacity))
                .animation(.easeInOut(duration: 0.35), value: gameState.cards)
            } else {
                VStack(spacing: 0) {
                    // Turn indicator at the top
                    if let player = currentPlayer {
                        TurnIndicatorView(
                            currentPlayer: player,
                            playerIndex: gameState.currentPlayerIndex,
                            totalPlayers: gameState.players.count,
                            cardsRemaining: cardsRemaining,
                            lockedCardCount: gameState.revealedCards.count
                        )
                        #if os(iOS)
                        .background(Color(UIColor.systemBackground).ignoresSafeArea(edges: .top))
                        #else
                        .background(Color(.controlBackgroundColor).ignoresSafeArea(edges: .top))
                        #endif
                    }
                    
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(spacing: 12) {
                            // Instruction text
                            Text("Choose a card to reveal")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                                .padding(.top, 12)
                                .animation(.easeInOut(duration: 0.3), value: gameState.currentPlayerIndex)
                            
                            // Card grid - key for refresh
                            LazyVGrid(columns: cardColumns, spacing: 8) {
                                ForEach(gameState.cards, id: \.id) { card in
                                    if let index = gameState.cards.firstIndex(where: { $0.id == card.id }) {
                                        let _ = print("[GRID] Rendering CardView for index \(index), isRevealed: \(card.isRevealed)")
                                        CardView(
                                            card: card,
                                            cardIndex: index,
                                            isCurrentPlayerTurn: true
                                        ) { tappedIndex in
                                            handleCardTap(tappedIndex)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.bottom, 12)
                            .id(cardCount)  // Force re-render when cardCount changes
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                #if os(iOS)
                .background(Color(UIColor.systemBackground).ignoresSafeArea())
                #else
                .background(Color(.controlBackgroundColor).ignoresSafeArea())
                #endif
                .sheet(isPresented: $showRevealedCard, onDismiss: {
                    handleCardLock()
                }) {
                    if let index = selectedCardIndex, index < gameState.cards.count {
                        CardRevealSheet(
                            card: gameState.cards[index],
                            playerName: currentPlayer?.name ?? "Player",
                            onDismiss: {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showRevealedCard = false
                                }
                            }
                        )
                        .transition(.scale.combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: showRevealedCard)
                    }
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            if !isInitialized {
                initializeGameState()
            }
        }
    }
    
    //MARK: - Initialization
    private func initializeGameState() {
        gameState.gamePhase = .inGame
        
        // Resolve theme (convert Random to concrete theme) before storing
        let resolvedTheme = GameLogic.resolveTheme(appState.selectedTheme.rawValue)
        gameState.selectedTheme = resolvedTheme
        
        // Create players from player names
        gameState.players = appState.playerNames.map { name in
            Player(name: name, role: .normal)
        }
        
        // Generate cards with the resolved theme
        do {
            gameState.cards = try GameLogic.generateCards(
                playerCount: gameState.players.count,
                theme: gameState.selectedTheme
            )
            
            // CRITICAL: Update cardCount to trigger LazyVGrid re-render
            cardCount = gameState.cards.count
        } catch {
            print("[ERROR] Failed to generate cards: \(error)")
        }
        
        isInitialized = true
    }
    
    //MARK: - Actions
    private func handleCardTap(_ cardIndex: Int) {
        print("[TAP] Card tap received for index \(cardIndex)")
        
        guard cardIndex >= 0 && cardIndex < gameState.cards.count else {
            print("[TAP] ❌ Invalid card index: \(cardIndex)")
            return
        }
        guard !gameState.cards[cardIndex].isLocked else {
            print("[TAP] ❌ Card is locked at index \(cardIndex)")
            return
        }
        
        print("[TAP] ✅ Card is valid and unlocked")
        selectedCardIndex = cardIndex
        print("[TAP] selectedCardIndex set to \(cardIndex)")
        
        do {
            let content = try gameState.selectCard(at: cardIndex, byPlayer: gameState.currentPlayerIndex)
            print("[TAP] ✅ Card selected, content: \(content == .spy ? "SPY" : "WORD")")
            
            withAnimation(.easeInOut(duration: 0.3)) {
                showRevealedCard = true
                print("[TAP] ✅ showRevealedCard set to TRUE")
            }
        } catch {
            print("[TAP] ❌ Failed to select card: \(error)")
        }
    }
    
    private func handleCardLock() {
        guard let index = selectedCardIndex else {
            return
        }
        
        do {
            try gameState.lockCard(at: index)
            gameState.nextPlayer()
            selectedCardIndex = nil
        } catch {
            print("[ERROR] Failed to lock card: \(error)")
        }
    }
}
// MARK: - Card Reveal Sheet
@available(iOS 17.0, macOS 14.0, *)
struct CardRevealSheet: View {
    let card: Card
    let playerName: String
    let onDismiss: () -> Void
    
    @State private var isRevealed = true
    
    private var cardContentDesc: String {
        switch card.content {
        case .spy:
            return "SPY"
        case .word(let w):
            return "WORD(\(w))"
        }
    }
    
    var body: some View {
        let _ = print("[SHEET] CardRevealSheet rendering for player: \(playerName), card content: \(cardContentDesc)")
        return VStack(spacing: 0) {
            // Player name header
            HStack {
                Text("\(playerName), your card is:")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
                .accessibilityLabel("Close")
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Scrollable content area
            ScrollView {
                VStack(spacing: 24) {
                    // Large card display
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue)
                            .stroke(Color.blue.opacity(0.5), lineWidth: 3)
                        
                        VStack(spacing: 16) {
                            switch card.content {
                            case .word(let word):
                                VStack(spacing: 12) {
                                    Image(systemName: "document.text.fill")
                                        .font(.system(size: 48))
                                        .foregroundColor(.white)
                                        .animation(.easeInOut(duration: 0.3), value: word)
                                    
                                    Text(word)
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .animation(.easeInOut(duration: 0.3), value: word)
                                }
                            case .spy:
                                VStack(spacing: 12) {
                                    Image(systemName: "eye.fill")
                                        .font(.system(size: 48))
                                        .foregroundColor(.white)
                                        .animation(.easeInOut(duration: 0.3), value: UUID())
                                    
                                    Text("SPY!")
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(24)
                    }
                    .frame(height: 280)
                    .padding(.horizontal, 20)
                    
                    // Instructions
                    VStack(spacing: 8) {
                        Text("Remember what you saw!")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                            .animation(.easeInOut(duration: 0.2), value: isRevealed)
                        
                        Text("Tap 'Hide Card' when ready, then pass the phone to the next player.")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
            }
            
            // Pinned button at bottom with generous spacing
            Button(action: onDismiss) {
                Text("Hide Card & Next Player")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.green)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom)
            .accessibilityLabel("Hide Card and continue to next player")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #if os(iOS)
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        #else
        .background(Color(.controlBackgroundColor).ignoresSafeArea())
        #endif
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview {
    @Previewable @State var appState = AppState()
    
    // Create a preview game state with sample cards
    var previewGameState: GameState {
        var state = GameState()
        state.gamePhase = .inGame
        state.selectedTheme = "Country"
        state.players = [
            Player(name: "Alice", role: .normal),
            Player(name: "Bob", role: .spy),
            Player(name: "Carol", role: .normal)
        ]
        state.cards = [
            Card(content: .word("France"), isRevealed: false, isLocked: false),
            Card(content: .word("France"), isRevealed: false, isLocked: false),
            Card(content: .spy, isRevealed: false, isLocked: false),
            Card(content: .word("France"), isRevealed: false, isLocked: false),
            Card(content: .word("France"), isRevealed: false, isLocked: false),
            Card(content: .word("France"), isRevealed: false, isLocked: false),
            Card(content: .word("France"), isRevealed: false, isLocked: false),
            Card(content: .word("France"), isRevealed: false, isLocked: false),
            Card(content: .word("France"), isRevealed: false, isLocked: false),
        ]
        return state
    }
    
    GameScreenView()
        .environment(appState)
}
