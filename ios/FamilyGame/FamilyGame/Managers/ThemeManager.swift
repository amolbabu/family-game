import Foundation

struct ThemeData: Codable {
    let name: String
    let words: [String]
}

struct ThemesContainer: Codable {
    let themes: [ThemeData]
}

struct ThemeInfo {
    let name: String
    let words: [String]
}

class ThemeManager {
    static let shared = ThemeManager()
    
    private var themes: [ThemeData] = []
    private var loadError: Error?
    
    private init() {
        loadThemes()
    }
    
    private func loadThemes() {
        guard let url = Bundle.main.url(forResource: "themes", withExtension: "json") else {
            loadError = ThemeLoadError.fileNotFound
            print("[ThemeManager] ERROR: themes.json file not found in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let container = try JSONDecoder().decode(ThemesContainer.self, from: data)
            
            print("[ThemeManager] DEBUG: Loaded \(container.themes.count) themes from bundle")
            for theme in container.themes {
                print("[ThemeManager] DEBUG: Theme '\(theme.name)' has \(theme.words.count) words")
                print("[ThemeManager] DEBUG:   - First word: \(theme.words.first ?? "N/A")")
            }
            
            // Validate themes
            for theme in container.themes {
                if theme.words.isEmpty {
                    loadError = ThemeLoadError.emptyTheme(theme.name)
                    print("[ThemeManager] ERROR: Theme '\(theme.name)' is empty")
                    return
                }
            }
            
            self.themes = container.themes
            print("[ThemeManager] SUCCESS: All themes loaded successfully")
        } catch {
            loadError = ThemeLoadError.decodingError(error)
            print("[ThemeManager] ERROR: Failed to decode themes.json: \(error)")
        }
    }
    
    func getThemes() -> [ThemeInfo] {
        return themes.map { ThemeInfo(name: $0.name, words: $0.words) }
    }
    
    func getWords(forTheme themeName: String) -> [String]? {
        let result = themes.first(where: { $0.name == themeName })?.words
        if result == nil {
            print("[ThemeManager] WARNING: Theme '\(themeName)' not found. Available themes: \(themes.map { $0.name }). Returning empty array.")
        }
        return result
    }
    
    func getThemeNames() -> [String] {
        return themes.map { $0.name }
    }
    
    func didLoadSuccessfully() -> Bool {
        return loadError == nil
    }
    
    func getLoadError() -> Error? {
        return loadError
    }
}

enum ThemeLoadError: Error, LocalizedError {
    case fileNotFound
    case emptyTheme(String)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "themes.json file not found in bundle"
        case .emptyTheme(let themeName):
            return "Theme '\(themeName)' has no words"
        case .decodingError(let error):
            return "Failed to decode themes.json: \(error.localizedDescription)"
        }
    }
}
