import SwiftUI

struct StyleSwipeTheme {
    // Colors
    static let primary = Color(hex: "2B2B2B")  // Dark text color
    static let secondary = Color(hex: "FFFFFF") // White
    static let accent = Color.clear   // Transparent for buttons
    static let background = Color(hex: "F5F5F5") // Paper-like background
    
    // Button specific properties
    static let buttonBorder = Color(hex: "2B2B2B") // Dark border color
    static let buttonTextColor = Color(hex: "2B2B2B") // Dark text color
    static let buttonCornerRadius: CGFloat = 25
    static let buttonBorderWidth: CGFloat = 1
    
    // Fonts - using system serif fonts instead of Times New Roman
    static let headlineFont = Font.custom("TimesNewRomanPSMT", size: 40)
    static let subheadlineFont = Font.custom("TimesNewRomanPSMT", size: 16)
    static let bodyFont = Font.custom("TimesNewRomanPSMT", size: 20)
    static let buttonFont = Font.custom("TimesNewRomanPSMT", size: 16)
    
    // Sizes
    static let standardPadding: CGFloat = 24
    static let cardSpacing: CGFloat = 20
}

// Add this new ButtonStyle struct in the same file
struct OutlinedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(StyleSwipeTheme.buttonTextColor)
            .padding(.horizontal, 30)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .strokeBorder(StyleSwipeTheme.buttonBorder, lineWidth: StyleSwipeTheme.buttonBorderWidth)
                    .background(StyleSwipeTheme.accent)
                    .clipShape(Capsule())
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// Add this extension for easy button style application
extension View {
    func outlinedButtonStyle() -> some View {
        self.buttonStyle(OutlinedButtonStyle())
    }
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