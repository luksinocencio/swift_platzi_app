import SwiftUI

struct AuthenticationController {
    let httpClient: HTTPClient
    
    func checkAuthentication() async -> Bool {
        guard let accessToken: String = Keychain.get(Constants.Keys.accessToken) else {
            return false
        }
        
        // check if access token is expired
        if JWTDecoder.isExpired(token: accessToken) {
            do {
                try await httpClient.refreshToken()
                return true
            } catch {
                return false
            }
        }
        
        return true
    }
    
    func login(email: String, password: String) async throws -> Bool {
        let request = LoginRequest(email: email, password: password)
        let resource = Resource(url: Constants.Urls.login, method: .post(try request.encode()), modelType: LoginResponse.self)
        let response = try await httpClient.load(resource)

        // save the access and refresh token in Keychain
        Keychain.set(response.accessToken, forKey: Constants.Keys.accessToken)
        Keychain.set(response.refreshToken, forKey: Constants.Keys.refreshToken)
        
        return true
    }
    
    func register(name: String, email: String, password: String) async throws -> RegistrationResponse {
        let request = RegistrationRequest(name: name, email: email, password: password, avatar: URL(string: "https://picsum.photos/800")!)
        let resource = Resource(url: Constants.Urls.register, method: .post(try request.encode()), modelType: RegistrationResponse.self)
        let response = try await httpClient.load(resource)
        return response
    }
    
    func signOut() {
        UserDefaults.standard.removeObject(forKey: Constants.Keys.isAuthenticated)
        let _ = Keychain<String>.delete(Constants.Keys.accessToken)
        let _ = Keychain<String>.delete(Constants.Keys.refreshToken)
    }
}

