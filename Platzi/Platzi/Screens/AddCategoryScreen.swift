import SwiftUI

struct AddCategoryScreen: View {
    @State private var viewModel = AddCategoryViewModel()

    @Environment(\.dismiss) private var dismiss
    @Environment(ErrorState.self) private var errorState

    let onSave: (Category) -> Void

    private func createCategory() async {
        do {
            let category = try await viewModel.createCategory()
            onSave(category)
            dismiss()
        } catch {
            errorState.error = error
        }
    }

    var body: some View {
        Form {
            TextField("Name", text: $viewModel.name)
        }.toolbar {
            ToolbarItem {
                Button("Save") {
                    Task { await createCategory() }
                }.disabled(!viewModel.isFormValid || viewModel.isLoading)
            }
        }
        .navigationTitle("Add Category")
    }
}

#Preview {
    NavigationStack {
        AddCategoryScreen(onSave: { _ in })
    }
    .environment(ErrorState())
}
