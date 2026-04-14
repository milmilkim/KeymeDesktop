import SwiftUI

struct MainContentView: View {
    @ObservedObject var keyListVM: KeyListViewModel
    @ObservedObject var playgroundVM: PlaygroundViewModel
    @ObservedObject var syncVM: SyncViewModel
    let providerRepo: ProviderRepository
    let keyRepo: KeyEntryRepository
    @State private var tab = 0
    @State private var showProviderForm = false
    @State private var showKeyForm = false
    @State private var editingEntry: KeyEntry?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Picker("", selection: $tab) {
                    Text("Keys").tag(0)
                    Text("Playground").tag(1)
                    Text("Sync").tag(2)
                    Text("Settings").tag(3)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 400)

                Spacer()

                Button {
                    editingEntry = nil
                    showKeyForm = true
                } label: {
                    Label("Add Key", systemImage: "key.fill")
                }
                .buttonStyle(.borderless)

                Button {
                    showProviderForm = true
                } label: {
                    Label("Add Provider", systemImage: "plus")
                }
                .buttonStyle(.borderless)
            }
            .padding(10)

            Divider()

            switch tab {
            case 0: KeyListView(vm: keyListVM, onPlayground: { entry, provider in
                playgroundVM.selectEntry(entry, provider: provider); tab = 1
            }, onEdit: { entry in
                editingEntry = entry
                showKeyForm = true
            })
            case 1: PlaygroundView(vm: playgroundVM)
            case 2: SyncView(vm: syncVM)
            case 3: SettingsView()
            default: EmptyView()
            }
        }
        .sheet(isPresented: $showProviderForm) {
            ProviderFormView { provider in
                try? providerRepo.save(provider)
                Task { await keyListVM.load() }
            }
        }
        .sheet(isPresented: $showKeyForm) {
            KeyFormView(
                providers: keyListVM.providers,
                keyRepo: keyRepo,
                editing: editingEntry
            ) {
                Task { await keyListVM.load() }
            }
        }
    }
}

// MARK: - Key 추가/편집 폼

struct KeyFormView: View {
    let providers: [Provider]
    let keyRepo: KeyEntryRepository
    let editing: KeyEntry?
    let onSaved: () -> Void
    @Environment(\.dismiss) var dismiss

    @State private var apiKey: String
    @State private var selectedProviderID: UUID?
    @State private var alias: String
    @State private var tags: String

    init(providers: [Provider], keyRepo: KeyEntryRepository, editing: KeyEntry?, onSaved: @escaping () -> Void) {
        self.providers = providers
        self.keyRepo = keyRepo
        self.editing = editing
        self.onSaved = onSaved
        // 편집 모드면 기존 값으로 초기화
        _apiKey = State(initialValue: editing?.apiKey ?? "")
        _selectedProviderID = State(initialValue: editing?.providerID ?? providers.first?.id)
        _alias = State(initialValue: editing?.alias ?? "")
        _tags = State(initialValue: editing?.tags.joined(separator: ", ") ?? "")
    }

    var isEditing: Bool { editing != nil }

    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            Text(isEditing ? "Edit Key" : "Add Key")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

            Form {
                TextField("API Key", text: $apiKey)
                    .font(Theme.fontMono)
                    .onChange(of: apiKey) { newValue in
                        autoDetectProvider(for: newValue)
                    }

                Picker("Provider", selection: $selectedProviderID) {
                    Text("Select...").tag(nil as UUID?)
                    ForEach(providers) { p in Text(p.name).tag(p.id as UUID?) }
                }

                TextField("Alias (optional)", text: $alias)

                TextField("Tags — comma separated (optional)", text: $tags)
                    .font(Theme.fontMonoSmall)
            }
            .formStyle(.grouped)

            // 버튼
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button(isEditing ? "Update" : "Save") {
                    saveEntry()
                }
                .disabled(apiKey.isEmpty || selectedProviderID == nil)
            }
            .padding()
        }
        .frame(width: 440, height: 340)
    }

    private func saveEntry() {
        guard let providerID = selectedProviderID, !apiKey.isEmpty else { return }
        let parsedTags = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }

        let finalAlias: String
        if alias.isEmpty {
            finalAlias = "Key \(Date().formatted(.dateTime.month().day().hour().minute()))"
        } else {
            finalAlias = alias
        }

        let entry: KeyEntry
        if let existing = editing {
            // 편집: 기존 ID 유지
            entry = KeyEntry(id: existing.id, providerID: providerID, alias: finalAlias, apiKey: apiKey, tags: parsedTags, createdAt: existing.createdAt)
        } else {
            entry = KeyEntry(providerID: providerID, alias: finalAlias, apiKey: apiKey, tags: parsedTags)
        }

        try? keyRepo.save(entry)
        onSaved()
        dismiss()
    }

    private func autoDetectProvider(for key: String) {
        // 유저가 이미 수동 선택했으면 건드리지 않음
        guard !isEditing else { return }
        guard let guessed = KeyMasking.guessProviderName(for: key) else { return }
        if let match = providers.first(where: { $0.name == guessed }) {
            selectedProviderID = match.id
        }
    }
}
