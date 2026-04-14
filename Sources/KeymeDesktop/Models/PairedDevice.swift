import Foundation

struct PairedDevice: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var publicKey: Data
    let pairedAt: Date

    init(id: UUID = UUID(), name: String, publicKey: Data, pairedAt: Date = Date()) {
        self.id = id; self.name = name; self.publicKey = publicKey; self.pairedAt = pairedAt
    }
}
