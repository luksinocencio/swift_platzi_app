import SwiftUI

struct LoginScreen: View {

    @State private var viewModel = LoginViewModel()
    @AppStorage(Constants.Keys.isAuthenticated) private var isAuthenticated: Bool = false

    @Environment(ErrorState.self) private var errorState

    private func login() async {
        do {
            isAuthenticated = try await viewModel.login()
        } catch {
            errorState.error = error
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                header
                fields
                loginButton
                registrationLink
            }
            .padding(.horizontal, 24)
            .padding(.top, 48)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private var header: some View {
        VStack(spacing: 16) {
            Image(systemName: "bag.fill")
                .font(.system(size: 40))
                .foregroundStyle(.white)
                .frame(width: 88, height: 88)
                .background(
                    LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: .rect(cornerRadius: 22, style: .continuous)
                )

            VStack(spacing: 4) {
                Text("Welcome Back")
                    .font(.largeTitle.bold())
                Text("Sign in to continue shopping")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var fields: some View {
        VStack(spacing: 12) {
            AuthField(icon: "envelope") {
                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            AuthField(icon: "lock") {
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.password)
                    .textInputAutocapitalization(.never)
            }
        }
    }

    private var loginButton: some View {
        Button {
            Task { await login() }
        } label: {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Login")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .controlSize(.large)
        .disabled(!viewModel.isFormValid || viewModel.isLoading)
    }

    private var registrationLink: some View {
        NavigationLink {
            RegistrationScreen()
        } label: {
            Text("Don't have an account? \(Text("Register").fontWeight(.semibold))")
                .font(.subheadline)
        }
    }
}

#Preview {
    NavigationStack {
        LoginScreen()
    }
    .environment(ErrorState())
}
