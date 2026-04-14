import SwiftUI
import AppKit

final class ClipboardToastWindow {
    private var window: NSWindow?
    private var hideTimer: Timer?

    func show(item: ClipboardItem, onSaveClicked: @escaping () -> Void) {
        hideTimer?.invalidate()
        window?.close()

        let mouseLocation = NSEvent.mouseLocation
        let toastView = ClipboardToastView(item: item, onSaveClicked: {
            onSaveClicked()
            self.hide()
        })
        let hostingView = NSHostingView(rootView: toastView)

        let w = NSWindow(
            contentRect: NSRect(x: mouseLocation.x + 12, y: mouseLocation.y - 40, width: 240, height: 36),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        w.contentView = hostingView
        w.backgroundColor = .clear
        w.isOpaque = false
        w.level = .floating
        w.hasShadow = true
        w.ignoresMouseEvents = false
        w.collectionBehavior = [.canJoinAllSpaces, .stationary]

        w.orderFront(nil)
        self.window = w

        hideTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [weak self] _ in
            self?.hide()
        }
    }

    func hide() {
        hideTimer?.invalidate()
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.2
            window?.animator().alphaValue = 0
        }, completionHandler: { [weak self] in
            self?.window?.close()
            self?.window = nil
        })
    }
}

struct ClipboardToastView: View {
    let item: ClipboardItem
    let onSaveClicked: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            if item.isAPIKey {
                Image(systemName: "key.fill")
                    .font(.system(size: 10))
                    .foregroundColor(Theme.accent)
                Text("Save to Keyme")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Theme.accent)
                Spacer()
                Text(KeyMasking.mask(item.content))
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(Theme.textSecondary)
            } else {
                Image(systemName: "doc.on.clipboard")
                    .font(.system(size: 10))
                    .foregroundColor(Theme.textSecondary)
                Text("copied")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: NSColor.black.withAlphaComponent(0.85)))
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(item.isAPIKey ? Theme.accent.opacity(0.3) : Color.white.opacity(0.06), lineWidth: 1)
        )
        .onTapGesture {
            if item.isAPIKey { onSaveClicked() }
        }
    }
}
