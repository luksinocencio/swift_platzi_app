import Foundation
import Observation

@MainActor
@Observable
class AddProductViewModel {
    var title: String = ""
    var price: Double?
    var description: String = ""
    var selectedCategoryId: Int
    var categories: [Category] = []
    var isLoading: Bool = false

    private let service: PlatziService

    init(selectedCategoryId: Int, service: PlatziService = PlatziService()) {
        self.selectedCategoryId = selectedCategoryId
        self.service = service
    }

    var isFormValid: Bool {
        !title.isEmptyOrWhitespace && !description.isEmptyOrWhitespace && price != nil && price! > 0
    }

    func loadCategories() async throws {
        categories = try await service.loadCategories()
    }

    func saveProduct() async throws -> Product? {
        guard let price else { return nil }

        isLoading = true
        defer { isLoading = false }

        return try await service.createProduct(
            title: title,
            price: price,
            description: description,
            categoryId: selectedCategoryId,
            images: [URL.randomImageURL]
        )
    }
}
