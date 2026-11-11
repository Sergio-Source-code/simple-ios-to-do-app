import SwiftUI

struct TodoItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var isDone = false
}

struct ContentView: View {
    @AppStorage("todos") private var stored: Data = Data()
    @State private var items: [TodoItem] = []
    @State private var newTitle = ""
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        TextField("New task", text: $newTitle)
                            .focused($focused)
                            .submitLabel(.done)
                            .onSubmit(add)
                        Button(action: add) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(newTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                Section {
                    ForEach($items) { $item in
                        Button {
                            item.isDone.toggle()
                        } label: {
                            HStack {
                                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                Text(item.title)
                                    .strikethrough(item.isDone)
                                    .foregroundStyle(item.isDone ? .secondary : .primary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { items.remove(atOffsets: $0) }
                }
            }
            .overlay {
                if items.isEmpty {
                    ContentUnavailableView("No tasks", systemImage: "checklist", description: Text("Add a task above."))
                        .allowsHitTesting(false)
                }
            }
            .navigationTitle("To-Do")
            .toolbar { EditButton() }
        }
        .onAppear {
            items = (try? JSONDecoder().decode([TodoItem].self, from: stored)) ?? []
        }
        .onChange(of: items) { save() }
    }

    private func add() {
        let title = newTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }
        items.insert(TodoItem(title: title), at: 0)
        newTitle = ""
    }

    private func save() {
        stored = (try? JSONEncoder().encode(items)) ?? Data()
    }
}
