import Foundation
import AppKit

@MainActor
final class KeyListViewModel: ObservableObject {
    @Published var providers: [Provider] = []
    @Published var entries: [KeyEntry] = []
    @Published var searchQuery = ""
    @Published var selectedProviderID: UUID?
    @Published var revealedKeyIDs: Set<UUID> = []

    private let providerRepo: ProviderRepository
    private let keyRepo: KeyEntryRepository
    private let authService: AuthServiceProtocol

    init(providerRepo: ProviderRepository, keyRepo: KeyEntryRepository, authService: AuthServiceProtocol) {
        self.providerRepo = providerRepo
        self.keyRepo = keyRepo
        self.authService = authService
    }

    var filteredEntries: [KeyEntry] {
        var result = entries
        if let id = selectedProviderID { result = result.filter { $0.providerID == id } }
        if !searchQuery.isEmpty {
            let q = searchQuery.lowercased()
            result = result.filter { $0.alias.lowercased().contains(q) || $0.tags.contains(where: { $0.lowercased().contains(q) }) }
        }
        return result
    }

    func load() async {
        providers = (try? providerRepo.fetchAll()) ?? []
        entries = (try? keyRepo.fetchAll()) ?? []
    }

    func revealKey(id: UUID) async {
        guard await authService.authenticate(reason: "API 키를 조회하려면 인증이 필요합니다") else { return }
        revealedKeyIDs.insert(id)
        Task { try? await Task.sleep(for: .seconds(30)); revealedKeyIDs.remove(id) }
    }

    func copyKey(_ entry: KeyEntry) async {
        guard await authService.authenticate(reason: "API 키를 복사하려면 인증이 필요합니다") else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(entry.apiKey, forType: .string)
    }

    func deleteEntry(id: UUID) async {
        try? keyRepo.delete(id: id)
        await load()
    }

    func providerName(for entry: KeyEntry) -> String {
        providers.first(where: { $0.id == entry.providerID })?.name ?? "Unknown"
    }

    func provider(for entry: KeyEntry) -> Provider? {
        providers.first(where: { $0.id == entry.providerID })
    }
}
