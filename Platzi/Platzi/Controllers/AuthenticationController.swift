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
}

