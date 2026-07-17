import Foundation

// MARK: - Produtos

extension PlatziService {

    /// Busca os produtos de uma categoria. (GET /categories/{id}/products)
    func fetchProductsBy(_ categoryId: Int) async throws -> [Product] {
        let resource = Resource(url: Constants.Urls.getProductsByCategory(categoryId), modelType: [Product].self)
        return try await httpClient.load(resource)
    }

    /// Cria um produto novo e retorna o produto criado pela API. (POST /products)
    func createProduct(title: String, price: Double, description: String, categoryId: Int, images: [URL]) async throws -> Product {
        let request = CreateProductRequest(title: title, price: price, description: description, categoryId: categoryId, images: images)
        let resource = Resource(
            url: Constants.Urls.createProduct,
            method: .post,
            body: try request.encode(),
            modelType: Product.self
        )
        return try await httpClient.load(resource)
    }

    /// Apaga um produto. A API responde `true` quando deu certo. (DELETE /products/{id})
    func deleteProduct(_ productId: Int) async throws -> Bool {
        let resource = Resource(url: Constants.Urls.deleteProduct(productId), method: .delete, modelType: Bool.self)
        return try await httpClient.load(resource)
    }
}
