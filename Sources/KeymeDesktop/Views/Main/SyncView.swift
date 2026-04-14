import SwiftUI

struct SyncView: View {
    @ObservedObject var vm: SyncViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Circle().fill(vm.isRunning ? Theme.accent : Theme.danger).frame(width: 8, height: 8)
                Text(vm.isRunning ? "server running" : "server stopped")
                    .font(.system(size: 12, design: .monospaced)).foregroundColor(Theme.textPrimary)
                Spacer()
                Button(vm.isRunning ? "stop" : "start") {
                    vm.isRunning ? vm.stopServer() : vm.startServer()
                }
                .font(.system(size: 11, design: .monospaced)).buttonStyle(.plain).foregroundColor(Theme.accent)
            }

            Divider().background(Theme.border)

            if let code = vm.pairingCode {
                VStack(spacing: 8) {
                    Text("pairing code").font(.system(size: 10, design: .monospaced)).foregroundColor(Theme.textSecondary)
                    Text(code)
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.accent).tracking(12)
                    Text("enter on mobile").font(.system(size: 10, design: .monospaced)).foregroundColor(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 20)
            } else {
                Button("generate pairing code") { vm.showPairingCode() }
                    .font(.system(size: 11, design: .monospaced)).buttonStyle(.plain).foregroundColor(Theme.accent)
                    .disabled(!vm.isRunning)
            }

            if let device = vm.connectedDevice {
                HStack {
                    Image(systemName: "iphone").foregroundColor(Theme.accent)
                    Text(device).font(.system(size: 11, design: .monospaced)).foregroundColor(Theme.textPrimary)
                }
            }

            Spacer()
        }
        .padding(16).background(Theme.bgPrimary)
    }
}
