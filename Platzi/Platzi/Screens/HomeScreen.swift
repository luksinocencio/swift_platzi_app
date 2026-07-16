import SwiftUI

struct HomeScreen: View {
    @Environment(\.authenticationController) private var authenticationController
    
    var body: some View {
        TabView {
            Tab {
                NavigationStack {
                    Text("CategoryListScreen")
                }
            } label: {
                Label("Categories", systemImage: "square.grid.2x2")
            }
            
            Tab {
                NavigationStack {
                    Text("Locations")
                }
            } label: {
                Label("Locations", systemImage: "map")
            }
            
            Tab {
                NavigationStack {
                    Text("Profile")
                }
            } label: {
                Label("Profile", systemImage: "person.crop.circle")
            }
        }
    }
}

#Preview {
    HomeScreen()
}
