import Foundation

enum KeyMasking {
    static func mask(_ key: String) -> String {
        guard key.count > 7 else {
            let prefix = String(key.prefix(max(0, key.count - 3)))
            return prefix.isEmpty ? "****" : "\(prefix)****"
        }
        return "\(key.prefix(4))****\(key.suffix(3))"
    }

    static func looksLikeAPIKey(_ text: String) -> Bool {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard t.count >= 20, !t.contains(" ") else { return false }
        let prefixes = ["sk-", "sk-ant-", "sk-or-", "AIza", "gsk_", "xai-"]
        if prefixes.contains(where: { t.hasPrefix($0) }) { return true }
        return t.range(of: "^[A-Za-z0-9_\\-]{20,}$", options: .regularExpression) != nil
    }

    /// API 키의 prefix로 프로바이더 이름을 추측
    static func guessProviderName(for key: String) -> String? {
        let t = key.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.hasPrefix("sk-ant-") { return "Anthropic" }
        if t.hasPrefix("sk-or-") { return "OpenRouter" }
        if t.hasPrefix("sk-") { return "OpenAI" }
        if t.hasPrefix("AIza") { return "Google AI" }
        if t.hasPrefix("gsk_") { return "Groq" }
        if t.hasPrefix("xai-") { return "xAI" }
        return nil
    }
}
