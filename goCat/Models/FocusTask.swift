import Foundation

struct FocusTask: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date
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

    mutating func toggleCompleted() {
        isCompleted.toggle()
        completedAt = isCompleted ? .now : nil
    }
}
