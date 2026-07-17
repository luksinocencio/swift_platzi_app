import Foundation

/// Cliente HTTP genérico: executa qualquer `Resource` e devolve o modelo já decodificado.
///
/// Fluxo de uma chamada:
/// 1. `load` chama `performRequest`.
/// 2. Se a API responder 401 (token expirado), renova o token e repete UMA vez.
/// 3. `performRequest` monta a URLRequest, executa, valida o status e decodifica o JSON.
struct HTTPClient {

    private let session: URLSession

    init() {
        // Toda requisição desta sessão envia JSON por padrão.
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Content-Type": "application/json"]
        self.session = URLSession(configuration: configuration)
    }

    /// Ponto de entrada público. Executa o resource e, se o token de acesso
    /// tiver expirado (401), renova e tenta de novo automaticamente.
    func load<T: Codable>(_ resource: Resource<T>) async throws -> T {
        do {
            return try await performRequest(resource)
        } catch NetworkError.unauthorized {
            // 401: o accessToken expirou. Renova com o refreshToken e repete a chamada.
            do {
                try await refreshToken()
                return try await performRequest(resource)
            } catch {
                // A renovação também falhou: o usuário precisa logar de novo.
                throw NetworkError.unauthorized
            }
        }
    }

    /// Renova o accessToken usando o refreshToken guardado no Keychain.
    func refreshToken() async throws {
        guard let refreshToken = Keychain<String>.get(Constants.Keys.refreshToken) else {
            throw NetworkError.unauthorized
        }

        let body = try JSONEncoder().encode(["refreshToken": refreshToken])
        let resource = Resource(
            url: Constants.Urls.refreshToken,
            method: .post,
            body: body,
            modelType: RefreshTokenResponse.self
        )

        let response = try await performRequest(resource)

        // Guarda os novos tokens para as próximas chamadas.
        Keychain.set(response.accessToken, forKey: Constants.Keys.accessToken)
        Keychain.set(response.refreshToken, forKey: Constants.Keys.refreshToken)
    }

    // MARK: - Passos internos

    /// Monta a URLRequest a partir do resource: URL + query, verbo, corpo, token e headers.
    private func makeRequest<T>(for resource: Resource<T>) throws -> URLRequest {
        // 1. Anexa os query items à URL (se houver).
        var url = resource.url
        if !resource.queryItems.isEmpty {
            var components = URLComponents(url: resource.url, resolvingAgainstBaseURL: false)
            components?.queryItems = resource.queryItems
            guard let urlWithQuery = components?.url else {
                throw NetworkError.badRequest
            }
            url = urlWithQuery
        }

        var request = URLRequest(url: url)

        // 2. Define o verbo (GET, POST...) e o corpo JSON.
        request.httpMethod = resource.method.rawValue
        request.httpBody = resource.body

        // 3. Se o usuário estiver logado, envia o token de acesso.
        if let token = Keychain<String>.get(Constants.Keys.accessToken) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // 4. Headers extras definidos no resource.
        if let headers = resource.headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        return request
    }

    /// Executa a requisição, valida o status HTTP e decodifica o JSON no modelo esperado.
    private func performRequest<T: Codable>(_ resource: Resource<T>) async throws -> T {
        let request = try makeRequest(for: resource)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        // Converte códigos de erro HTTP em erros do app.
        switch httpResponse.statusCode {
        case 200..<300:
            break // sucesso — segue para a decodificação
        case 401:
            throw NetworkError.unauthorized
        case 404:
            throw NetworkError.notFound
        default:
            throw NetworkError.undefined(data, httpResponse)
        }

        // Transforma o JSON recebido no modelo Swift (ex.: [Category]).
        do {
            return try JSONDecoder().decode(resource.modelType, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
