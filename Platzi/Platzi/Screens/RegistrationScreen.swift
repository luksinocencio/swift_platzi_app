import SwiftUI

struct RegistrationScreen: View {

    @Environment(\.authenticationController) private var authenticationController
    @Environment(ErrorState.self) private var errorState

    @State private var registrationForm = RegistrationForm()
    @State private var successMessage: String?
    @State private var isLoading: Bool = false

    private func register() async {
        defer { isLoading = false }

        do {
            isLoading = true
            let response = try await authenticationController.register(
                name: registrationForm.name,
                email: registrationForm.email,
                password: registrationForm.password
            )
            successMessage = "Registration for user \(response.name) is completed."
        } catch {
            errorState.error = error
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                header
                fields

                let validationErrors = registrationForm.validate()
                if !validationErrors.isEmpty {
                    ValidationSummaryView(errors: validationErrors)
                }

                if let successMessage {
                    successBanner(successMessage)
                }

                registerButton
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
        }
        .scrollBounceBehavior(.basedOnSize)
        .navigationTitle("Register")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 40))
                .foregroundStyle(.white)
                .frame(width: 88, height: 88)
                .background(
                    LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: .rect(cornerRadius: 22, style: .continuous)
                )

            VStack(spacing: 4) {
                Text("Create Account")
                    .font(.largeTitle.bold())
                Text("Join Platzi Store today")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var fields: some View {
        VStack(spacing: 12) {
            AuthField(icon: "person") {
                TextField("Name", text: $registrationForm.name)
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
            }

            AuthField(icon: "envelope") {
                TextField("Email", text: $registrationForm.email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            AuthField(icon: "lock") {
                SecureField("Password", text: $registrationForm.password)
                    .textContentType(.newPassword)
                    .textInputAutocapitalization(.never)
            }
        }
    }

    private var registerButton: some View {
        Button {
            Task { await register() }
        } label: {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Register")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .controlSize(.large)
        .disabled(!registrationForm.isValid || isLoading)
    }

    private func successBanner(_ message: String) -> some View {
        HStack(alignment: .top) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
        .frame(maxWidth: .infinity, alignment: .leading)
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
    NavigationStack {
        RegistrationScreen()
    }
    .environment(ErrorState())
}
