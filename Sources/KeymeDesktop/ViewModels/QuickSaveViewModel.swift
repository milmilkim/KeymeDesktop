import Foundation
import SwiftUI
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
    private let keyRepo: KeyEntryRepository
    private let clipboardMonitor: ClipboardMonitor

    init(providerRepo: ProviderRepository, keyRepo: KeyEntryRepository, clipboardMonitor: ClipboardMonitor) {
        self.providerRepo = providerRepo
        self.keyRepo = keyRepo
        self.clipboardMonitor = clipboardMonitor
    }

    func load() async {
        providers = (try? providerRepo.fetchAll()) ?? []
        selectedProviderID = providers.first?.id
        if let content = NSPasteboard.general.string(forType: .string),
           KeyMasking.looksLikeAPIKey(content.trimmingCharacters(in: .whitespacesAndNewlines)) {
            detectedKey = content.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    func save() async throws {
        guard let providerID = selectedProviderID, !detectedKey.isEmpty else { return }
        let parsedTags = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        let entry = KeyEntry(providerID: providerID, alias: alias.isEmpty ? "Untitled" : alias, apiKey: detectedKey, tags: parsedTags)
        try keyRepo.save(entry)
        isSaved = true
    }

    func reset() {
        detectedKey = ""
        alias = ""
        tags = ""
        isSaved = false
        selectedProviderID = providers.first?.id
    }
}
