import SwiftUI

struct AddProductScreen: View {
    @State private var viewModel: AddProductViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(ErrorState.self) private var errorState

    let onSave: (Product) -> Void

    init(selectedCategory: Int, onSave: @escaping (Product) -> Void) {
        _viewModel = State(initialValue: AddProductViewModel(selectedCategoryId: selectedCategory))
        self.onSave = onSave
    }

    private func saveProduct() async {
        do {
            guard let product = try await viewModel.saveProduct() else { return }
            onSave(product)
            dismiss()
        } catch {
            errorState.error = error
        }
    }

    var body: some View {
        Form {
            Picker("Select a category", selection: $viewModel.selectedCategoryId) {
                ForEach(viewModel.categories) { category in
                    Text(category.name)
                        .tag(category.id)
                }
            }.pickerStyle(.automatic)

            TextField("Title", text: $viewModel.title)
            TextField("Price", value: $viewModel.price, format: .number)
                .keyboardType(.decimalPad)
            TextEditor(text: $viewModel.description)
                .frame(height: 100)

        }
        .task {
            do {
                try await viewModel.loadCategories()
            } catch {
                errorState.error = error
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Save Product") {
                    Task { await saveProduct() }
                }.disabled(!viewModel.isFormValid || viewModel.isLoading)
            }
        })
        .navigationTitle("Add Product")
        .padding(.top)
    }
}

#Preview {
    NavigationStack {
        AddProductScreen(selectedCategory: 87, onSave: { _ in })
    }
    .environment(ErrorState())
}
