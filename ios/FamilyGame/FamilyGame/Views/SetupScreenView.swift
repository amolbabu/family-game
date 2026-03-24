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
    
    //MARK: - Body
    @available(iOS 17.0, macOS 14.0, *)
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            NavigationStack {
                Form {
                // Section 1: Number-only player count entry
                Section(header: Label("Number of Players", systemImage: "person.2.fill")) {
                    TextField("Enter number (1-12)", text: $playerCountInput)
                        .onChange(of: playerCountInput) { newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered != newValue { playerCountInput = filtered }
                            if let v = Int(filtered) {
                                if v < 1 { errorMessage = "Minimum 1 player" }
                                else if v > 12 { errorMessage = "Maximum 12 players" }
                                else { errorMessage = nil }
                                // update shared state immediately when valid
                                if (1...12).contains(v) {
                                    appState.setPlayerCount(v)
                                }
                            } else {
                                errorMessage = "Enter a number between 1 and 12"
                            }
                        }
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
                
                // Section 3: Theme Selection with Category Buttons
                Section(header: Label("Choose a theme", systemImage: "sparkles")) {
                    VStack(spacing: 12) {
                        // Standard category buttons (Place, Country, Things)
                        HStack(spacing: 12) {
                            ForEach([Theme.place, Theme.country, Theme.things], id: \.self) { theme in
                                Button(action: { appState.selectedTheme = theme }) {
                                    Text(theme.rawValue)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(appState.selectedTheme == theme ? Color.playfulBlue : Color.gray.opacity(0.3))
                                        .cornerRadius(10)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("\(theme.rawValue) theme")
                                .accessibilityHint(appState.selectedTheme == theme ? "Currently selected" : "Select this theme")
                            }
                        }
                        
                        // Random button with accent styling
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
                }
                
                // Section 4: Action Button
                Section {
                    Button(action: {
                        if isValidCount {
                            let val = Int(playerCountInput) ?? appState.playerCount
                            print("[Setup] Start Game with \(val) players and theme: \(appState.selectedTheme.rawValue)")
                            appState.setPlayerCount(val)
                            appState.startGame()
                        } else {
                            errorMessage = "Please enter a valid number between 1 and 12"
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Start")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .contentShape(Rectangle())
                    }
                    .disabled(!isValidCount)
                    .accessibilityLabel("Start Game")
                    .accessibilityHint(isValidCount ? "Tap to begin the game" : "Enter a valid player count")
                }
            }
            .navigationTitle("Game Setup")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .onAppear {
                playerCountInput = "\(appState.playerCount)"
            }
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
