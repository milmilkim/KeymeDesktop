import SwiftUI

struct KeyListView: View {
    @ObservedObject var vm: KeyListViewModel
    let onPlayground: (KeyEntry, Provider) -> Void
    var onEdit: ((KeyEntry) -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            // Search + Filter
            HStack(spacing: 8) {
                TextField("Search keys, tags, providers...", text: $vm.searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .font(Theme.fontMonoSmall)

                Picker("", selection: $vm.selectedProviderID) {
                    Text("All Providers").tag(nil as UUID?)
                    ForEach(vm.providers) { p in Text(p.name).tag(p.id as UUID?) }
                }
                .frame(width: 160)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            Divider()

            if vm.filteredEntries.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "key")
                        .font(.system(size: 32))
                        .foregroundColor(Theme.textMuted)
                    Text("No keys yet")
                        .font(Theme.fontMono)
                        .foregroundColor(Theme.textSecondary)
                    Text("Add a key with the button above or ⌘⇧K")
                        .font(Theme.fontMonoSmall)
                        .foregroundColor(Theme.textMuted)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(vm.filteredEntries) { entry in
                    let provider = vm.provider(for: entry)
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(vm.providerName(for: entry))
                                    .font(Theme.fontMonoSmall)
                                    .foregroundColor(Theme.accent)
                                Text(entry.alias)
                                    .font(Theme.fontMono)
                            }
                            if !entry.tags.isEmpty {
                                HStack(spacing: 4) {
                                    ForEach(entry.tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption2)
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 1)
                                            .background(Theme.accentSubtle)
                                            .cornerRadius(3)
                                    }
                                }
                            }
                        }

                        Spacer()

                        Text(vm.revealedKeyIDs.contains(entry.id) ? entry.apiKey : KeyMasking.mask(entry.apiKey))
                            .font(Theme.fontMonoSmall)
                            .foregroundColor(Theme.textSecondary)
                            .textSelection(.enabled)

                        // Actions
                        Button { Task { await vm.revealKey(id: entry.id) } } label: {
                            Image(systemName: vm.revealedKeyIDs.contains(entry.id) ? "eye.slash" : "eye")
                        }
                        .buttonStyle(.borderless)
                        .help("Reveal key")

                        Button { Task { await vm.copyKey(entry) } } label: {
                            Image(systemName: "doc.on.doc")
                        }
                        .buttonStyle(.borderless)
                        .help("Copy key")

                        if let p = provider {
                            Button { onPlayground(entry, p) } label: {
                                Image(systemName: "play.fill")
                            }
                            .buttonStyle(.borderless)
                            .help("Open in Playground")
                        }

                        if let url = provider?.dashboardURL, let link = URL(string: url) {
                            Link(destination: link) {
                                Image(systemName: "arrow.up.right.square")
                            }
                            .help("Open dashboard")
                        }

                        Button { onEdit?(entry) } label: {
                            Image(systemName: "pencil")
                        }
                        .buttonStyle(.borderless)
                        .help("Edit key")

                        Button { Task { await vm.deleteEntry(id: entry.id) } } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.borderless)
                        .foregroundColor(Theme.danger)
                        .help("Delete key")
                    }
                }
            }

            Divider()
            HStack {
                Text("\(vm.filteredEntries.count) keys · \(vm.providers.count) providers")
                    .font(Theme.fontMonoSmall)
                    .foregroundColor(Theme.textMuted)
                Spacer()
                Text("⌘⇧K quick save")
                    .font(Theme.fontMonoSmall)
                    .foregroundColor(Theme.textMuted)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
        }
        .task { await vm.load() }
    }
}
