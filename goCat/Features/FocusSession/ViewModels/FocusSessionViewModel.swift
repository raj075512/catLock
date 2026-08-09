import Foundation
import Observation

@MainActor
@Observable
final class FocusSessionViewModel {
    var timerService: FocusTimerService
    var session: FocusSession

    init(session: FocusSession = FocusSession()) {
        self.session = session
        self.timerService = FocusTimerService(duration: session.plannedDuration)

        // Keep `session.state` in sync even when the countdown finishes on
        // its own (not just when `complete()` is tapped explicitly).
        timerService.onComplete = { [weak self] in
            self?.session.state = .completed
            self?.session.endedAt = .now
        }
    }

    var formattedRemainingTime: String {
        let totalSeconds = Int(timerService.remainingSeconds)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func start() {
        timerService.start()
        session.state = .running
    }

    func pause() {
        timerService.pause()
        session.state = .paused
    }

    func complete() {
        // session.state/endedAt are updated by the onComplete callback set
        // in init, so this stays correct whether complete() is tapped
        // explicitly or the countdown just ran out.
        timerService.complete()
    }
}
