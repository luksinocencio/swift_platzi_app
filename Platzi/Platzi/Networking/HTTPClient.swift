import Foundation

struct HTTPClient {
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
