import Foundation
import Observation

@MainActor
@Observable
class RegistrationViewModel {
    var name: String = "John Doe"
    var email: String = "johndoe@gmail.com"
    var password: String = "password1234"
    var isLoading: Bool = false
    var successMessage: String?

    private let authenticationController: AuthenticationController

    init(authenticationController: AuthenticationController = AuthenticationController(httpClient: HTTPClient())) {
        self.authenticationController = authenticationController
    }

    var isFormValid: Bool {
        validate().isEmpty
    }

    func validate() -> [String] {

        var errors: [String] = []

        if name.isEmptyOrWhitespace {
            errors.append("Name cannot be empty.")
        }

        if email.isEmptyOrWhitespace {
            errors.append("Email cannot be empty.")
        }

        if password.isEmptyOrWhitespace {
            errors.append("Password cannot be empty.")
        }

        if !password.isValidPassword {
            errors.append("Password must be at least 8 characters long.")
        }

        if !email.isEmail {
            errors.append("Email must be in correct format.")
        }

        return errors
    }

    func register() async throws {
        isLoading = true
        defer { isLoading = false }
        let response = try await authenticationController.register(name: name, email: email, password: password)
        successMessage = "Registration for user \(response.name) is completed."
    }
}
