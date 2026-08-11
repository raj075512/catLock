import Foundation

/// Everything the Progress sheet shows, derived from completed sessions.
///
/// Was a hardcoded `.sample`. The screen answers three questions in descending
/// order of how often they get asked — what's my streak, what did I do today,
/// is this week normal — so the digest is shaped to match rather than exposing
/// a general query surface.
struct ProgressSummary: Hashable {
    var minutesToday: Int
    var sessionsToday: Int
    /// Seven entries, week-start first, each the total minutes for that day.
    var weekMinutes: [Int]
    var weekTotalMinutes: Int
    /// Index into `weekMinutes` for today, so the chart can bold one label.
    var todayIndex: Int

    var isEmpty: Bool {
        sessionsToday == 0 && weekTotalMinutes == 0
    }

    static let empty = ProgressSummary(
        minutesToday: 0,
        sessionsToday: 0,
        weekMinutes: Array(repeating: 0, count: 7),
        weekTotalMinutes: 0,
        todayIndex: 0
    )

    init(
        minutesToday: Int,
        sessionsToday: Int,
        weekMinutes: [Int],
        weekTotalMinutes: Int,
        todayIndex: Int
    ) {
        self.minutesToday = minutesToday
        self.sessionsToday = sessionsToday
        self.weekMinutes = weekMinutes
        self.weekTotalMinutes = weekTotalMinutes
        self.todayIndex = todayIndex
    }

    init(sessions: [CompletedSession], now: Date = .now, calendar: Calendar = .current) {
        let today = calendar.startOfDay(for: now)
        let todaySessions = sessions.filter { calendar.isDate($0.endedAt, inSameDayAs: now) }

        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else {
            self.init(
                minutesToday: todaySessions.reduce(0) { $0 + $1.minutes },
                sessionsToday: todaySessions.count,
                weekMinutes: Array(repeating: 0, count: 7),
                weekTotalMinutes: 0,
                todayIndex: 0
            )
            return
        }

        var buckets = Array(repeating: 0, count: 7)
        for session in sessions where weekInterval.contains(session.endedAt) {
            let day = calendar.startOfDay(for: session.endedAt)
            guard let offset = calendar.dateComponents([.day], from: weekInterval.start, to: day).day,
                  buckets.indices.contains(offset) else { continue }
            buckets[offset] += session.minutes
        }

        let offsetToToday = calendar.dateComponents([.day], from: weekInterval.start, to: today).day ?? 0

        self.init(
            minutesToday: todaySessions.reduce(0) { $0 + $1.minutes },
            sessionsToday: todaySessions.count,
            weekMinutes: buckets,
            weekTotalMinutes: buckets.reduce(0, +),
            todayIndex: min(max(offsetToToday, 0), 6)
        )
    }

    /// "4h 10m", or "40m" under an hour — the chart caption reads
    /// "This week · 4h 10m".
    var formattedWeekTotal: String {
        Self.format(minutes: weekTotalMinutes)
    }

    static func format(minutes: Int) -> String {
        let hours = minutes / 60
        let remainder = minutes % 60
        if hours == 0 { return "\(remainder)m" }
        if remainder == 0 { return "\(hours)h" }
        return "\(hours)h \(remainder)m"
    }

    /// Weekday initials starting from the user's own week start, which is a
    /// locale setting — Sunday in the US, Monday across most of Europe.
    static func weekdayInitials(calendar: Calendar = .current) -> [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let firstIndex = calendar.firstWeekday - 1
        return (0..<7).map { symbols[($0 + firstIndex) % 7] }
    }
}
