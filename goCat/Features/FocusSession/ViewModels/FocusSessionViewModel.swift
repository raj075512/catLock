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
        timerService.complete()
        session.state = .completed
        session.endedAt = .now
    }
}
