import Foundation

struct HTTPHeader: Identifiable, Equatable {
    let id = UUID()
    var key: String
    var value: String
}

@MainActor
final class PlaygroundViewModel: ObservableObject {
    @Published var url = ""
    @Published var method = "POST"
    @Published var headers: [HTTPHeader] = []
    @Published var body = ""
    @Published var responseStatus = ""
    @Published var responseHeaders = ""
    @Published var responseBody = ""
    @Published var isLoading = false

    let methods = ["GET", "POST", "PUT", "DELETE", "PATCH"]

    func selectEntry(_ entry: KeyEntry, provider: Provider) {
        url = "\(provider.baseURL)/chat/completions"
        headers = [
            HTTPHeader(key: "Authorization", value: "Bearer \(entry.apiKey)"),
            HTTPHeader(key: "Content-Type", value: "application/json"),
        ]
        let model = entry.models?.first ?? "gpt-3.5-turbo"
        body = """
        {
          "model": "\(model)",
          "messages": [
            {"role": "user", "content": "Hello"}
          ]
        }
        """
    }

    func send() async {
        guard let requestURL = URL(string: url) else { return }
        isLoading = true
        defer { isLoading = false }

        var request = URLRequest(url: requestURL)
        request.httpMethod = method
        for h in headers where !h.key.isEmpty { request.setValue(h.value, forHTTPHeaderField: h.key) }
        if !body.isEmpty && method != "GET" { request.httpBody = body.data(using: .utf8) }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse {
                responseStatus = "\(http.statusCode)"
                responseHeaders = http.allHeaderFields.map { "\($0.key): \($0.value)" }.sorted().joined(separator: "\n")
            }
            if let json = try? JSONSerialization.jsonObject(with: data),
               let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let str = String(data: pretty, encoding: .utf8) {
                responseBody = str
            } else {
                responseBody = String(data: data, encoding: .utf8) ?? "(binary)"
            }
        } catch {
            responseStatus = "ERROR"
            responseBody = error.localizedDescription
        }
    }
}
