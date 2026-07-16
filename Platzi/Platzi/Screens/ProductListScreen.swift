import SwiftUI

struct ProductListScreen: View {
    let category: Category
    
    @Environment(PlatziStore.self) private var store
    @State private var products: [Product] = []
    @State private var isLoading: Bool = false
    
    private func loadProducts() async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            products = try await store.fetchProductsBy(category.id)
            print(products)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var body: some View {
        ZStack {
            if products.isEmpty && !isLoading {
                ContentUnavailableView("No products available", systemImage: "shippingbox")
            } else {
                List(products) { product in
                    NavigationLink {
                        ProductDetailScreen(product: product)
                    } label: {
                        ProductCellView(product: product)
                    }
                }.refreshable {
                    await loadProducts()
                }
            }
        }
        .overlay(alignment: .center) {
            if isLoading {
                ProgressView("Loading...")
            }
        }
        .task {
            Task { await loadProducts() }
        }
        .navigationTitle(category.name)
    }
}

struct ProductCellView: View {
    let product: Product
    
    var body: some View {
        HStack {
            AsyncImage(url: product.images.first) { img in
                img
                    .resizable()
                    .frame(width: 75, height: 75)
                    .clipShape(RoundedRectangle(cornerRadius: 16.0, style: .continuous))
            } placeholder: {
                ImagePlaceHolderView()
            }
            Text(product.title)
        }
    }
}

#Preview {
    NavigationStack {
        ProductListScreen(category: .init(id: 1, name: "Shoes", image: URL.randomImageURL))
    }.environment(PlatziStore(httpClient: HTTPClient()))
}
