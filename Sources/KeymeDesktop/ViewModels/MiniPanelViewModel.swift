import Foundation
import AppKit

@MainActor
final class MiniPanelViewModel: ObservableObject {
    @Published var providers: [Provider] = []
    @Published var recentEntries: [KeyEntry] = []
    @Published var searchQuery = ""

    private let providerRepo: ProviderRepository
    private let keyRepo: KeyEntryRepository
    private let authService: AuthServiceProtocol

    init(providerRepo: ProviderRepository, keyRepo: KeyEntryRepository, authService: AuthServiceProtocol) {
        self.providerRepo = providerRepo
        self.keyRepo = keyRepo
        self.authService = authService
    }

    var filteredEntries: [KeyEntry] {
        guard !searchQuery.isEmpty else { return recentEntries }
        let q = searchQuery.lowercased()
        return recentEntries.filter {
            $0.alias.lowercased().contains(q) || $0.tags.contains(where: { $0.lowercased().contains(q) })
        }
    }

    func load() async {
        providers = (try? providerRepo.fetchAll()) ?? []
        recentEntries = (try? keyRepo.fetchAll())?.suffix(10).reversed() ?? []
    }

    func providerName(for entry: KeyEntry) -> String {
        providers.first(where: { $0.id == entry.providerID })?.name ?? "Unknown"
    }

    func copyKey(_ entry: KeyEntry) async {
        guard await authService.authenticate(reason: "API 키를 복사하려면 인증이 필요합니다") else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(entry.apiKey, forType: .string)
    }
}
