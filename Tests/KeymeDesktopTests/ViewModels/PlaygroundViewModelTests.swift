import XCTest
@testable import KeymeDesktop

final class PlaygroundViewModelTests: XCTestCase {
    func testSelectEntryPopulatesFields() async {
        let provider = Provider(name: "OpenRouter", baseURL: "https://openrouter.ai/api/v1")
        let entry = KeyEntry(providerID: provider.id, alias: "test", apiKey: "sk-or-test123", models: ["claude-3.5-sonnet"])

        let vm = await PlaygroundViewModel()
        await vm.selectEntry(entry, provider: provider)

        await MainActor.run {
            XCTAssertEqual(vm.url, "https://openrouter.ai/api/v1/chat/completions")
            XCTAssertEqual(vm.method, "POST")
            XCTAssertTrue(vm.headers.contains(where: { $0.key == "Authorization" && $0.value == "Bearer sk-or-test123" }))
            XCTAssertTrue(vm.body.contains("claude-3.5-sonnet"))
        }
    }
}
