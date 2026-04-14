import XCTest
@testable import KeymeDesktop

final class KeyMaskingTests: XCTestCase {
    func testMaskStandardKey() {
        XCTAssertEqual(KeyMasking.mask("sk-proj-abc123def456ghi789"), "sk-p****789")
    }

    func testMaskShortKey() {
        XCTAssertEqual(KeyMasking.mask("sk-123"), "sk-****")
    }

    func testMaskEmpty() {
        XCTAssertEqual(KeyMasking.mask(""), "****")
    }

    func testDetectAPIKeyPatterns() {
        XCTAssertTrue(KeyMasking.looksLikeAPIKey("sk-proj-abc123def456"))
        XCTAssertTrue(KeyMasking.looksLikeAPIKey("sk-or-v1-abc123def456"))
        XCTAssertTrue(KeyMasking.looksLikeAPIKey("sk-ant-api03-abc123def456"))
        XCTAssertTrue(KeyMasking.looksLikeAPIKey("AIzaSyA1B2C3D4E5F6G7H8I9"))
        XCTAssertTrue(KeyMasking.looksLikeAPIKey("gsk_abc123def456ghi789jkl"))
        XCTAssertTrue(KeyMasking.looksLikeAPIKey("xai-abc123def456ghi789jkl"))
        XCTAssertFalse(KeyMasking.looksLikeAPIKey("hello world"))
        XCTAssertFalse(KeyMasking.looksLikeAPIKey("short"))
    }
}
