import XCTest
@testable import KeymeDesktop

final class ClipboardMonitorTests: XCTestCase {
    func testDetectAPIKeyFromClipboard() {
        let monitor = ClipboardMonitor()
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("sk-proj-abc123def456ghi789jkl", forType: .string)
        let item = monitor.checkClipboard()
        XCTAssertNotNil(item)
        XCTAssertTrue(item!.isAPIKey)
        XCTAssertEqual(item!.content, "sk-proj-abc123def456ghi789jkl")
    }

    func testDetectNonKeyText() {
        let monitor = ClipboardMonitor()
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("hello world this is normal text", forType: .string)
        let item = monitor.checkClipboard()
        XCTAssertNotNil(item)
        XCTAssertFalse(item!.isAPIKey)
    }

    func testNoChangeReturnsNil() {
        let monitor = ClipboardMonitor()
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("test", forType: .string)
        _ = monitor.checkClipboard()
        let second = monitor.checkClipboard()
        XCTAssertNil(second)
    }
}
