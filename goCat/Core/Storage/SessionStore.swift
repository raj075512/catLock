import Foundation

final class SessionStore {
    static let shared = SessionStore()

    private enum Keys {
        static let activeTimer = "activeTimer"
    }

    private let store: UserDefaultsStore

    init(store: UserDefaultsStore = .shared) {
        self.store = store
    }

    func saveTimerSnapshot(_ snapshot: TimerSnapshot) {
        store.set(snapshot, forKey: Keys.activeTimer)
    }

    func loadTimerSnapshot() -> TimerSnapshot? {
        store.value(forKey: Keys.activeTimer, fallback: Optional<TimerSnapshot>.none)
    }

    func clearTimerSnapshot() {
        store.removeValue(forKey: Keys.activeTimer)
    }
}

extension SessionStore {
    struct TimerSnapshot: Codable, Hashable {
        var remainingSeconds: TimeInterval
        var state: FocusSessionState
        var updatedAt: Date
    }
}
