import Foundation

struct TimerPersistenceService {
    private let sessionStore: SessionStore

    init(sessionStore: SessionStore = .shared) {
        self.sessionStore = sessionStore
    }

    func save(remainingSeconds: TimeInterval, state: FocusSessionState) {
        let snapshot = SessionStore.TimerSnapshot(
            remainingSeconds: remainingSeconds,
            state: state,
            updatedAt: .now
        )
        sessionStore.saveTimerSnapshot(snapshot)
    }

    func load() -> (remainingSeconds: TimeInterval, state: FocusSessionState)? {
        guard let snapshot = sessionStore.loadTimerSnapshot() else {
            return nil
        }
        return (snapshot.remainingSeconds, snapshot.state)
    }

    func clear() {
        sessionStore.clearTimerSnapshot()
    }
}
