import SwiftUI

struct ProfileScreen: View {
    
    @Environment(\.authenticationService) private var authenticationService

    var body: some View {
        // Sign Out Button
        Button(action: {
            authenticationService.signOut()
        }) {
            Text("Sign Out")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(12)
        }
        .padding(.horizontal)
        .padding(.bottom, 40)
        .navigationTitle("Profile")
    }
}

#Preview {
    NavigationStack {
        ProfileScreen()
    }
}
