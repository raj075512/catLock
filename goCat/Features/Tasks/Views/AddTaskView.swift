import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""

    let onAdd: (String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Task title", text: $title)
            }
            .navigationTitle("Add Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd(title)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
