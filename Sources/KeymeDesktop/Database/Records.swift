import Foundation
import GRDB

struct ProviderRecord: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "providers"
    var id: String
    var name: String
    var baseURL: String
    var dashboardURL: String?
    var icon: String?
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, icon
        case baseURL = "base_url"
        case dashboardURL = "dashboard_url"
        case createdAt = "created_at"
    }

    init(_ p: Provider) {
        id = p.id.uuidString; name = p.name; baseURL = p.baseURL
        dashboardURL = p.dashboardURL; icon = p.icon; createdAt = p.createdAt
    }

    var toModel: Provider {
        Provider(id: UUID(uuidString: id)!, name: name, baseURL: baseURL, dashboardURL: dashboardURL, icon: icon, createdAt: createdAt)
    }
}

struct KeyEntryRecord: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "key_entries"
    var id: String
    var providerID: String
    var alias: String
    var apiKey: String
    var tags: String
    var models: String?
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, alias, tags, models
        case providerID = "provider_id"
        case apiKey = "api_key"
        case createdAt = "created_at"
    }

    init(_ e: KeyEntry) {
        id = e.id.uuidString; providerID = e.providerID.uuidString
        alias = e.alias; apiKey = e.apiKey; createdAt = e.createdAt
        tags = (try? String(data: JSONEncoder().encode(e.tags), encoding: .utf8)) ?? "[]"
        models = e.models.flatMap { try? String(data: JSONEncoder().encode($0), encoding: .utf8) }
    }

    var toModel: KeyEntry {
        let decodedTags = (try? JSONDecoder().decode([String].self, from: Data(tags.utf8))) ?? []
        let decodedModels = models.flatMap { try? JSONDecoder().decode([String].self, from: Data($0.utf8)) }
        return KeyEntry(id: UUID(uuidString: id)!, providerID: UUID(uuidString: providerID)!, alias: alias, apiKey: apiKey, tags: decodedTags, models: decodedModels, createdAt: createdAt)
    }
}
