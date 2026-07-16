import Foundation
import Observation

@MainActor
@Observable
class AddCategoryViewModel {
    var name: String = ""
    var isLoading: Bool = false

    private let service: PlatziService

    init(service: PlatziService = PlatziService()) {
        self.service = service
    }

    var isFormValid: Bool {
        !name.isEmptyOrWhitespace
    }

    func createCategory() async throws -> Category {
        isLoading = true
        defer { isLoading = false }
        return try await service.createCategory(name: name)
    }
}
