import SwiftUI

struct SignInView: View {
    @Bindable var model: LabModel
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("E-mail", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .accessibilityIdentifier("email")
                    SecureField("Password", text: $password)
                        .accessibilityIdentifier("password")
                } footer: {
                    Text("Firebase Authentication over its REST API, with the session kept in the keychain.")
                }

                Section {
                    Button("Create Account") { Task { await model.signUp(email: email, password: password) } }
                        .accessibilityIdentifier("sign-up")
                    Button("Sign In") { Task { await model.signIn(email: email, password: password) } }
                        .accessibilityIdentifier("sign-in")
                    Button("Continue Without an Account") { Task { await model.continueAnonymously() } }
                        .accessibilityIdentifier("anonymous")
                }
                .disabled(model.isWorking)

                if let message = model.message {
                    Section {
                        Label(message, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                            .accessibilityIdentifier("message")
                    }
                }

                Section {
                    Label(model.environmentLabel, systemImage: "server.rack")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Firebase Lab")
        }
    }
}
