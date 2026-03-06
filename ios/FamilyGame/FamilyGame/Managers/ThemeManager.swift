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
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let container = try JSONDecoder().decode(ThemesContainer.self, from: data)
            
            // Validate themes
            for theme in container.themes {
                if theme.words.isEmpty {
                    loadError = ThemeLoadError.emptyTheme(theme.name)
                    return
                }
            }
            
            self.themes = container.themes
        } catch {
            loadError = ThemeLoadError.decodingError(error)
        }
    }
    
    func getThemes() -> [ThemeInfo] {
        return themes.map { ThemeInfo(name: $0.name, words: $0.words) }
    }
    
    func getWords(forTheme themeName: String) -> [String]? {
        return themes.first(where: { $0.name == themeName })?.words
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
