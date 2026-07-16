import SwiftUI

/// A rounded input container with a leading icon, used on the Login and Registration screens.
struct AuthField<Field: View>: View {
    let icon: String
    @ViewBuilder let field: Field

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 24)
            field
        }
        .padding()
        .background(.fill.tertiary, in: .rect(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    VStack(spacing: 12) {
        AuthField(icon: "envelope") {
            TextField("Email", text: .constant(""))
        }
        AuthField(icon: "lock") {
            SecureField("Password", text: .constant(""))
        }
    }
    .padding()
}
