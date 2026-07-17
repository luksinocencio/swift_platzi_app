import Foundation

// MARK: - Categorias

extension PlatziService {

    /// Busca todas as categorias. (GET /categories)
    func loadCategories() async throws -> [Category] {
        let resource = Resource(url: Constants.Urls.categories, modelType: [Category].self)
        return try await httpClient.load(resource)
    }

    /// Cria uma categoria nova e retorna a categoria criada pela API. (POST /categories)
    func createCategory(name: String) async throws -> Category {
        let request = CreateCategoryRequest(name: name, image: URL.randomImageURL)
        let resource = Resource(
            url: Constants.Urls.createCategory,
            method: .post,
            body: try request.encode(),
            modelType: Category.self
        )
        return try await httpClient.load(resource)
    }
}
