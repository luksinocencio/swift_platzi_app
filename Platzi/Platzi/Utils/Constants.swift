import Foundation

struct Constants {
    struct Urls {
        static let register = URL(string: "https://api.escuelajs.co/api/v1/users")!
        static let login = URL(string: "https://api.escuelajs.co/api/v1/auth/login")!
        static let refreshToken = URL(string: "https://api.escuelajs.co/api/v1/auth/refresh-token")!
        static let categories = URL(string: "https://api.escuelajs.co/api/v1/categories")!
        static let createCategory = URL(string: "https://api.escuelajs.co/api/v1/categories/")!
        static func getProductsByCategory(_ categoryId: Int) -> URL {
            URL(string: "https://api.escuelajs.co/api/v1/categories/\(categoryId)/products")!
        }
    }
}
