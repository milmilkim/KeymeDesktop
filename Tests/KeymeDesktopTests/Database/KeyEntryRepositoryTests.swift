import XCTest
@testable import KeymeDesktop

final class KeyEntryRepositoryTests: XCTestCase {
    var db: DatabaseManager!
    var providerRepo: ProviderRepository!
    var keyRepo: KeyEntryRepository!
    var testProvider: Provider!

    override func setUp() {
        super.setUp()
        db = try! DatabaseManager(inMemory: true)
        providerRepo = ProviderRepository(db: db)
        keyRepo = KeyEntryRepository(db: db)
        testProvider = Provider(name: "OpenRouter", baseURL: "https://openrouter.ai/api/v1")
        try! providerRepo.save(testProvider)
    }

    func testInsertAndFetch() throws {
        try keyRepo.save(KeyEntry(providerID: testProvider.id, alias: "main", apiKey: "sk-or-test"))
        let all = try keyRepo.fetchAll(providerID: testProvider.id)
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.alias, "main")
    }

    func testSearchByTag() throws {
        try keyRepo.save(KeyEntry(providerID: testProvider.id, alias: "work", apiKey: "sk-1", tags: ["work"]))
        try keyRepo.save(KeyEntry(providerID: testProvider.id, alias: "personal", apiKey: "sk-2", tags: ["personal"]))
        let results = try keyRepo.search(tag: "work")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.alias, "work")
    }

    func testSearchByQuery() throws {
        try keyRepo.save(KeyEntry(providerID: testProvider.id, alias: "rp-main", apiKey: "sk-1"))
        try keyRepo.save(KeyEntry(providerID: testProvider.id, alias: "dev-test", apiKey: "sk-2"))
        let results = try keyRepo.search(query: "rp")
        XCTAssertEqual(results.count, 1)
    }

    func testCascadeDelete() throws {
        try keyRepo.save(KeyEntry(providerID: testProvider.id, alias: "cascade", apiKey: "sk-x"))
        try providerRepo.delete(id: testProvider.id)
        XCTAssertTrue(try keyRepo.fetchAll(providerID: testProvider.id).isEmpty)
    }
}
