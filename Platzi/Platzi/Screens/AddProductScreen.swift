import SwiftUI

struct AddProductScreen: View {
    @State private var title: String = ""
    @State private var price: Double?
    @State private var description: String = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(PlatziStore.self) private var store
    
    @State private var selectedCategoryId: Int
    
    let onSave: (Product) -> Void
    
    init(selectedCategory: Int, onSave: @escaping (Product) -> Void) {
        self.selectedCategoryId = selectedCategory
        self.onSave = onSave
    }
    
    private var isFormValid: Bool {
        !title.isEmptyOrWhitespace && !description.isEmptyOrWhitespace && price != nil && price! > 0
    }
    
    private func saveProduct() async {
        guard let price else { return }
        
        do {
            let newProduct = try await store.createProduct(
                title: title,
                price: price,
                description: description,
                categoryId: selectedCategoryId,
                images: [URL.randomImageURL]
            )
            onSave(newProduct)
            dismiss()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var body: some View {
        Form {
            Picker("Select a category", selection: $selectedCategoryId) {
                ForEach(store.categories) { category in
                    Text(category.name)
                        .tag(category.id)
                }
            }.pickerStyle(.automatic)
            
            TextField("Title", text: $title)
            TextField("Price", value: $price, format: .number)
                .keyboardType(.decimalPad)
            TextEditor(text: $description)
                .frame(height: 100)
            
        }
        .task {
            do {
                try await store.loadCategories()
            } catch {
                print(error.localizedDescription)
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
                }.disabled(!isFormValid)
            }
        })
        .navigationTitle("Add Product")
        .padding(.top)
    }
}

#Preview {
    NavigationStack {
        AddProductScreen(selectedCategory: 87, onSave: { _ in })
    }.environment(PlatziStore(httpClient: HTTPClient()))
}
