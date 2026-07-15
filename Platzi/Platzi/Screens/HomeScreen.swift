import SwiftUI

struct HomeScreen: View {
    @Environment(\.authenticationController) private var authenticationController
    
    var body: some View {
        Button("Signout") {
            authenticationController.signOut()
        }
    }
}

#Preview {
    HomeScreen()
}
