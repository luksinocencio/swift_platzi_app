import SwiftUI

struct AddCategoryScreen: View {
    @State private var name: String = ""
    @State private var isLoading: Bool = false
    
    @Environment(PlatziStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    
    private func createCategory() async {
        defer { isLoading = false }
        do {
            isLoading = true
            try await store.createCategory(name: name)
            dismiss()
        } catch {
            print(error.localizedDescription)
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
    }.environment(PlatziStore(httpClient: HTTPClient()))
}
