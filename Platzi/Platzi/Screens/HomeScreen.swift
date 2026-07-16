import SwiftUI

struct HomeScreen: View {
    
    var body: some View {
        TabView {
            Tab {
                NavigationStack {
                    CategoryListScreen()
                }
            } label: {
                Label("Categories", systemImage: "square.grid.2x2")
            }
            
            Tab {
                NavigationStack {
                    LocationsScreen()
                }
            } label: {
                Label("Locations", systemImage: "map")
            }
            
            Tab {
                NavigationStack {
                    ProfileScreen()
                }
            } label: {
                Label("Profile", systemImage: "person.crop.circle")
            }
        }
    }
}

#Preview {
    HomeScreen()
        .environment(PlatziStore(httpClient: HTTPClient()))
}
