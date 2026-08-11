import Foundation
import SwiftData

/// A session the user *finished*.
///
/// Cancelled sessions are never written here. That is rule 3, and it is why
/// this type has no state field: everything in the store completed, so history
/// and the weekly chart cannot accidentally show an abandoned session as work
/// done.
@Model
final class CompletedSession {
    var id: UUID = UUID()
    var minutes: Int = 0
    /// Display name of the sound that was playing, or `nil` for silence.
    var soundName: String?
    var endedAt: Date = Date.now

    init(id: UUID = UUID(), minutes: Int, soundName: String?, endedAt: Date = .now) {
        self.id = id
        self.minutes = minutes
        self.soundName = soundName
        self.endedAt = endedAt
    }
}

/// A line on the task scratchpad.
///
/// Not a task manager: no due date, no priority, no project, no reminder.
/// Anything more and it starts competing with the timer for attention, which
/// is the one thing this screen must not do.
@Model
final class TaskItem {
    var id: UUID = UUID()
    var title: String = ""
    var isCompleted: Bool = false
    var createdAt: Date = Date.now
    var completedAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        createdAt: Date = .now,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.completedAt = completedAt
    }

    func toggle() {
        isCompleted.toggle()
        completedAt = isCompleted ? .now : nil
    }
}
