import SwiftUI

/// Serviço de autenticação: login, registro, sessão e logout.
/// Os tokens ficam no Keychain; a flag de sessão fica no UserDefaults (@AppStorage).
struct AuthenticationService {
    let httpClient: HTTPClient

    init(httpClient: HTTPClient = HTTPClient()) {
        self.httpClient = httpClient
    }

    /// Verifica se o usuário ainda tem uma sessão válida ao abrir o app.
    /// Se o accessToken expirou, tenta renovar com o refreshToken.
    func checkAuthentication() async -> Bool {
        guard let accessToken: String = Keychain.get(Constants.Keys.accessToken) else {
            return false // nunca logou ou fez sign out
        }

        if JWTDecoder.isExpired(token: accessToken) {
            do {
                try await httpClient.refreshToken()
                return true
            } catch {
                return false // renovação falhou: precisa logar de novo
            }
        }

        return true
    }

    /// Faz login e guarda os tokens no Keychain. (POST /auth/login)
    func login(email: String, password: String) async throws -> Bool {
        let request = LoginRequest(email: email, password: password)
        let resource = Resource(
            url: Constants.Urls.login,
            method: .post,
            body: try request.encode(),
            modelType: LoginResponse.self
        )
        let response = try await httpClient.load(resource)

        // Guarda os tokens para as próximas chamadas autenticadas.
        Keychain.set(response.accessToken, forKey: Constants.Keys.accessToken)
        Keychain.set(response.refreshToken, forKey: Constants.Keys.refreshToken)

        return true
    }

    /// Cria uma conta nova e retorna os dados do usuário criado. (POST /users)
    func register(name: String, email: String, password: String) async throws -> RegistrationResponse {
        let request = RegistrationRequest(name: name, email: email, password: password, avatar: URL(string: "https://picsum.photos/800")!)
        let resource = Resource(
            url: Constants.Urls.register,
            method: .post,
            body: try request.encode(),
            modelType: RegistrationResponse.self
        )
        return try await httpClient.load(resource)
    }

    /// Encerra a sessão: apaga a flag de autenticação e os tokens.
    func signOut() {
        UserDefaults.standard.removeObject(forKey: Constants.Keys.isAuthenticated)
        let _ = Keychain<String>.delete(Constants.Keys.accessToken)
        let _ = Keychain<String>.delete(Constants.Keys.refreshToken)
    }
}
