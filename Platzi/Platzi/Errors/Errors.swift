import Foundation

enum NetworkError: Error {
    case badRequest
    case decodingError(Error)
    case invalidResponse
    case unauthorized
    case notFound
    case undefined(Data, HTTPURLResponse)
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .badRequest:
            return NSLocalizedString("Bad Request (400): Unable to perform the request.", comment: "badRequestError")
        case .decodingError(let error):
            return NSLocalizedString("Unable to decode successfully. \(error)", comment: "decodingError")
        case .invalidResponse:
            return NSLocalizedString("Invalid response.", comment: "invalidResponse")
        case .unauthorized:
            return NSLocalizedString("Unauthorized credentials.", comment: "authorizationError")
        case .notFound:
            return NSLocalizedString("Resource not found (404).", comment: "notFoundError")
        case .undefined(let data, let response):
            if let decoded = try? JSONDecoder().decode(ErrorResponse.self, from: data),
               let message = decoded.message {
                return message
            } else {
                return "An unexpected error occurred. Status code: \(response.statusCode)"
            }
        }
    }
}
