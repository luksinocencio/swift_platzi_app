import SwiftUI

struct RegistrationScreen: View {

    @State private var viewModel = RegistrationViewModel()

    @Environment(ErrorState.self) private var errorState

    private func register() async {
        do {
            try await viewModel.register()
        } catch {
            errorState.error = error
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                header
                fields

                let validationErrors = viewModel.validate()
                if !validationErrors.isEmpty {
                    ValidationSummaryView(errors: validationErrors)
                }

                if let successMessage = viewModel.successMessage {
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
                TextField("Name", text: $viewModel.name)
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
            }

            AuthField(icon: "envelope") {
                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            AuthField(icon: "lock") {
                SecureField("Password", text: $viewModel.password)
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
                if viewModel.isLoading {
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
        .disabled(!viewModel.isFormValid || viewModel.isLoading)
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

#Preview {
    NavigationStack {
        RegistrationScreen()
    }
    .environment(ErrorState())
}
