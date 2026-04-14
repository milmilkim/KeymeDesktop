import SwiftUI

struct KeyListView: View {
    @ObservedObject var vm: KeyListViewModel
    let onPlayground: (KeyEntry, Provider) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass").font(.system(size: 11)).foregroundColor(Theme.textSecondary)
                    TextField("search keys, tags, providers...", text: $vm.searchQuery)
                        .font(.system(size: 11, design: .monospaced)).textFieldStyle(.plain)
                }
                .padding(6).background(Color.white.opacity(0.03))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.border)).cornerRadius(6)

                Picker("", selection: $vm.selectedProviderID) {
                    Text("all providers").tag(nil as UUID?)
                    ForEach(vm.providers) { p in Text(p.name).tag(p.id as UUID?) }
                }.font(.system(size: 10, design: .monospaced)).frame(width: 160)
            }
            .padding(.horizontal, 14).padding(.vertical, 10)

            Divider().background(Theme.border)

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(vm.filteredEntries) { entry in
                        KeyRowView(
                            entry: entry,
                            providerName: vm.providerName(for: entry),
                            isRevealed: vm.revealedKeyIDs.contains(entry.id),
                            dashboardURL: vm.provider(for: entry)?.dashboardURL,
                            onReveal: { Task { await vm.revealKey(id: entry.id) } },
                            onCopy: { Task { await vm.copyKey(entry) } },
                            onPlayground: { if let p = vm.provider(for: entry) { onPlayground(entry, p) } },
                            onDelete: { Task { await vm.deleteEntry(id: entry.id) } }
                        )
                        Divider().background(Theme.border)
                    }
                }
            }

            Divider().background(Theme.border)
            HStack {
                Text("\(vm.filteredEntries.count) keys · \(vm.providers.count) providers")
                    .font(.system(size: 9, design: .monospaced)).foregroundColor(Theme.textMuted)
                Spacer()
                Text("⌘⇧K quick save")
                    .font(.system(size: 9, design: .monospaced)).foregroundColor(Theme.textMuted)
            }
            .padding(.horizontal, 14).padding(.vertical, 6)
        }
        .background(Theme.bgPrimary)
        .task { await vm.load() }
    }
}
