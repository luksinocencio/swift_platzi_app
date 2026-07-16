import Foundation
import Observation

@MainActor
@Observable
class LoginViewModel {
    var email: String = "johndoe@gmail.com"
    var password: String = "password1234"
    var isLoading: Bool = false

    private let authenticationController: AuthenticationController

    init(authenticationController: AuthenticationController = AuthenticationController(httpClient: HTTPClient())) {
        self.authenticationController = authenticationController
    }

    var isFormValid: Bool {
        !email.isEmptyOrWhitespace && !password.isEmptyOrWhitespace
    }

    func login() async throws -> Bool {
        isLoading = true
        defer { isLoading = false }
        return try await authenticationController.login(email: email, password: password)
    }
}
