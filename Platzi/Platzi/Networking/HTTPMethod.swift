import Foundation

/// Os verbos HTTP que a API aceita.
/// O `rawValue` (ex.: "GET") é o texto que vai direto na URLRequest.
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
