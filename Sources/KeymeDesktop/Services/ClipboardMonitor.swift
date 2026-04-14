import AppKit
import Combine

final class ClipboardMonitor: ObservableObject {
    @Published var latestItem: ClipboardItem?
    @Published var history: [ClipboardItem] = []

    private var lastChangeCount: Int
    private var timer: Timer?

    init() {
        lastChangeCount = NSPasteboard.general.changeCount
    }

    func checkClipboard() -> ClipboardItem? {
        let currentCount = NSPasteboard.general.changeCount
        guard currentCount != lastChangeCount else { return nil }
        lastChangeCount = currentCount

        guard let content = NSPasteboard.general.string(forType: .string) else { return nil }
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let isKey = KeyMasking.looksLikeAPIKey(trimmed)
        let item = ClipboardItem(content: trimmed, isAPIKey: isKey)
        return item
    }

    func startMonitoring(onClipboardChange: @escaping (ClipboardItem) -> Void) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self, let item = self.checkClipboard() else { return }
            DispatchQueue.main.async {
                self.latestItem = item
                self.history.insert(item, at: 0)
                if self.history.count > 100 { self.history.removeLast() }
                onClipboardChange(item)
            }
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        lastChangeCount = NSPasteboard.general.changeCount
    }
}
