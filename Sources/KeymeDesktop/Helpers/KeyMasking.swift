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
}
