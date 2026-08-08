import Foundation
import Observation

@MainActor
@Observable
final class FocusTimerService {
    private(set) var state: FocusSessionState = .idle
    private(set) var remainingSeconds: TimeInterval

    var duration: TimeInterval

    init(duration: TimeInterval = 25 * 60) {
        self.duration = duration
        self.remainingSeconds = duration
    }

    func start() {
        state = .running
    }

    func pause() {
        state = .paused
    }

    func complete() {
        remainingSeconds = 0
        state = .completed
    }

    func reset(to duration: TimeInterval? = nil) {
        if let duration {
            self.duration = duration
        }
        remainingSeconds = self.duration
        state = .idle
    }
}
