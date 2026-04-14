import Foundation
import GRDB

final class ProviderRepository {
    let db: DatabaseManager

    init(db: DatabaseManager) { self.db = db }

    func save(_ provider: Provider) throws {
        try db.dbQueue.write { db in try ProviderRecord(provider).save(db) }
    }

    func fetchAll() throws -> [Provider] {
        try db.dbQueue.read { db in try ProviderRecord.fetchAll(db).map(\.toModel) }
    }

    func fetch(id: UUID) throws -> Provider? {
        try db.dbQueue.read { db in try ProviderRecord.fetchOne(db, key: id.uuidString)?.toModel }
    }

    func delete(id: UUID) throws {
        try db.dbQueue.write { db in _ = try ProviderRecord.deleteOne(db, key: id.uuidString) }
    }
}
