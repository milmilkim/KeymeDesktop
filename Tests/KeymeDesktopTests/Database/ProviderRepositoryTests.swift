import XCTest
@testable import KeymeDesktop

final class ProviderRepositoryTests: XCTestCase {
    var db: DatabaseManager!
    var repo: ProviderRepository!

    override func setUp() {
        super.setUp()
        db = try! DatabaseManager(inMemory: true)
        repo = ProviderRepository(db: db)
    }

    func testInsertAndFetch() throws {
        let p = Provider(name: "OpenRouter", baseURL: "https://openrouter.ai/api/v1", dashboardURL: "https://openrouter.ai/keys")
        try repo.save(p)
        let all = try repo.fetchAll()
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.name, "OpenRouter")
    }

    func testDelete() throws {
        let p = Provider(name: "Test", baseURL: "https://test.com")
        try repo.save(p)
        try repo.delete(id: p.id)
        XCTAssertTrue(try repo.fetchAll().isEmpty)
    }

    func testUpdate() throws {
        var p = Provider(name: "Old", baseURL: "https://old.com")
        try repo.save(p)
        p.name = "New"
        try repo.save(p)
        let all = try repo.fetchAll()
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.name, "New")
    }
}
