import AppKit

final class ClipboardToastWindow {
    private var window: NSWindow?
    private var hideTimer: Timer?

    func show(item: ClipboardItem) {
        guard item.isAPIKey else { return }

        hideTimer?.invalidate()
        window?.close()
        window = nil

        let mouseLocation = NSEvent.mouseLocation

        // 순수 AppKit으로 토스트 구성
        let label = NSTextField(labelWithString: "🔑 API key copied — ⌘⇧K to save")
        label.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .medium)
        label.textColor = .white
        label.backgroundColor = .clear
        label.isBezeled = false
        label.isEditable = false
        label.sizeToFit()

        let padding: CGFloat = 12
        let width = label.frame.width + padding * 2
        let height: CGFloat = 30

        label.frame.origin = CGPoint(x: padding, y: (height - label.frame.height) / 2)

        let container = NSView(frame: NSRect(x: 0, y: 0, width: width, height: height))
        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.8).cgColor
        container.layer?.cornerRadius = 8
        container.addSubview(label)

        let w = NSWindow(
            contentRect: NSRect(x: mouseLocation.x + 12, y: mouseLocation.y - 40, width: width, height: height),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        w.contentView = container
        w.backgroundColor = .clear
        w.isOpaque = false
        w.level = .floating
        w.hasShadow = true
        w.ignoresMouseEvents = true
        w.orderFront(nil)
        self.window = w

        hideTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.window?.close()
            self?.window = nil
        }
    }
}
