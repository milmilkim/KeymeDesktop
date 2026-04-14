import Foundation
import GRDB

final class DatabaseManager {
    let dbQueue: DatabaseQueue

    init(inMemory: Bool = false) throws {
        if inMemory {
            dbQueue = try DatabaseQueue()
        } else {
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                .appendingPathComponent("Keyme", isDirectory: true)
            try FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true)
            let dbPath = appSupport.appendingPathComponent("keyme.db").path
            dbQueue = try DatabaseQueue(path: dbPath)
        }
        try migrate()
    }

    private func migrate() throws {
        var migrator = DatabaseMigrator()
        migrator.registerMigration("v1") { db in
            try db.create(table: "providers") { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("base_url", .text).notNull()
                t.column("dashboard_url", .text)
                t.column("icon", .text)
                t.column("created_at", .datetime).notNull()
            }
            try db.create(table: "key_entries") { t in
                t.column("id", .text).primaryKey()
                t.column("provider_id", .text).notNull().references("providers", onDelete: .cascade)
                t.column("alias", .text).notNull()
                t.column("api_key", .text).notNull()
                t.column("tags", .text).notNull().defaults(to: "[]")
                t.column("models", .text)
                t.column("created_at", .datetime).notNull()
            }
            try db.create(table: "paired_devices") { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("public_key", .blob).notNull()
                t.column("paired_at", .datetime).notNull()
            }
        }
        try migrator.migrate(dbQueue)
    }

    func tableNames() throws -> [String] {
        try dbQueue.read { db in
            try String.fetchAll(db, sql: "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'grdb_%'")
        }
    }

    func exportSnapshot() throws -> Data {
        try dbQueue.read { db in
            let providers = try ProviderRecord.fetchAll(db)
            let entries = try KeyEntryRecord.fetchAll(db)
            let snapshot = DatabaseSnapshot(providers: providers, entries: entries)
            return try JSONEncoder().encode(snapshot)
        }
    }
}

struct DatabaseSnapshot: Codable {
    let providers: [ProviderRecord]
    let entries: [KeyEntryRecord]
}
