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
    private var hotkeyService: HotkeyService!
    private var quickSavePanel: QuickSavePanelController!
    private var quickSaveVM: QuickSaveViewModel!
    private var mainWindowController: MainWindowController!
    private var keyListVM: KeyListViewModel!
    private var playgroundVM: PlaygroundViewModel!
    private var syncVM: SyncViewModel!

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
            }, onAddKey: { [weak self] in
                self?.popover.performClose(nil)
                self?.showQuickSave()
            })
        )

        quickSaveVM = QuickSaveViewModel(
            providerRepo: appState.providerRepo,
            keyRepo: appState.keyRepo
        )
        quickSavePanel = QuickSavePanelController()

        hotkeyService = HotkeyService { [weak self] in
            self?.showQuickSave()
        }
        hotkeyService.register()

        keyListVM = KeyListViewModel(providerRepo: appState.providerRepo, keyRepo: appState.keyRepo, authService: appState.authService)
        playgroundVM = PlaygroundViewModel()
        syncVM = SyncViewModel(server: SyncServer(db: appState.db))
        mainWindowController = MainWindowController()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "key.fill", accessibilityDescription: "Keyme")
            button.image?.size = NSSize(width: 16, height: 16)
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
    }

    @objc private func togglePopover(_ sender: NSStatusBarButton) {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            // 열 때마다 최신 데이터 로드
            Task { await miniPanelVM.load() }
            popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    private func showQuickSave() {
        Task { @MainActor in
            quickSaveVM.reset()
            await quickSaveVM.load()
            quickSavePanel.show(vm: quickSaveVM)
        }
    }

    private func openMainWindow() {
        popover.performClose(nil)
        mainWindowController.show(contentView:
            MainContentView(
                keyListVM: keyListVM,
                playgroundVM: playgroundVM,
                syncVM: syncVM,
                providerRepo: appState.providerRepo,
                keyRepo: appState.keyRepo
            )
        )
    }
}
