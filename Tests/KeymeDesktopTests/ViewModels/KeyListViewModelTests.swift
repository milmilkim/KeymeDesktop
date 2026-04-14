import XCTest
@testable import KeymeDesktop

final class KeyListViewModelTests: XCTestCase {
    var db: DatabaseManager!

    override func setUp() {
        super.setUp()
        db = try! DatabaseManager(inMemory: true)
    }

    func testLoadWithData() async throws {
        let providerRepo = ProviderRepository(db: db)
        let keyRepo = KeyEntryRepository(db: db)
        let provider = Provider(name: "OpenRouter", baseURL: "https://openrouter.ai/api/v1")
        try providerRepo.save(provider)
        try keyRepo.save(KeyEntry(providerID: provider.id, alias: "main", apiKey: "sk-test"))

        let vm = await KeyListViewModel(providerRepo: providerRepo, keyRepo: keyRepo, authService: MockAuthService())
        await vm.load()
        await MainActor.run {
            XCTAssertEqual(vm.providers.count, 1)
            XCTAssertEqual(vm.entries.count, 1)
        }
    }

    func testFilterByProvider() async throws {
        let providerRepo = ProviderRepository(db: db)
        let keyRepo = KeyEntryRepository(db: db)
        let p1 = Provider(name: "OpenRouter", baseURL: "https://openrouter.ai/api/v1")
        let p2 = Provider(name: "Anthropic", baseURL: "https://api.anthropic.com")
        try providerRepo.save(p1)
        try providerRepo.save(p2)
        try keyRepo.save(KeyEntry(providerID: p1.id, alias: "or-key", apiKey: "sk-or"))
        try keyRepo.save(KeyEntry(providerID: p2.id, alias: "ant-key", apiKey: "sk-ant"))

        let vm = await KeyListViewModel(providerRepo: providerRepo, keyRepo: keyRepo, authService: MockAuthService())
        await vm.load()
        await MainActor.run {
            vm.selectedProviderID = p1.id
            XCTAssertEqual(vm.filteredEntries.count, 1)
            XCTAssertEqual(vm.filteredEntries.first?.alias, "or-key")
        }
    }

    func testSearch() async throws {
        let providerRepo = ProviderRepository(db: db)
        let keyRepo = KeyEntryRepository(db: db)
        let provider = Provider(name: "OpenRouter", baseURL: "https://openrouter.ai/api/v1")
        try providerRepo.save(provider)
        try keyRepo.save(KeyEntry(providerID: provider.id, alias: "work", apiKey: "sk-1", tags: ["work"]))
        try keyRepo.save(KeyEntry(providerID: provider.id, alias: "personal", apiKey: "sk-2", tags: ["personal"]))

        let vm = await KeyListViewModel(providerRepo: providerRepo, keyRepo: keyRepo, authService: MockAuthService())
        await vm.load()
        await MainActor.run {
            vm.searchQuery = "work"
            XCTAssertEqual(vm.filteredEntries.count, 1)
        }
    }
}
