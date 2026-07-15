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
            return try await performRequest(resource)
        } catch NetworkError.unauthorized {
            // attempt to refresh the token
            do {
                try await refreshToken()
                return try await performRequest(resource)
            } catch {
                throw NetworkError.unauthorized
            }
        }
    }
    
    private func performRequest<T: Codable>(_ resource: Resource<T>) async throws -> T {
        
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
            for (key, value) in headers {
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
    
    func refreshToken() async throws {
        
        guard let refreshToken = Keychain<String>.get("refreshToken") else {
            throw NetworkError.unauthorized
        }
        
        let body = try JSONEncoder().encode(["refreshToken": refreshToken])
        let resource = Resource(url: Constants.Urls.refreshToken, method: .post(body), modelType: RefreshTokenResponse.self)
        
        let response = try await performRequest(resource)
        
        Keychain.set(response.accessToken, forKey: "accessToken")
        Keychain.set(response.refreshToken, forKey: "refreshToken")
    }
}

