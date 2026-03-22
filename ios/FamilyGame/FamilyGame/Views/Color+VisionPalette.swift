import SwiftUI

@available(iOS 14.0, macOS 10.15, *)
extension Color {
    static let playfulBlue = Color(hex: "#3A8DFF")
    static let sunnyYellow = Color(hex: "#FFD93A")
    static let livelyGreen = Color(hex: "#4ADE80")
    static let energeticPink = Color(hex: "#FF6F91")
    static let softPurple = Color(hex: "#A78BFA")
    static let warmOrange = Color(hex: "#FFB86B")
    static let coolTeal = Color(hex: "#2DD4BF")
    static let deepNavy = Color(hex: "#1E293B")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
