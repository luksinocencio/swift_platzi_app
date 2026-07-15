import SwiftUI

struct AuthenticationController {
    let httpClient: HTTPClient
    
    func register(name: String, email: String, password: String) async throws -> RegistrationResponse {
        let request = RegistrationRequest(name: name, email: email, password: password, avatar: URL(string: "https://picsum.photos/800")!)
        let resource = Resource(url: Constants.Urls.register, method: .post(try request.encode()), modelType: RegistrationResponse.self)
        let response = try await httpClient.load(resource)
        return response
    }
    
    func login(email: String, password: String) async throws -> Bool {
        let request = LoginRequest(email: email, password: password)
        let resource = Resource(url: Constants.Urls.login, method: .post(try request.encode()), modelType: LoginResponse.self)
        let response = try await httpClient.load(resource)
        
        print(response.accessToken)
        print(response.refreshToken)
        
        // save the access and refresh token in Keychain
        Keychain.set(response.accessToken, forKey: "accessToken")
        Keychain.set(response.refreshToken, forKey: "refreshToken")
        
        return true
    }
}

