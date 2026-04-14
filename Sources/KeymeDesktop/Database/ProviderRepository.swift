import Foundation
import GRDB

final class ProviderRepository {
    let db: DatabaseManager

    init(db: DatabaseManager) { self.db = db }

    func save(_ provider: Provider) throws {
        try db.dbQueue.write { db in
            let record = ProviderRecord(provider)
            if try ProviderRecord.fetchOne(db, key: record.id) != nil {
                try record.update(db)
            } else {
                try record.insert(db)
            }
        }
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
