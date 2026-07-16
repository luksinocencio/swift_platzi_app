import Foundation

struct RegistrationResponse: Codable {
    let email: String
    let password: String
    let name: String
    let avatar: URL
    let role: String
    let id: Int
}
