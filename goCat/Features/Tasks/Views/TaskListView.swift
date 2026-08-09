import SwiftUI

struct TaskListView: View {
    @State private var viewModel = TaskViewModel()
    @State private var isAddingTask = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.tasks.isEmpty {
                    EmptyStateView(
                        title: "No tasks",
                        message: "Add a task before your next focus block.",
                        systemImage: "checklist"
                    )
                } else {
                    List(viewModel.tasks) { task in
                        TaskRowView(task: task) {
                            viewModel.toggle(task)
                        }
                    }
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isAddingTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Task")
                }
            }
            .sheet(isPresented: $isAddingTask) {
                AddTaskView { title in
                    viewModel.addTask(title: title)
                }
            }
        }
    }
}
