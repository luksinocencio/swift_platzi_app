import Foundation

struct CreateProductRequest: Codable {
    let title: String
    let price: Double
    let description: String
    let categoryId: Int
    let images: [URL]
}
