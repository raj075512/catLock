import Foundation

extension FocusSession {
    var progressSummaryContribution: TimeInterval {
        state == .completed ? elapsedDuration : 0
    }
}
