import SwiftUI

struct CategoryListScreen: View {
    @State private var viewModel = CategoryListViewModel()
    @State private var showAddCategoryScreen: Bool = false

    @Environment(ErrorState.self) private var errorState

    private func loadCategories() async {
        do {
            try await viewModel.loadCategories()
        } catch {
            errorState.error = error
        }
    }

    var body: some View {
        ZStack {
            if viewModel.categories.isEmpty && !viewModel.isLoading {
                ContentUnavailableView("No products available", systemImage: "shippingbox")
            } else {
                List(viewModel.categories) { category in
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
            if viewModel.isLoading {
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
                AddCategoryScreen { category in
                    viewModel.add(category)
                }
            }
            .globalErrorAlert()
        })
        .navigationTitle("Categories")
    }
}

#Preview {
    NavigationStack {
        CategoryListScreen()
    }
    .environment(ErrorState())
}
