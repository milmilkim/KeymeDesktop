import SwiftUI

struct MiniPanelView: View {
    @ObservedObject var vm: MiniPanelViewModel
    let onOpenMain: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Search
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 11))
                    .foregroundColor(Theme.textSecondary)
                TextField("search...", text: $vm.searchQuery)
                    .font(.system(size: 11, design: .monospaced))
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Theme.bgPrimary)

            Divider().background(Theme.border)

            // Key list
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(vm.filteredEntries) { entry in
                        HStack {
                            VStack(alignment: .leading, spacing: 1) {
                                Text(vm.providerName(for: entry))
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundColor(Theme.accent)
                                Text(entry.alias)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(Theme.textPrimary)
                            }
                            Spacer()
                            Text(KeyMasking.mask(entry.apiKey))
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(Theme.textSecondary)
                            Button(action: { Task { await vm.copyKey(entry) } }) {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 11))
                                    .foregroundColor(Theme.textSecondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                        Divider().background(Theme.border).padding(.horizontal, 12)
                    }
                }
            }
            .frame(maxHeight: 280)

            // Footer
            Divider().background(Theme.border)
            HStack {
                Text("\(vm.recentEntries.count) keys")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(Theme.textMuted)
                Spacer()
                Button("Open Keyme →") { onOpenMain() }
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(Theme.accent)
                    .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .frame(width: 320)
        .background(Theme.bgPrimary)
        .task { await vm.load() }
    }
}
