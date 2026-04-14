import AppKit

final class ClipboardMonitor {
    private var lastChangeCount: Int
    private var timer: Timer?
    private var onChange: ((ClipboardItem) -> Void)?

    init() {
        lastChangeCount = NSPasteboard.general.changeCount
    }

    func startMonitoring(onClipboardChange: @escaping (ClipboardItem) -> Void) {
        self.onChange = onClipboardChange
        // RunLoop.main에서 직접 실행 — DispatchQueue 이중 디스패치 없음
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.poll()
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        onChange = nil
    }

    private func poll() {
        let currentCount = NSPasteboard.general.changeCount
        guard currentCount != lastChangeCount else { return }
        lastChangeCount = currentCount

        guard let content = NSPasteboard.general.string(forType: .string) else { return }
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let item = ClipboardItem(
            content: trimmed,
            isAPIKey: KeyMasking.looksLikeAPIKey(trimmed)
        )
        onChange?(item)
    }
}
