import XCTest
@testable import KeymeDesktop

final class DatabaseManagerTests: XCTestCase {
    func testDatabaseCreation() throws {
        let db = try DatabaseManager(inMemory: true)
        XCTAssertNotNil(db)
    }

    func testTablesExist() throws {
        let db = try DatabaseManager(inMemory: true)
        let tables = try db.tableNames()
        XCTAssertTrue(tables.contains("providers"))
        XCTAssertTrue(tables.contains("key_entries"))
        XCTAssertTrue(tables.contains("paired_devices"))
    }
}
