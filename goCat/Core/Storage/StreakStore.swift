import Foundation
import Observation

/// Persists the focus streak.
///
/// Observable so the Home pill and the Progress sheet both react when a
/// session completes, rather than each polling on appear.
@MainActor
@Observable
final class StreakStore {
    static let shared = StreakStore()

    private enum Keys {
        static let state = "streakState"
        /// The pre-day-boundary counter. Read once to migrate, then ignored.
        static let legacyCounter = "currentStreak"
    }

    private(set) var state: StreakState

    private let store: UserDefaultsStore
    private let calendar: Calendar

    init(store: UserDefaultsStore = .shared, calendar: Calendar = .current) {
        self.store = store
        self.calendar = calendar
        self.state = Self.loadState(from: store, calendar: calendar)
    }

    /// The number to put in front of "day streak".
    var currentStreak: Int {
        state.current(asOf: .now, calendar: calendar)
    }

    var bestStreak: Int {
        state.best
    }

    /// True before the very first completed session, when the pill reads
    /// "Day 1 starts here" instead of showing a zero next to a flame.
    var hasEverCompleted: Bool {
        state.lastCompletedDay != nil
    }

    @discardableResult
    func recordCompletedSession(on date: Date = .now) -> Int {
        let updated = state.recordCompletion(on: date, calendar: calendar)
        store.set(state, forKey: Keys.state)
        return updated
    }

    /// Earlier builds stored a bare session count under `currentStreak`. It
    /// was never a day count, but it is the only signal we have about someone
    /// who has been using the app — so carry it over as a best-effort current
    /// streak ending today rather than resetting them to zero on upgrade.
    private static func loadState(from store: UserDefaultsStore, calendar: Calendar) -> StreakState {
        if let stored: StreakState = store.storedValue(forKey: Keys.state) {
            return stored
        }

        let legacy: Int = store.value(forKey: Keys.legacyCounter, fallback: 0)
        guard legacy > 0 else { return .empty }

        return StreakState(
            current: legacy,
            best: legacy,
            lastCompletedDay: calendar.startOfDay(for: .now)
        )
    }
}
