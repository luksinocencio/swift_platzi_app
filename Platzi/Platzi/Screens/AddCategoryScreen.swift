import SwiftUI

struct AddCategoryScreen: View {
    @State private var name: String = ""
    @State private var isLoading: Bool = false
    
    @Environment(PlatziStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(ErrorState.self) private var errorState

    private func createCategory() async {
        defer { isLoading = false }
        do {
            isLoading = true
            try await store.createCategory(name: name)
            dismiss()
        } catch {
            errorState.error = error
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmptyOrWhitespace
    }
    
    var body: some View {
        Form {
            TextField("Name", text: $name)
        }.toolbar {
            ToolbarItem {
                Button("Save") {
                    Task { await createCategory() }
                }.disabled(!isFormValid || isLoading)
            }
        }
        .navigationTitle("Add Category")
    }
}

#Preview {
    NavigationStack {
        AddCategoryScreen()
    }
    .environment(PlatziStore(httpClient: HTTPClient()))
    .environment(ErrorState())
}
