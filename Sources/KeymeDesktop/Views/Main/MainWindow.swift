import SwiftUI
import AppKit

final class MainWindowController {
    private var window: NSWindow?

    func show(contentView: some View) {
        if let existing = window, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let w = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 500),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        w.title = "keyme"
        w.titlebarAppearsTransparent = true
        w.backgroundColor = NSColor(Theme.bgPrimary)
        w.contentView = NSHostingView(rootView: contentView)
        w.center()
        w.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        self.window = w
    }
}
