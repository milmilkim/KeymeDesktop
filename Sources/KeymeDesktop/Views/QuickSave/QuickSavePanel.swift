import SwiftUI
import AppKit

final class QuickSavePanelController {
    private var panel: NSPanel?

    func show(vm: QuickSaveViewModel) {
        if let existing = panel, existing.isVisible {
            existing.close()
            self.panel = nil
            return
        }

        let view = QuickSaveView(vm: vm, onDismiss: { [weak self] in self?.hide() })
        let hostingView = NSHostingView(rootView: view)

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 340),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.contentView = hostingView
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.level = .floating
        panel.hasShadow = true
        panel.isMovableByWindowBackground = true
        panel.center()
        panel.orderFront(nil)

        self.panel = panel
    }

    func hide() {
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.15
            panel?.animator().alphaValue = 0
        }, completionHandler: { [weak self] in
            self?.panel?.close()
            self?.panel = nil
        })
    }
}

struct QuickSaveView: View {
    @ObservedObject var vm: QuickSaveViewModel
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("quick save")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(Theme.accent)
                Spacer()
                HStack(spacing: 6) {
                    Text("⌘⇧K")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(Theme.textSecondary)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color.white.opacity(0.06)).cornerRadius(3)
                    Text("esc")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(Theme.textMuted)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    Text("key").font(.system(size: 9, design: .monospaced)).foregroundColor(Theme.textSecondary)
                    if !vm.detectedKey.isEmpty {
                        Text("clipboard").font(.system(size: 8, design: .monospaced)).foregroundColor(Theme.accent)
                            .padding(.horizontal, 5).padding(.vertical, 1).background(Theme.accentSubtle).cornerRadius(2)
                    }
                }
                TextField("paste api key...", text: $vm.detectedKey)
                    .font(.system(size: 12, design: .monospaced)).textFieldStyle(.plain)
                    .padding(8).background(Color.white.opacity(0.04))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.border)).cornerRadius(6)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("provider").font(.system(size: 9, design: .monospaced)).foregroundColor(Theme.textSecondary)
                Picker("", selection: $vm.selectedProviderID) {
                    ForEach(vm.providers) { p in Text(p.name).tag(p.id as UUID?) }
                }.font(.system(size: 12, design: .monospaced))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("alias").font(.system(size: 9, design: .monospaced)).foregroundColor(Theme.textSecondary)
                TextField("description...", text: $vm.alias)
                    .font(.system(size: 12, design: .monospaced)).textFieldStyle(.plain)
                    .padding(8).background(Color.white.opacity(0.04))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.border)).cornerRadius(6)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("tags").font(.system(size: 9, design: .monospaced)).foregroundColor(Theme.textSecondary)
                TextField("personal, rp...", text: $vm.tags)
                    .font(.system(size: 12, design: .monospaced)).textFieldStyle(.plain)
                    .padding(8).background(Color.white.opacity(0.04))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.border)).cornerRadius(6)
            }

            HStack {
                Spacer()
                if vm.isSaved {
                    Text("saved ✓").font(.system(size: 12, design: .monospaced)).foregroundColor(Theme.accent)
                } else {
                    Button(action: {
                        Task {
                            try? await vm.save()
                            try? await Task.sleep(for: .seconds(0.8))
                            onDismiss()
                            vm.reset()
                        }
                    }) {
                        Text("save")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(Theme.bgPrimary)
                            .padding(.horizontal, 18).padding(.vertical, 6)
                            .background(Theme.accent).cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.return, modifiers: [])
                }
            }
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(nsColor: NSColor.black.withAlphaComponent(0.88))))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08)))
        .shadow(color: .black.opacity(0.5), radius: 30, y: 12)
        .onExitCommand { onDismiss() }
        .task { await vm.load() }
    }
}
