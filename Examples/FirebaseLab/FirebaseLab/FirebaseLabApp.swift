import SwiftUI

@main
struct FirebaseLabApp: App {
    @State private var model = LabModel()

    var body: some Scene {
        WindowGroup {
            RootView(model: model)
                .tint(.labBlue)
                .task { await model.start() }
        }
    }
}

struct RootView: View {
    @Bindable var model: LabModel

    var body: some View {
        Group {
            if model.session == nil {
                SignInView(model: model)
            } else {
                NotesView(model: model)
            }
        }
        .animation(.default, value: model.session?.userID)
    }
}

extension Color {
    /// The repository's blue (#0071E3).
    static let labBlue = Color(red: 0, green: 113 / 255, blue: 227 / 255)
}
