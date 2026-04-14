import SwiftUI

struct MainContentView: View {
    @ObservedObject var keyListVM: KeyListViewModel
    @ObservedObject var playgroundVM: PlaygroundViewModel
    @ObservedObject var syncVM: SyncViewModel
    let providerRepo: ProviderRepository
    @State private var tab = 0
    @State private var showProviderForm = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                tabBtn("keys", 0); tabBtn("playground", 1); tabBtn("sync", 2); tabBtn("settings", 3)
                Spacer()
                Button("+ provider") { showProviderForm = true }
                    .font(.system(size: 10, design: .monospaced)).buttonStyle(.plain).foregroundColor(Theme.accent)
                    .padding(.trailing, 14)
            }
            .padding(.leading, 14).padding(.top, 8)

            Divider().background(Theme.border)

            switch tab {
            case 0: KeyListView(vm: keyListVM, onPlayground: { entry, provider in
                playgroundVM.selectEntry(entry, provider: provider); tab = 1
            })
            case 1: PlaygroundView(vm: playgroundVM)
            case 2: SyncView(vm: syncVM)
            case 3: SettingsView()
            default: EmptyView()
            }
        }
        .background(Theme.bgPrimary)
        .sheet(isPresented: $showProviderForm) {
            ProviderFormView { provider in
                try? providerRepo.save(provider)
                Task { await keyListVM.load() }
            }
        }
    }

    private func tabBtn(_ title: String, _ index: Int) -> some View {
        Button(title) { tab = index }
            .font(.system(size: 11, design: .monospaced))
            .foregroundColor(tab == index ? Theme.accent : Theme.textSecondary)
            .padding(.horizontal, 12).padding(.vertical, 8)
            .overlay(tab == index ? Rectangle().fill(Theme.accent).frame(height: 2).offset(y: 12) : nil, alignment: .bottom)
            .buttonStyle(.plain)
    }
}
