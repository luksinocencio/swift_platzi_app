import Foundation

// MARK: - Localizações

extension PlatziService {

    /// Busca todas as localizações para o mapa. (GET /locations)
    func loadLocations() async throws -> [Location] {
        let resource = Resource(url: Constants.Urls.locations, modelType: [Location].self)
        return try await httpClient.load(resource)
    }
}
