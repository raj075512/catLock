import Foundation

struct FocusSession: Identifiable, Codable, Hashable {
    var id: UUID
    var taskID: FocusTask.ID?
    var startedAt: Date
    var endedAt: Date?
    var plannedDuration: TimeInterval
    var elapsedDuration: TimeInterval
    var state: FocusSessionState

    init(
        id: UUID = UUID(),
        taskID: FocusTask.ID? = nil,
        startedAt: Date = .now,
        endedAt: Date? = nil,
        plannedDuration: TimeInterval = 25 * 60,
        elapsedDuration: TimeInterval = 0,
        state: FocusSessionState = .idle
    ) {
        self.id = id
        self.taskID = taskID
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.plannedDuration = plannedDuration
        self.elapsedDuration = elapsedDuration
        self.state = state
    }
}
