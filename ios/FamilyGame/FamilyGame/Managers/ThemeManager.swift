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
        // Try Bundle.main first (for iOS app target)
        if let url = Bundle.main.url(forResource: "themes", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let container = try JSONDecoder().decode(ThemesContainer.self, from: data)
                self.themes = container.themes
                return
            } catch {
                loadError = ThemeLoadError.decodingError(error)
                return
            }
        }
        
        // Fallback: hardcoded themes (embedded as constant)
        // This ensures the app works even if the JSON file is not bundled
        self.themes = ThemeManager.defaultThemes()
    }
    
    private static func defaultThemes() -> [ThemeData] {
        return [
            ThemeData(name: "Country", words: [
                "France", "Italy", "Japan", "Brazil", "Australia", "Canada", "Spain",
                "Thailand", "Germany", "Mexico", "Egypt", "India", "Russia", "Norway",
                "Greece", "Sweden", "Switzerland", "Netherlands", "Portugal", "Poland",
                "South Korea", "China", "Vietnam", "Indonesia", "Philippines", "Morocco",
                "Kenya", "Ireland", "Scotland", "New Zealand", "Argentina", "Chile"
            ]),
            ThemeData(name: "Place", words: [
                "Airport", "Hotel", "Hospital", "Coffee Shop", "Shopping Mall", "Toilet",
                "Restaurant", "Library", "Cinema", "Park", "School", "Bank", "Supermarket",
                "Train Station", "Bus Stop", "Swimming Pool", "Gym", "Museum", "Church",
                "Beach", "Garden", "Market", "Office", "Kitchen", "Bedroom", "Bathroom"
            ]),
            ThemeData(name: "Things", words: [
                "Bicycle", "Book", "Camera", "Clock", "Elephant", "Guitar", "Hat", "Lighthouse"
            ]),
            ThemeData(name: "Jobs", words: [
                "Doctor", "Teacher", "Pilot", "Chef", "Police Officer", "Firefighter",
                "Engineer", "Nurse", "Lawyer", "Architect", "Dentist", "Farmer",
                "Artist", "Scientist", "Journalist", "Accountant", "Librarian", "Mechanic",
                "Plumber", "Carpenter", "Electrician", "Pharmacist", "Programmer",
                "Photographer", "Surgeon", "Soldier", "Judge", "Actor", "Musician", "Coach"
            ])
        ]
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
