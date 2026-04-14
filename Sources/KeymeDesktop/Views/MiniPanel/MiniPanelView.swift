import SwiftUI

struct MiniPanelView: View {
    @ObservedObject var vm: MiniPanelViewModel
    let onOpenMain: () -> Void
    let onAddKey: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Search
            TextField("Search...", text: $vm.searchQuery)
                .textFieldStyle(.roundedBorder)
                .font(Theme.fontMonoSmall)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

            Divider()

            if vm.filteredEntries.isEmpty {
                VStack(spacing: 6) {
                    Text("No keys")
                        .font(Theme.fontMono)
                        .foregroundColor(Theme.textSecondary)
                    Text("⌘⇧K to quick save")
                        .font(Theme.fontMonoSmall)
                        .foregroundColor(Theme.textMuted)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(height: 120)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(vm.filteredEntries) { entry in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(vm.providerName(for: entry))
                                        .font(Theme.fontMonoSmall)
                                        .foregroundColor(Theme.accent)
                                    Text(entry.alias)
                                        .font(Theme.fontMono)
                                        .foregroundColor(Theme.textPrimary)
                                }
                                Spacer()
                                Text(KeyMasking.mask(entry.apiKey))
                                    .font(Theme.fontMonoSmall)
                                    .foregroundColor(Theme.textSecondary)
                                Button(action: { Task { await vm.copyKey(entry) } }) {
                                    Image(systemName: "doc.on.doc")
                                }
                                .buttonStyle(.borderless)
                                .help("Copy key")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                            Divider().padding(.horizontal, 12)
                        }
                    }
                }
                .frame(maxHeight: 280)
            }

            // Footer
            Divider()
            HStack {
                Button(action: onAddKey) {
                    Label("Add Key", systemImage: "plus")
                        .font(Theme.fontMonoSmall)
                }
                .buttonStyle(.borderless)

                Spacer()

                Button("Open Keyme →") { onOpenMain() }
                    .font(Theme.fontMonoSmall)
                    .buttonStyle(.borderless)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .frame(width: 320)
        .task { await vm.load() }
    }
}
