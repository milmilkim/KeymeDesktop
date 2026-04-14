import SwiftUI
import AppKit

final class MainWindowController {
    private var window: NSWindow?

    func show(contentView: some View) {
        if let existing = window, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            if #available(macOS 14.0, *) {
                NSApp.activate()
            } else {
                NSApp.activate(ignoringOtherApps: true)
            }
            return
        }

        let w = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 500),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        w.title = "Keyme"
        w.contentView = NSHostingView(rootView: contentView)
        w.isReleasedWhenClosed = false
        w.level = .normal
        w.center()

        // LSUIElement 앱에서 윈도우를 제대로 띄우려면
        // 먼저 activate 하고 나서 윈도우를 보여줘야 함
        NSApp.setActivationPolicy(.regular)
        if #available(macOS 14.0, *) {
            NSApp.activate()
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }
        w.makeKeyAndOrderFront(nil)

        self.window = w
    }
}
