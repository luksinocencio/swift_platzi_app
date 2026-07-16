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
    
    func createCategory(name: String) async throws {
        let createCategoryRequest = CreateCategoryRequest(name: name, image: URL.randomImageURL)
        let resource = Resource(
            url: Constants.Urls.createCategory,
            method: .post(try createCategoryRequest.encode()),
            modelType: Category.self
        )
        
        let category = try await httpClient.load(resource)
        categories.append(category)
    }
}
