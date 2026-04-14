import Foundation

struct ClipboardItem: Identifiable, Equatable {
    let id: UUID
    let content: String
    let isAPIKey: Bool
    let detectedProvider: String?
    let copiedAt: Date

    init(id: UUID = UUID(), content: String, isAPIKey: Bool = false, detectedProvider: String? = nil, copiedAt: Date = Date()) {
        self.id = id; self.content = content; self.isAPIKey = isAPIKey
        self.detectedProvider = detectedProvider; self.copiedAt = copiedAt
    }
}
