import Foundation
import Observation

@MainActor
@Observable
class PlatziStore {
    let httpClient: HTTPClient
    var categories: [Category] = []
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func loadCategories() async throws {
        let resource = Resource(url: Constants.Urls.categories, modelType: [Category].self)
        categories = try await httpClient.load(resource)
    }
}
