import iOSFirebaseTools
import SwiftUI

struct NotesView: View {
    @Bindable var model: LabModel
    @State private var draft = ""
    @State private var showsAccount = false

    var body: some View {
        NavigationStack {
            List {
                if let message = model.message {
                    Label(message, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                        .accessibilityIdentifier("message")
                }
                ForEach(model.notes, id: \.id) { note in
                    NoteRow(note: note.data)
                        .swipeActions(edge: .trailing) {
                            Button("Delete", systemImage: "trash", role: .destructive) { Task { await model.delete(note) } }
                        }
                        .swipeActions(edge: .leading) {
                            Button(note.data.pinned ? "Unpin" : "Pin", systemImage: note.data.pinned ? "pin.slash" : "pin") {
                                Task { await model.togglePin(note) }
                            }
                            .tint(.labBlue)
                        }
                }
            }
            .overlay {
                if model.notes.isEmpty && !model.isWorking {
                    ContentUnavailableView("No Notes Yet", systemImage: "note.text",
                                           description: Text("Notes are saved in Cloud Firestore, readable only by you."))
                }
            }
            .refreshable { await model.refresh() }
            .safeAreaInset(edge: .bottom) { composer }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Account", systemImage: "person.crop.circle") { showsAccount = true }
                        .accessibilityIdentifier("account")
                }
            }
            .sheet(isPresented: $showsAccount) {
                AccountView(model: model)
            }
        }
    }

    private var composer: some View {
        HStack {
            TextField("New note", text: $draft)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.done)
                .onSubmit(add)
                .accessibilityIdentifier("new-note")
            Button("Add", systemImage: "plus.circle.fill", action: add)
                .labelStyle(.iconOnly)
                .font(.title2)
                .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty || model.isWorking)
                .accessibilityIdentifier("add-note")
        }
        .padding()
        .background(.bar)
    }

    private func add() {
        let text = draft
        draft = ""
        Task { await model.add(text) }
    }
}

struct NoteRow: View {
    let note: Note

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(note.text)
                if let createdAt = note.createdAt {
                    Text(createdAt, format: .dateTime.hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if note.pinned {
                Image(systemName: "pin.fill")
                    .foregroundStyle(Color.labBlue)
                    .accessibilityLabel("Pinned")
            }
        }
        .accessibilityElement(children: .combine)
    }
}
