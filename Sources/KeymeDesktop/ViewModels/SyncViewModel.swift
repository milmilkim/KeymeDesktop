import Foundation

@MainActor
final class SyncViewModel: ObservableObject {
    @Published var isRunning = false
    @Published var pairingCode: String?
    @Published var connectedDevice: String?
    private let server: SyncServer

    init(server: SyncServer) { self.server = server }

    func startServer() {
        try? server.start(); isRunning = true
    }

    func stopServer() {
        server.stop(); isRunning = false
    }

    func showPairingCode() {
        pairingCode = server.generatePairingCode()
    }
}
