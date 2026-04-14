import XCTest
@testable import KeymeDesktop

final class MiniPanelViewModelTests: XCTestCase {
    var db: DatabaseManager!

    override func setUp() {
        super.setUp()
        db = try! DatabaseManager(inMemory: true)
    }

    func testLoadRecentKeys() async throws {
        let providerRepo = ProviderRepository(db: db)
        let keyRepo = KeyEntryRepository(db: db)
        let provider = Provider(name: "OpenRouter", baseURL: "https://openrouter.ai/api/v1")
        try providerRepo.save(provider)
        try keyRepo.save(KeyEntry(providerID: provider.id, alias: "key1", apiKey: "sk-1"))
        try keyRepo.save(KeyEntry(providerID: provider.id, alias: "key2", apiKey: "sk-2"))
        try keyRepo.save(KeyEntry(providerID: provider.id, alias: "key3", apiKey: "sk-3"))

        let vm = await MiniPanelViewModel(providerRepo: providerRepo, keyRepo: keyRepo, authService: MockAuthService())
        await vm.load()

        await MainActor.run {
            XCTAssertEqual(vm.recentEntries.count, 3)
        }
    }

    func testSearchFilter() async throws {
        let providerRepo = ProviderRepository(db: db)
        let keyRepo = KeyEntryRepository(db: db)
        let provider = Provider(name: "OpenRouter", baseURL: "https://openrouter.ai/api/v1")
        try providerRepo.save(provider)
        try keyRepo.save(KeyEntry(providerID: provider.id, alias: "rp-main", apiKey: "sk-1"))
        try keyRepo.save(KeyEntry(providerID: provider.id, alias: "dev-test", apiKey: "sk-2"))

        let vm = await MiniPanelViewModel(providerRepo: providerRepo, keyRepo: keyRepo, authService: MockAuthService())
        await vm.load()

        await MainActor.run {
            vm.searchQuery = "rp"
            XCTAssertEqual(vm.filteredEntries.count, 1)
            XCTAssertEqual(vm.filteredEntries.first?.alias, "rp-main")
        }
    }
}
