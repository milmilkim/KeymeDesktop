import Foundation

struct KeyEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var providerID: UUID
    var alias: String
    var apiKey: String
    var tags: [String]
    var models: [String]?
    let createdAt: Date

    init(id: UUID = UUID(), providerID: UUID, alias: String, apiKey: String, tags: [String] = [], models: [String]? = nil, createdAt: Date = Date()) {
        self.id = id; self.providerID = providerID; self.alias = alias
        self.apiKey = apiKey; self.tags = tags; self.models = models; self.createdAt = createdAt
    }
}
