import Foundation
import Observation

@MainActor
@Observable
final class FocusSessionViewModel {
    var timerService: FocusTimerService
    var session: FocusSession

    /// Set once, the moment the countdown finishes on its own. The streak
    /// increments here — not in the view — so it happens exactly once no
    /// matter how many times the completion screen re-renders.
    private(set) var completedStreak: Int?

    init(session: FocusSession = FocusSession(), streakStore: StreakStore = .shared) {
        self.session = session
        self.timerService = FocusTimerService(duration: session.plannedDuration)

        timerService.onComplete = { [weak self] in
            self?.session.state = .completed
            self?.session.endedAt = .now
            self?.completedStreak = streakStore.recordCompletedSession()
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

    /// The only way to end a session before the countdown finishes. There's
    /// no pause, and no manual "mark complete" — completion only happens by
    /// letting the countdown reach zero (see `onComplete` above).
    func cancel() {
        timerService.cancel()
        session.state = .cancelled
        session.endedAt = .now
    }
}
