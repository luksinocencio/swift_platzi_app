import SwiftUI

struct AuthenticationController {
    let httpClinet: HTTPClient
    
    func register(name: String, email: String, password: String) async throws -> RegistrationResponse {
        let registrationRespnse = try await httpClinet.register(
            name: name,
            email: email,
            password: password,
            avatar: URL(string: "https://picsum.photos/800")!
        )
        
        return registrationRespnse
    }
    
    func login(email: String, password: String) async throws -> Bool {
        let loginResponse = try await httpClinet.login(email: email, password: password)
        
        print("accessToken: \(loginResponse.accessToken)")
        print("refreshToken: \(loginResponse.refreshToken)")
        
        // save the access tokens on keychain
        Keychain.set(loginResponse.accessToken, forKey: "accessToken")
        Keychain.set(loginResponse.refreshToken, forKey: "refreshToken")
        
        return true
    }
}

