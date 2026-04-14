import SwiftUI
import AppKit

final class QuickSavePanelController {
    private var panel: NSPanel?

    func show(vm: QuickSaveViewModel) {
        if let existing = panel, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            return
        }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 300),
            styleMask: [.titled, .closable, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        panel.title = "Quick Save"
        panel.level = .floating
        panel.hasShadow = true
        panel.isReleasedWhenClosed = false

        let view = QuickSaveView(vm: vm, onDismiss: { [weak self] in
            self?.panel?.close()
            self?.panel = nil
        })
        panel.contentView = NSHostingView(rootView: view)
        panel.center()

        if #available(macOS 14.0, *) {
            NSApp.activate()
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }
        panel.makeKeyAndOrderFront(nil)
        self.panel = panel
    }
}

struct QuickSaveView: View {
    @ObservedObject var vm: QuickSaveViewModel
    let onDismiss: () -> Void

    var body: some View {
        Form {
            Section {
                TextField("API Key", text: $vm.detectedKey)
                    .font(Theme.fontMono)

                Picker("Provider", selection: $vm.selectedProviderID) {
                    Text("Select...").tag(nil as UUID?)
                    ForEach(vm.providers) { p in Text(p.name).tag(p.id as UUID?) }
                }

                TextField("Alias", text: $vm.alias)

                TextField("Tags (comma separated)", text: $vm.tags)
                    .font(Theme.fontMonoSmall)
            }

            Section {
                HStack {
                    Spacer()
                    Button("Cancel", role: .cancel) {
                        onDismiss()
                    }
                    .keyboardShortcut(.cancelAction)

                    Button("Save") {
                        // 동기적으로 저장, async 안 씀
                        do {
                            guard let providerID = vm.selectedProviderID, !vm.detectedKey.isEmpty else { return }
                            let parsedTags = vm.tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                            let entry = KeyEntry(providerID: providerID, alias: vm.alias.isEmpty ? "Key \(Date().formatted(.dateTime.month().day().hour().minute()))" : vm.alias, apiKey: vm.detectedKey, tags: parsedTags)
                            try vm.keyRepo.save(entry)
                            vm.reset()
                            onDismiss()
                        } catch {
                            // 저장 실패 시 무시
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(vm.detectedKey.isEmpty || vm.selectedProviderID == nil)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 380, height: 280)
        .task { await vm.load() }
    }
}
