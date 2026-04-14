import SwiftUI

enum Theme {
    static let fontMono = Font.system(.body, design: .monospaced)
    static let fontMonoSmall = Font.system(.caption, design: .monospaced)
    static let fontMonoLarge = Font.system(.title3, design: .monospaced)

    static let bgPrimary = Color(hex: "#1a1a2e")
    static let bgSecondary = Color(hex: "#16213e")
    static let bgHover = Color.white.opacity(0.03)
    static let textPrimary = Color(hex: "#e0e0e0")
    static let textSecondary = Color(hex: "#8a8a8a")
    static let textMuted = Color(hex: "#555555")
    static let accent = Color(hex: "#00d4aa")
    static let accentSubtle = Color(hex: "#00d4aa").opacity(0.12)
    static let border = Color.white.opacity(0.06)
    static let danger = Color(hex: "#ff6b6b")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        self.init(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }
}
