import SwiftUI

struct LoginScreen: View {
    
    @State private var email: String = "johndoe@gmail.com"
    @State private var password: String = "password1234"
    @AppStorage("isAuthenticated") private var isAuthenticated: Bool = false
    
    @Environment(\.authenticationController) private var authenticationController
    
    private var isFormValid: Bool {
        !email.isEmptyOrWhitespace && !password.isEmptyOrWhitespace
    }
    
    private func login() async {
        do {
            isAuthenticated = try await authenticationController.login(email: email, password: password)
            print(isAuthenticated)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Welcome Back").font(.headline).foregroundColor(.blue)) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .foregroundColor(.primary)
                
                SecureField("Password", text: $password)
                    .textInputAutocapitalization(.never)
                    .foregroundColor(.primary)
            }
            
            Section {
                Button(action: {
                    Task { await login() }
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                        .background(isFormValid ? Color.blue : Color.gray)
                        .cornerRadius(8)
                }
                .disabled(!isFormValid)
                .listRowBackground(Color.clear)
            }
        }
    }
}

#Preview {
    LoginScreen()
}
