import XCTest
@testable import KeymeDesktop

final class KeyEntryTests: XCTestCase {
    func testKeyEntryCreation() {
        let providerID = UUID()
        let entry = KeyEntry(providerID: providerID, alias: "sound@gmail.com / main", apiKey: "sk-test-1234567890", tags: ["personal", "main"], models: ["gpt-4", "claude-3.5-sonnet"])
        XCTAssertEqual(entry.providerID, providerID)
        XCTAssertEqual(entry.alias, "sound@gmail.com / main")
        XCTAssertEqual(entry.apiKey, "sk-test-1234567890")
        XCTAssertEqual(entry.tags, ["personal", "main"])
        XCTAssertEqual(entry.models, ["gpt-4", "claude-3.5-sonnet"])
    }

    func testKeyEntryWithoutOptionalFields() {
        let entry = KeyEntry(providerID: UUID(), alias: "test", apiKey: "sk-abc")
        XCTAssertTrue(entry.tags.isEmpty)
        XCTAssertNil(entry.models)
    }
}
