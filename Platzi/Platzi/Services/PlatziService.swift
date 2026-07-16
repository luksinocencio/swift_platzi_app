import Foundation

/// Stateless data layer for the Platzi API. ViewModels own the state;
/// this service only performs requests and returns values.
struct PlatziService {
    let httpClient: HTTPClient

    init(httpClient: HTTPClient = HTTPClient()) {
        self.httpClient = httpClient
    }

    func loadCategories() async throws -> [Category] {
        let resource = Resource(url: Constants.Urls.categories, modelType: [Category].self)
        return try await httpClient.load(resource)
    }

    func createCategory(name: String) async throws -> Category {
        let createCategoryRequest = CreateCategoryRequest(name: name, image: URL.randomImageURL)
        let resource = Resource(
            url: Constants.Urls.createCategory,
            method: .post(try createCategoryRequest.encode()),
            modelType: Category.self
        )
        return try await httpClient.load(resource)
    }

    func fetchProductsBy(_ categoryId: Int) async throws -> [Product] {
        let resource = Resource(url: Constants.Urls.getProductsByCategory(categoryId), modelType: [Product].self)
        return try await httpClient.load(resource)
    }

    func createProduct(title: String, price: Double, description: String, categoryId: Int, images: [URL]) async throws -> Product {
        let createProductRequest = CreateProductRequest(title: title, price: price, description: description, categoryId: categoryId, images: images)
        let resource = Resource(url: Constants.Urls.createProduct, method: .post(try createProductRequest.encode()), modelType: Product.self)
        return try await httpClient.load(resource)
    }

    func deleteProduct(_ productId: Int) async throws -> Bool {
        let resource = Resource(url: Constants.Urls.deleteProduct(productId), method: .delete, modelType: Bool.self)
        return try await httpClient.load(resource)
    }

    func loadLocations() async throws -> [Location] {
        let resource = Resource(url: Constants.Urls.locations, modelType: [Location].self)
        return try await httpClient.load(resource)
    }
}
