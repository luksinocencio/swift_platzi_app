import SwiftUI

struct ProductListScreen: View {
    @State private var viewModel: ProductListViewModel
    @State private var showAddProductScreen: Bool = false

    @Environment(ErrorState.self) private var errorState

    init(category: Category) {
        _viewModel = State(initialValue: ProductListViewModel(category: category))
    }

    private func loadProducts() async {
        do {
            try await viewModel.loadProducts()
        } catch {
            errorState.error = error
        }
    }

    private func deleteProducts(_ indexSet: IndexSet) {
        Task {
            do {
                try await viewModel.deleteProducts(at: indexSet)
            } catch {
                errorState.error = error
            }
        }
    }

    var body: some View {
        ZStack {
            if viewModel.products.isEmpty && !viewModel.isLoading {
                ContentUnavailableView("No products available", systemImage: "shippingbox")
            } else {
                List {
                    ForEach(viewModel.products) { product in
                        NavigationLink {
                            ProductDetailScreen(product: product)
                        } label: {
                            ProductCellView(product: product)
                        }
                    }.onDelete(perform: deleteProducts)
                }.refreshable {
                    await loadProducts()
                }
            }
        }
        .overlay(alignment: .center) {
            if viewModel.isLoading {
                ProgressView("Loading...")
            }
        }
        .sheet(isPresented: $showAddProductScreen, content: {
            NavigationStack {
                AddProductScreen(selectedCategory: viewModel.category.id) { product in
                    viewModel.add(product)
                }
            }
            .globalErrorAlert()
        })
        .toolbar(content: {
            ToolbarItem {
                Button("Add Product") {
                    showAddProductScreen = true
                }
            }
        })
        .task {
            await loadProducts()
        }
        .navigationTitle(viewModel.category.name)
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
        ProductListScreen(category: .init(id: 79, name: "Shoes", image: URL.randomImageURL))
    }
    .environment(ErrorState())
}
