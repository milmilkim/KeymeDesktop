import SwiftUI

@main
struct KeymeDesktopApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings { EmptyView() }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var appState: AppState!
    private var miniPanelVM: MiniPanelViewModel!

    func applicationDidFinishLaunching(_ notification: Notification) {
        appState = try! AppState()
        miniPanelVM = MiniPanelViewModel(
            providerRepo: appState.providerRepo,
            keyRepo: appState.keyRepo,
            authService: appState.authService
        )

        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 360)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(
            rootView: MiniPanelView(vm: miniPanelVM, onOpenMain: { [weak self] in
                self?.openMainWindow()
            })
        )

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "key.fill", accessibilityDescription: "Keyme")
            button.image?.size = NSSize(width: 16, height: 16)
            button.action = #selector(togglePopover)
            button.target = self
        }
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    private func openMainWindow() {
        popover.performClose(nil)
        // TODO: Layer 4 main window (Task 9)
    }
}
