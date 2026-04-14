import XCTest
@testable import KeymeDesktop

final class ClipboardMonitorTests: XCTestCase {
    func testDetectAPIKey() {
        let monitor = ClipboardMonitor()
        let expectation = expectation(description: "API key detected")

        NSPasteboard.general.clearContents()

        monitor.startMonitoring { item in
            XCTAssertTrue(item.isAPIKey)
            XCTAssertEqual(item.content, "sk-proj-abc123def456ghi789jkl")
            expectation.fulfill()
        }

        // 모니터 시작 후 클립보드에 키 복사
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("sk-proj-abc123def456ghi789jkl", forType: .string)

        waitForExpectations(timeout: 3)
        monitor.stopMonitoring()
    }

    func testIgnoreNonKey() {
        let monitor = ClipboardMonitor()

        NSPasteboard.general.clearContents()

        var detected = false
        monitor.startMonitoring { item in
            if !item.isAPIKey { detected = true }
        }

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("hello world this is normal text that is long enough", forType: .string)

        // 2초 대기 — non-key도 콜백은 옴
        RunLoop.main.run(until: Date().addingTimeInterval(2))
        monitor.stopMonitoring()

        // non-key 텍스트도 감지되지만 isAPIKey가 false
        XCTAssertTrue(detected)
    }
}
