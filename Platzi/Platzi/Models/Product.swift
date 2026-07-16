import Foundation

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
