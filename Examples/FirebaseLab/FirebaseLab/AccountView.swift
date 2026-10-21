import iOSFirebaseTools
import SwiftUI

struct AccountView: View {
    @Bindable var model: LabModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                if let session = model.session {
                    Section("User") {
                        LabeledContent("User ID", value: session.userID)
                        LabeledContent("E-mail", value: session.email ?? "Anonymous")
                            .accessibilityIdentifier("user-email")
                        if let provider = model.claims?.signInProvider {
                            LabeledContent("Signed in with", value: provider)
                                .accessibilityIdentifier("provider")
                        }
                    }
                    Section {
                        // Secret's description: the token itself never reaches the screen or a log.
                        LabeledContent("ID token", value: String(describing: session.idToken))
                            .accessibilityIdentifier("id-token")
                        LabeledContent("Expires", value: session.expiresAt.formatted(date: .omitted, time: .shortened))
                        Button("Refresh Token") { Task { await model.refreshToken() } }
                    } header: {
                        Text("Token")
                    } footer: {
                        Text("Claims are read on the device without checking the signature. Servers verify tokens with IDTokenVerifier.")
                    }
                }
                Section {
                    Button("Sign Out") {
                        Task {
                            await model.signOut()
                            dismiss()
                        }
                    }
                    .accessibilityIdentifier("sign-out")
                    Button("Delete Account", role: .destructive) {
                        Task {
                            await model.deleteAccount()
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("done")
                }
            }
        }
    }
}
