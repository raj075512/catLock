import Foundation
import Observation

@MainActor
@Observable
final class TaskViewModel {
    var tasks: [FocusTask] = [
        FocusTask(title: "Plan the next focus block"),
        FocusTask(title: "Review priority task")
    ]

    func addTask(title: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            return
        }
        tasks.append(FocusTask(title: trimmedTitle))
    }

    func toggle(_ task: FocusTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }
        tasks[index].toggleCompleted()
    }
}
