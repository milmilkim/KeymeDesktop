import XCTest
@testable import KeymeDesktop

final class ProviderTests: XCTestCase {
    func testProviderCreation() {
        let provider = Provider(name: "OpenRouter", baseURL: "https://openrouter.ai/api/v1", dashboardURL: "https://openrouter.ai/keys", icon: "openrouter")
        XCTAssertEqual(provider.name, "OpenRouter")
        XCTAssertEqual(provider.baseURL, "https://openrouter.ai/api/v1")
        XCTAssertFalse(provider.id.uuidString.isEmpty)
    }

    func testProviderWithoutOptionalFields() {
        let provider = Provider(name: "Custom", baseURL: "https://api.example.com")
        XCTAssertNil(provider.dashboardURL)
        XCTAssertNil(provider.icon)
    }
}
