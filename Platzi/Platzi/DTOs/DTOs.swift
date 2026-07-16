import Foundation

struct RefreshTokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

struct RegistrationResponse: Codable {
    let email: String
    let password: String
    let name: String
    let avatar: URL
    let role: String
    let id: Int
}

struct RegistrationRequest: Codable {
    let name: String
    let email: String
    let password: String
    let avatar: URL
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let accessToken: String
    let refreshToken: String
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

struct ErrorResponse: Codable {
    let message: String?
}

struct Category: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let image: URL
}

struct CreateCategoryRequest: Codable {
    let name: String
    let image: URL
}

struct Product: Codable, Identifiable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let images: [URL]
}

extension Product {
    static var preview: Product {
        Product(
            id: 1,
            title: "Handmade Fresh Table",
            price: 687.0,
            description: "Andy shoes are designed to keep in comfort and style. Perfect for your next dinner party or client meeting",
            images: [
                URL(string: "https://placehold.co/600x400")!,
                URL(string: "https://placehold.co/600x400")!,
                URL(string: "https://placehold.co/600x400")!,
            ]
        )
    }
}
