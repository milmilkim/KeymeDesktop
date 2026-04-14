import Foundation
import Network

final class SyncServer: ObservableObject {
    private var listener: NWListener?
    private let db: DatabaseManager
    @Published var isRunning = false
    @Published var pairingCode: String?
    @Published var connectedDeviceName: String?
    private var pairedDeviceIDs: Set<String> = []
    private var pendingCode: String?

    init(db: DatabaseManager) { self.db = db }

    func start() throws {
        let params = NWParameters.tcp
        params.includePeerToPeer = true
        listener = try NWListener(using: params, on: .any)
        listener?.service = NWListener.Service(name: "Keyme", type: "_keyme._tcp")
        listener?.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                self?.isRunning = (state == .ready)
            }
        }
        listener?.newConnectionHandler = { [weak self] conn in self?.handle(conn) }
        listener?.start(queue: .main)
    }

    func stop() { listener?.cancel(); listener = nil; isRunning = false }

    func generatePairingCode() -> String {
        let code = String(format: "%04d", Int.random(in: 0...9999))
        pendingCode = code; pairingCode = code
        return code
    }

    private func handle(_ conn: NWConnection) {
        conn.start(queue: .main)
        conn.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, _, _ in
            guard let self, let data else { return }
            self.process(data: data, conn: conn)
        }
    }

    private func process(data: Data, conn: NWConnection) {
        guard let req = try? JSONDecoder().decode(SyncRequest.self, from: data) else { conn.cancel(); return }
        switch req.type {
        case .pair:
            guard req.pairingCode == pendingCode else {
                send(SyncResponse(type: .error, message: "Invalid code"), on: conn); return
            }
            if let id = req.deviceID { pairedDeviceIDs.insert(id) }
            pendingCode = nil
            DispatchQueue.main.async { self.pairingCode = nil; self.connectedDeviceName = req.deviceName }
            send(SyncResponse(type: .paired, message: "OK"), on: conn)
        case .sync:
            guard let id = req.deviceID, pairedDeviceIDs.contains(id) else {
                send(SyncResponse(type: .error, message: "Not paired"), on: conn); return
            }
            DispatchQueue.main.async { self.connectedDeviceName = req.deviceName }
            let snapshot = try? db.exportSnapshot()
            send(SyncResponse(type: .snapshot, data: snapshot), on: conn)
        }
    }

    private func send(_ resp: SyncResponse, on conn: NWConnection) {
        guard let data = try? JSONEncoder().encode(resp) else { return }
        conn.send(content: data, completion: .contentProcessed { _ in conn.cancel() })
    }
}

struct SyncRequest: Codable {
    enum Kind: String, Codable { case pair, sync }
    let type: Kind
    var deviceID: String?
    var deviceName: String?
    var pairingCode: String?
}

struct SyncResponse: Codable {
    enum Kind: String, Codable { case paired, snapshot, error }
    let type: Kind
    var message: String?
    var data: Data?
}
