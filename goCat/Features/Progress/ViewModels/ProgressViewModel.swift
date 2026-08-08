import Foundation
import Observation

@MainActor
@Observable
final class ProgressViewModel {
    var summary = ProgressSummary.sample
    var sessions: [FocusSession] = [
        FocusSession(startedAt: .now.addingTimeInterval(-3600), endedAt: .now, plannedDuration: 25 * 60, elapsedDuration: 25 * 60, state: .completed)
    ]
}
