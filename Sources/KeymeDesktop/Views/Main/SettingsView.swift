import SwiftUI

struct SettingsView: View {
    @AppStorage("hotkeyDisplay") var hotkeyDisplay = "⌘⇧K"
    @AppStorage("autoMaskSeconds") var autoMaskSeconds = 30
    @AppStorage("clipboardToastEnabled") var clipboardToastEnabled = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("settings").font(.system(size: 14, weight: .semibold, design: .monospaced)).foregroundColor(Theme.accent)

            Group {
                HStack {
                    Text("quick save shortcut").font(.system(size: 11, design: .monospaced)).foregroundColor(Theme.textPrimary)
                    Spacer()
                    Text(hotkeyDisplay).font(.system(size: 11, design: .monospaced)).foregroundColor(Theme.accent)
                        .padding(.horizontal, 8).padding(.vertical, 4).background(Color.white.opacity(0.06)).cornerRadius(4)
                }

                HStack {
                    Text("auto re-mask after").font(.system(size: 11, design: .monospaced)).foregroundColor(Theme.textPrimary)
                    Spacer()
                    Picker("", selection: $autoMaskSeconds) {
                        Text("15s").tag(15)
                        Text("30s").tag(30)
                        Text("60s").tag(60)
                    }.frame(width: 80).font(.system(size: 10, design: .monospaced))
                }

                HStack {
                    Text("clipboard toast").font(.system(size: 11, design: .monospaced)).foregroundColor(Theme.textPrimary)
                    Spacer()
                    Toggle("", isOn: $clipboardToastEnabled).toggleStyle(.switch)
                }
            }

            Divider().background(Theme.border)

            Text("keyme v0.1.0").font(.system(size: 10, design: .monospaced)).foregroundColor(Theme.textMuted)

            Spacer()
        }
        .padding(16).background(Theme.bgPrimary)
    }
}
