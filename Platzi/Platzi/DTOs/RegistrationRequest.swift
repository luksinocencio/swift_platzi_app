import Foundation

struct RegistrationRequest: Codable {
    let name: String
    let email: String
    let password: String
    let avatar: URL
}
