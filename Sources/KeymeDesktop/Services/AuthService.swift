import LocalAuthentication

protocol AuthServiceProtocol {
    func authenticate(reason: String) async -> Bool
}

final class AuthService: AuthServiceProtocol {
    func authenticate(reason: String) async -> Bool {
        let context = LAContext()
        var error: NSError?
        let policy: LAPolicy = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
            ? .deviceOwnerAuthenticationWithBiometrics
            : .deviceOwnerAuthentication
        guard context.canEvaluatePolicy(policy, error: &error) else { return false }
        do { return try await context.evaluatePolicy(policy, localizedReason: reason) }
        catch { return false }
    }
}

final class MockAuthService: AuthServiceProtocol {
    var shouldSucceed = true
    func authenticate(reason: String) async -> Bool { shouldSucceed }
}
