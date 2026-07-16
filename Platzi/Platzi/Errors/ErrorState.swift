import SwiftUI
import Observation

@MainActor
@Observable
class ErrorState {
    var error: Error?
}

struct GlobalErrorAlertModifier: ViewModifier {
    @Environment(ErrorState.self) private var errorState

    func body(content: Content) -> some View {
        content
            .alert(
                "Error",
                isPresented: Binding(
                    get: { errorState.error != nil },
                    set: { if !$0 { errorState.error = nil } }
                )
            ) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorState.error?.localizedDescription ?? "An unexpected error occurred.")
            }
    }
}

extension View {
    /// Presents a global error alert driven by the `ErrorState` in the environment.
    /// Apply at the root and inside sheet contexts so alerts present correctly.
    func globalErrorAlert() -> some View {
        modifier(GlobalErrorAlertModifier())
    }
}
