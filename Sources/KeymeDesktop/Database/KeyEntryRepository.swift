import Foundation
import GRDB

final class KeyEntryRepository {
    private let db: DatabaseManager

    init(db: DatabaseManager) { self.db = db }

    func save(_ entry: KeyEntry) throws {
        try db.dbQueue.write { db in
            let record = KeyEntryRecord(entry)
            // 기존 레코드가 있으면 update, 없으면 insert
            if try KeyEntryRecord.fetchOne(db, key: record.id) != nil {
                try record.update(db)
            } else {
                try record.insert(db)
            }
        }
    }

    func fetchAll(providerID: UUID? = nil) throws -> [KeyEntry] {
        try db.dbQueue.read { db in
            if let providerID {
                return try KeyEntryRecord.filter(Column("provider_id") == providerID.uuidString).fetchAll(db).map(\.toModel)
            }
            return try KeyEntryRecord.fetchAll(db).map(\.toModel)
        }
    }

    func search(tag: String) throws -> [KeyEntry] {
        try db.dbQueue.read { db in
            try KeyEntryRecord.filter(sql: "tags LIKE ?", arguments: ["%\"\(tag)\"%"]).fetchAll(db).map(\.toModel)
        }
    }

    func search(query: String) throws -> [KeyEntry] {
        try db.dbQueue.read { db in
            try KeyEntryRecord.filter(Column("alias").like("%\(query)%") || Column("tags").like("%\(query)%")).fetchAll(db).map(\.toModel)
        }
    }

    func delete(id: UUID) throws {
        try db.dbQueue.write { db in _ = try KeyEntryRecord.deleteOne(db, key: id.uuidString) }
    }
}
