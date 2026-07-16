import SwiftUI

struct CategoryListScreen: View {
    @Environment(PlatziStore.self) private var store
    @State private var isLoading: Bool = false
    @State private var showAddCategoryScreen: Bool = false
    
    private func loadCategories() async {
        defer { isLoading = false }
        
        do {
            isLoading = true
            try await store.loadCategories()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var body: some View {
        ZStack {
            if store.categories.isEmpty && !isLoading {
                ContentUnavailableView("No products available", systemImage: "shippingbox")
            } else {
                List(store.categories) { category in
                    NavigationLink {
                        ProductListScreen(category: category)
                    } label: {
                        CategoryCellView(category: category)
                    }
                }
                .listStyle(.grouped)
            }
        }
        .overlay(alignment: .center) {
            if isLoading {
                ProgressView("Loading...")
            }
        }
        .task {
            await loadCategories()
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add Category") {
                    showAddCategoryScreen = true
                }
            }
        })
        .sheet(isPresented: $showAddCategoryScreen, content: {
            NavigationStack {
                AddCategoryScreen()
            }
        })
        .navigationTitle("Categories")
    }
}

#Preview {
    NavigationStack {
        CategoryListScreen()
    }.environment(PlatziStore(httpClient: HTTPClient()))
}
