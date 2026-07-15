import SwiftUI

struct RegistrationScreen: View {
    
    @Environment(\.authenticationController) private var authenticationController
    
    @State private var registrationForm = RegistrationForm()
    @State private var messageText: String?
    
    private func register() async {
        do {
            let response = try await authenticationController.register(
                name: registrationForm.name,
                email: registrationForm.email,
                password: registrationForm.password
            )
            messageText = "✅ Registration for user \(response.name) is completed."
        } catch {
            messageText = "❌ \(error.localizedDescription)"
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Create Account")) {
                    TextField("Name", text: $registrationForm.name)
                        .textContentType(.name)
                        .autocapitalization(.words)
                    
                    TextField("Email", text: $registrationForm.email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $registrationForm.password)
                        .textContentType(.newPassword)
                }
                
                Section {
                    Button(action: {
                        Task { await register() }
                    }) {
                        Text("Register")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(!registrationForm.isValid)
                }
                
                if let messageText {
                    Section {
                        Text(messageText)
                            .foregroundColor(messageText.contains("❌") ? .red : .green)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .navigationTitle("Register")
        }
    }
}


extension RegistrationScreen {
    private struct RegistrationForm {
        var name: String = "John Doe"
        var email: String = "johndoe@gmail.com"
        var password: String = "password1234"
        
        var isValid: Bool {
            validate().isEmpty
        }
        
        func validate() -> [String] {
            
            var errors: [String] = []
            
            if name.isEmptyOrWhitespace {
                errors.append("Name cannot be empty.")
            }
            
            if email.isEmptyOrWhitespace {
                errors.append("Email cannot be empty.")
            }
            
            if password.isEmptyOrWhitespace {
                errors.append("Password cannot be empty.")
            }
            
            if !password.isValidPassword {
                errors.append("Password must be at least 8 characters long.")
            }
            
            if !email.isEmail {
                errors.append("Email must be in correct format.")
            }
            
            return errors
        }
    }
}

#Preview {
    RegistrationScreen()
}
