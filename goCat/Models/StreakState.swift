import Foundation

/// The streak, as days rather than as a tally of sessions.
///
/// The distinction matters: an earlier build incremented a counter on every
/// completed session, so three sessions in one afternoon displayed "3 day
/// streak". A streak is a property of the calendar, not of the session count.
struct StreakState: Codable, Hashable {
    var current: Int
    var best: Int
    /// Start-of-day for the last day with at least one completed session.
    var lastCompletedDay: Date?

    static let empty = StreakState(current: 0, best: 0, lastCompletedDay: nil)

    /// The streak as it should be *displayed* right now.
    ///
    /// `current` is only correct as of `lastCompletedDay`. Once the user misses
    /// a day it is stale, and reading the stored value directly would show a
    /// streak that has actually lapsed. Today and yesterday both still count —
    /// a streak isn't broken until a whole day passes without a session, so
    /// someone who finished yesterday and hasn't started today has not lost it.
    func current(asOf date: Date, calendar: Calendar = .current) -> Int {
        guard let lastCompletedDay else { return 0 }
        let today = calendar.startOfDay(for: date)
        guard let days = calendar.dateComponents([.day], from: lastCompletedDay, to: today).day else {
            return 0
        }
        return days <= 1 ? current : 0
    }

    /// Record a completed session. Returns the streak after recording.
    ///
    /// Only completions land here. Cancelling never calls this, and the copy
    /// on the cancelled screen promises exactly that.
    mutating func recordCompletion(on date: Date = .now, calendar: Calendar = .current) -> Int {
        let today = calendar.startOfDay(for: date)

        if let lastCompletedDay {
            let days = calendar.dateComponents([.day], from: lastCompletedDay, to: today).day ?? 0
            switch days {
            case 0:
                // Already counted today. A second session is still recorded in
                // history and still adds minutes — it just doesn't move a
                // counter that measures days.
                return current
            case 1:
                current += 1
            default:
                current = 1
            }
        } else {
            current = 1
        }

        best = max(best, current)
        self.lastCompletedDay = today
        return current
    }
}
