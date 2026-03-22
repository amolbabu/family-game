import SwiftUI

// MARK: - SetupScreenView
struct SetupScreenView: View {
    //MARK: - Environment & State
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
    var body: some View {
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
                
                // Section 3: Theme Selection
                Section(header: Label("Choose a theme", systemImage: "sparkles")) {
                    Picker("Theme", selection: Binding(
                        get: { appState.selectedTheme },
                        set: { appState.selectedTheme = $0 }
                    )) {
                        ForEach(Theme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(.blue)
                    .accessibilityLabel("Theme selector")
                    .accessibilityValue(appState.selectedTheme.rawValue)
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
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                playerCountInput = "\(appState.playerCount)"
            }
        }
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    SetupScreenView()
        .environment(appState)
}
