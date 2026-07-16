import Foundation
import Observation

@MainActor
@Observable
class ProductListViewModel {
    let category: Category
    var products: [Product] = []
    var isLoading: Bool = false

    private let service: PlatziService

    init(category: Category, service: PlatziService = PlatziService()) {
        self.category = category
        self.service = service
    }

    func loadProducts() async throws {
        guard !isLoading else { return }

        isLoading = true
        defer { isLoading = false }

        products = try await service.fetchProductsBy(category.id)
    }

    func deleteProducts(at indexSet: IndexSet) async throws {
        for index in indexSet {
            let product = products[index]
            let isDeleted = try await service.deleteProduct(product.id)
            if isDeleted {
                products.removeAll { $0.id == product.id }
            }
        }
    }

    func add(_ product: Product) {
        products.append(product)
    }
}
