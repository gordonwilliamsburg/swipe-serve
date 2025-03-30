import SwiftUI

struct StyleSwipeTheme {
    // Colors
    static let primary = Color(hex: "1A1A1A")
    static let secondary = Color(hex: "FFFFFF")
    static let accent = Color(hex: "D4AF37")
    static let background = Color(hex: "F5F5F5")
    
    // Fonts
    static let headlineFont = Font.system(.title, design: .default).weight(.bold)
    static let bodyFont = Font.system(.body, design: .default)
    static let buttonFont = Font.system(.body, design: .default).weight(.medium)
    
    // Sizes
    static let standardPadding: CGFloat = 16
    static let cardSpacing: CGFloat = 20
}

// Helper extension for hex color creation
extension Color {
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
            (a, r, g, b) = (1, 1, 1, 0)
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