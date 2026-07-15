import Foundation

struct HTTPClient {
    private let session: URLSession
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Content-Type": "application/json"]
        self.session = URLSession(configuration: configuration)
    }
    
    func load<T: Codable>(_ resource: Resource<T>) async throws -> T {
        do {
            return try await perfomeRequest(resource)
        } catch {
            throw NetworkError.invalidResponse
        }
    }
    
    private func perfomeRequest<T: Codable>(_ resource: Resource<T>) async throws -> T {
        var request = URLRequest(url: resource.url)
        
        switch resource.method {
        case .get(let queryItems):
            var components = URLComponents(url: resource.url, resolvingAgainstBaseURL: false)
            components?.queryItems = queryItems
            guard let url = components?.url else {
                throw NetworkError.badRequest
            }
            request.url = url
        case .post(let data), .put(let data):
            request.httpMethod = resource.method.name
            request.httpBody = data
        case .delete:
            request.httpMethod = resource.method.name
        }
        
        // add authorization header // accessToken
        if let token = Keychain<String>.get("accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let headers = resource.headers {
            for(key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            break
        case 401:
            throw NetworkError.unauthorized
        case 404:
            throw NetworkError.notFound
        default:
            throw NetworkError.undefined(data, httpResponse)
        }
        
        do {
            return try JSONDecoder().decode(resource.modelType, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    func register(
        name: String,
        email: String,
        password: String,
        avatar: URL
    ) async throws -> RegistrationResponse {
        let registationRequest = RegistrationRequest(name: name, email: email, password: password, avatar: avatar)
        
        var request = URLRequest(url: Constants.Urls.register)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(registationRequest)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let registrationResponse = try JSONDecoder().decode(RegistrationResponse.self, from: data)
        
        return registrationResponse
    }
    
    func login(email: String, password: String) async throws -> LoginResponse {
        let loginRequest = LoginRequest(email: email, password: password)
        
        var request = URLRequest(url: Constants.Urls.login)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(loginRequest)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        return loginResponse
    }
}
