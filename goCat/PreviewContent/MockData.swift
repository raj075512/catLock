import Foundation

enum MockData {
    static let task = FocusTask(title: "Draft focus plan")
    static let session = FocusSession(plannedDuration: 25 * 60, elapsedDuration: 25 * 60, state: .completed)
    static let summary = ProgressSummary.sample
}
