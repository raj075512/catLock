import Foundation

/// Tracks the user's focus streak. Deliberately simple for now: a single
/// persisted counter incremented once per completed session — no
/// day-boundary/"did they skip a day" logic yet. That's real behavior
/// (breaking a streak after a missed day, timezone handling, etc.) worth
/// its own pass rather than guessing at it here; see DESIGN.md MVP scope.
final class StreakStore {
    static let shared = StreakStore()

    private enum Keys {
        static let currentStreak = "currentStreak"
    }

    private let store: UserDefaultsStore

    init(store: UserDefaultsStore = .shared) {
        self.store = store
    }

    var currentStreak: Int {
        store.value(forKey: Keys.currentStreak, fallback: 0)
    }

    @discardableResult
    func recordCompletedSession() -> Int {
        let updated = currentStreak + 1
        store.set(updated, forKey: Keys.currentStreak)
        return updated
    }
}
