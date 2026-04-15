import SwiftUI

// MARK: - SetupScreenView
@available(iOS 17.0, macOS 14.0, *)
struct SetupScreenView: View {
    //MARK: - Environment & State
    @available(iOS 17.0, macOS 14.0, *)
    @Environment(AppState.self) var appState
    @State private var playerCountInput: String = ""
    @State private var errorMessage: String? = nil
    
    //MARK: - Validation
    var isValidCount: Bool {
        if let v = Int(playerCountInput), (1...12).contains(v) {
            return true
        }
        return false
    }
    
    var canStartGame: Bool {
        if let v = Int(playerCountInput), v >= 3 && v <= 12 {
            return true
        }
        return false
    }
    
    //MARK: - Body
    @available(iOS 17.0, macOS 14.0, *)
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 24)

                        // Section 1: Number of players
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Number of Players", systemImage: "person.2.fill")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)

                            TextField("Enter number (1–12)", text: $playerCountInput)
                                .keyboardType(.numberPad)
                                .font(.system(size: 17, design: .rounded))
                                .padding(12)
                                .background(Color(UIColor.secondarySystemFill))
                                .cornerRadius(10)
                                .onChange(of: playerCountInput) { oldValue, newValue in
                                    let filtered = newValue.filter { $0.isNumber }
                                    if filtered != newValue { playerCountInput = filtered }
                                    if let v = Int(filtered) {
                                        if v < 1 { errorMessage = "Minimum 1 player" }
                                        else if v > 12 { errorMessage = "Maximum 12 players" }
                                        else { errorMessage = nil }
                                        if (1...12).contains(v) {
                                            appState.setPlayerCount(v)
                                        }
                                    } else {
                                        errorMessage = "Enter a number between 1 and 12"
                                    }
                                }

                            if let error = errorMessage {
                                Text(error)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.red)
                            }
                            
                            // Minimum player hint
                            if let v = Int(playerCountInput), v < 3 {
                                Text("Minimum 3 players required")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 24)

                        Spacer().frame(height: 32)

                        // Section 2: Theme selection
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Choose a Theme", systemImage: "sparkles")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)

                            // Standard category buttons (Place, Country, Things)
                            HStack(spacing: 12) {
                                ForEach([Theme.place, Theme.country, Theme.things, Theme.jobs], id: \.self) { theme in
                                    Button(action: { appState.selectedTheme = theme }) {
                                        Text(theme.rawValue)
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(appState.selectedTheme == theme ? .white : .primary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(appState.selectedTheme == theme ? Color.playfulBlue : Color(UIColor.secondarySystemFill))
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(appState.selectedTheme == theme ? Color.white : Color.secondary.opacity(0.4), lineWidth: appState.selectedTheme == theme ? 2 : 1)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("\(theme.rawValue) theme")
                                    .accessibilityHint(appState.selectedTheme == theme ? "Currently selected" : "Select this theme")
                                }
                            }

                            // Random button with accent styling
                            Spacer().frame(height: 8)
                            Button(action: { appState.selectedTheme = .random }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "shuffle")
                                    Text(Theme.random.rawValue)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.energeticPink,
                                            Color.softPurple
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(appState.selectedTheme == .random ? Color.white : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Random theme")
                            .accessibilityHint("Select a random theme for variety")
                        }
                        .padding(.horizontal, 24)

                        Spacer().frame(height: 32)
                    }
                }

                // Start button pinned at the bottom
                Divider()
                Button(action: {
                    if canStartGame {
                        let val = Int(playerCountInput) ?? appState.playerCount
                        print("[Setup] Start Game with \(val) players and theme: \(appState.selectedTheme.rawValue)")
                        appState.setPlayerCount(val)
                        appState.startGame()
                    } else {
                        if let v = Int(playerCountInput), v < 3 {
                            errorMessage = "Minimum 3 players required"
                        } else {
                            errorMessage = "Please enter a valid number between 1 and 12"
                        }
                    }
                }) {
                    Text("Start Game")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(canStartGame ? Color.blue : Color.blue.opacity(0.4))
                        .cornerRadius(14)
                }
                .disabled(!canStartGame)
                .opacity(canStartGame ? 1.0 : 0.5)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 32)
                .accessibilityLabel("Start Game")
                .accessibilityHint(canStartGame ? "Tap to begin the game" : "Enter at least 3 players to start")
            }
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
            .navigationTitle("Game Setup")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .onAppear {
                playerCountInput = "\(appState.playerCount)"
            }
        }
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview {
    @Previewable @State var appState = AppState()
    SetupScreenView()
        .environment(appState)
}
