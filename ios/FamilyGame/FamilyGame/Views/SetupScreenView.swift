import SwiftUI

struct SetupScreenView: View {
    @Environment(AppState.self) var appState
    
    var isFormValid: Bool {
        // Check if all player names are filled (not empty)
        appState.playerNames.allSatisfy { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Section 1: Player Count Selection
                Section(header: Label("How many players?", systemImage: "person.2.fill")) {
                    Picker("Number of Players", selection: $appState.playerCount) {
                        ForEach(2...8, id: \.self) { count in
                            Text("\(count) Players").tag(count)
                        }
                    }
                    .onChange(of: appState.playerCount) { oldValue, newValue in
                        appState.setPlayerCount(newValue)
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel("Player count selector")
                    .accessibilityValue("\(appState.playerCount) players")
                }
                
                // Section 2: Player Names
                Section(header: Label("Player Names", systemImage: "pencil.circle.fill")) {
                    ForEach(0..<appState.playerNames.count, id: \.self) { index in
                        HStack {
                            Text("Player \(index + 1)")
                                .foregroundColor(.secondary)
                                .frame(width: 70, alignment: .leading)
                            
                            TextField("Name", text: $appState.playerNames[index])
                                .textFieldStyle(.roundedBorder)
                                .accessibilityLabel("Player \(index + 1) name")
                        }
                    }
                }
                
                // Section 3: Theme Selection
                Section(header: Label("Choose a theme", systemImage: "sparkles")) {
                    Picker("Theme", selection: $appState.selectedTheme) {
                        ForEach(Theme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel("Theme selector")
                    .accessibilityValue(appState.selectedTheme.rawValue)
                }
                
                // Section 4: Action Button
                Section {
                    Button(action: {
                        if isFormValid {
                            appState.startGame()
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Start Game")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .listRowBackground(
                        isFormValid ? Color.green : Color.gray.opacity(0.3)
                    )
                    .disabled(!isFormValid)
                    .accessibilityLabel("Start Game")
                    .accessibilityHint(isFormValid ? "Tap to begin the game" : "Fill in all player names to continue")
                }
            }
            .navigationTitle("Game Setup")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    SetupScreenView()
        .environment(appState)
}
