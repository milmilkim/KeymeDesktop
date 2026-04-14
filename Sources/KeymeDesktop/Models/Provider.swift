import Foundation

struct Provider: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var baseURL: String
    var dashboardURL: String?
    var icon: String?
    let createdAt: Date

    init(id: UUID = UUID(), name: String, baseURL: String, dashboardURL: String? = nil, icon: String? = nil, createdAt: Date = Date()) {
        self.id = id; self.name = name; self.baseURL = baseURL
        self.dashboardURL = dashboardURL; self.icon = icon; self.createdAt = createdAt
    }
}
