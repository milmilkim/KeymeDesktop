import Foundation

final class AppState: ObservableObject {
    let db: DatabaseManager
    let providerRepo: ProviderRepository
    let keyRepo: KeyEntryRepository
    let authService: AuthServiceProtocol

    init(inMemory: Bool = false) throws {
        db = try DatabaseManager(inMemory: inMemory)
        providerRepo = ProviderRepository(db: db)
        keyRepo = KeyEntryRepository(db: db)
        authService = AuthService()
    }

    init(db: DatabaseManager, authService: AuthServiceProtocol) {
        self.db = db
        self.providerRepo = ProviderRepository(db: db)
        self.keyRepo = KeyEntryRepository(db: db)
        self.authService = authService
    }
}
