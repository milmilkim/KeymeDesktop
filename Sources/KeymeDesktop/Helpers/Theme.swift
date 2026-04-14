import SwiftUI

enum Theme {
    static let fontMono = Font.system(.body, design: .monospaced)
    static let fontMonoSmall = Font.system(.caption, design: .monospaced)
    static let fontMonoLarge = Font.system(.title3, design: .monospaced)

    // macOS 네이티브 시스템 색상 사용
    static let bgPrimary = Color(nsColor: .windowBackgroundColor)
    static let bgSecondary = Color(nsColor: .controlBackgroundColor)
    static let bgHover = Color(nsColor: .selectedContentBackgroundColor).opacity(0.1)
    static let textPrimary = Color(nsColor: .labelColor)
    static let textSecondary = Color(nsColor: .secondaryLabelColor)
    static let textMuted = Color(nsColor: .tertiaryLabelColor)
    static let accent = Color.accentColor
    static let accentSubtle = Color.accentColor.opacity(0.12)
    static let border = Color(nsColor: .separatorColor)
    static let danger = Color.red
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
