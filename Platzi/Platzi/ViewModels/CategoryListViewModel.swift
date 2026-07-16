import Foundation
import Observation

@MainActor
@Observable
class CategoryListViewModel {
    var categories: [Category] = []
    var isLoading: Bool = false

    private let service: PlatziService

    init(service: PlatziService = PlatziService()) {
        self.service = service
    }

    func loadCategories() async throws {
        isLoading = true
        defer { isLoading = false }
        categories = try await service.loadCategories()
    }

    func add(_ category: Category) {
        categories.append(category)
    }
}
