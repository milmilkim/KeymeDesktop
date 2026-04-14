import Foundation
import AppKit

@MainActor
final class QuickSaveViewModel: ObservableObject {
    @Published var providers: [Provider] = []
    @Published var detectedKey = ""
    @Published var selectedProviderID: UUID?
    @Published var alias = ""
    @Published var tags = ""
    @Published var isSaved = false

    private let providerRepo: ProviderRepository
    let keyRepo: KeyEntryRepository

    init(providerRepo: ProviderRepository, keyRepo: KeyEntryRepository) {
        self.providerRepo = providerRepo
        self.keyRepo = keyRepo
    }

    func load() async {
        providers = (try? providerRepo.fetchAll()) ?? []
        selectedProviderID = providers.first?.id
        // 클립보드에서 API 키 자동 감지
        if let content = NSPasteboard.general.string(forType: .string),
           KeyMasking.looksLikeAPIKey(content.trimmingCharacters(in: .whitespacesAndNewlines)) {
            detectedKey = content.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    func reset() {
        detectedKey = ""
        alias = ""
        tags = ""
        isSaved = false
        selectedProviderID = providers.first?.id
    }
}
