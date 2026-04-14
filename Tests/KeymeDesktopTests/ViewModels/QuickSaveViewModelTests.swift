import XCTest
@testable import KeymeDesktop

final class QuickSaveViewModelTests: XCTestCase {
    var db: DatabaseManager!

    override func setUp() {
        super.setUp()
        db = try! DatabaseManager(inMemory: true)
    }

    func testAutoDetectClipboardKey() async {
        let providerRepo = ProviderRepository(db: db)
        let keyRepo = KeyEntryRepository(db: db)
        try! providerRepo.save(Provider(name: "OpenRouter", baseURL: "https://openrouter.ai/api/v1"))

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("sk-or-v1-test1234567890abcdef", forType: .string)

        let monitor = ClipboardMonitor()
        let vm = await QuickSaveViewModel(providerRepo: providerRepo, keyRepo: keyRepo, clipboardMonitor: monitor)
        await vm.load()

        await MainActor.run {
            XCTAssertEqual(vm.detectedKey, "sk-or-v1-test1234567890abcdef")
        }
    }

    func testSaveKey() async throws {
        let providerRepo = ProviderRepository(db: db)
        let keyRepo = KeyEntryRepository(db: db)
        let provider = Provider(name: "OpenRouter", baseURL: "https://openrouter.ai/api/v1")
        try providerRepo.save(provider)

        let vm = await QuickSaveViewModel(providerRepo: providerRepo, keyRepo: keyRepo, clipboardMonitor: ClipboardMonitor())
        await vm.load()

        await MainActor.run {
            vm.detectedKey = "sk-or-v1-newkey123456789"
            vm.selectedProviderID = provider.id
            vm.alias = "test key"
        }
        try await vm.save()

        let entries = try keyRepo.fetchAll()
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.apiKey, "sk-or-v1-newkey123456789")
    }
}
