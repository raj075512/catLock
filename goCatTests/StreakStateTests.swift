import XCTest
@testable import goCat

/// The streak used to be a session counter: three sessions in one afternoon
/// displayed "3 day streak". These tests pin the day-boundary behaviour that
/// replaced it.
final class StreakStateTests: XCTestCase {
    private let calendar = Calendar(identifier: .gregorian)

    private func day(_ offset: Int) -> Date {
        calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: .now))!
    }

    func testFirstCompletionStartsAtOne() {
        var streak = StreakState.empty

        XCTAssertEqual(streak.recordCompletion(on: day(0), calendar: calendar), 1)
        XCTAssertEqual(streak.best, 1)
    }

    /// The bug this replaced. Several sessions in one day is one day.
    func testSecondCompletionOnTheSameDayDoesNotIncrement() {
        var streak = StreakState.empty

        _ = streak.recordCompletion(on: day(0), calendar: calendar)
        _ = streak.recordCompletion(on: day(0), calendar: calendar)
        let third = streak.recordCompletion(on: day(0), calendar: calendar)

        XCTAssertEqual(third, 1, "Three sessions today is still a one-day streak")
    }

    func testConsecutiveDaysIncrement() {
        var streak = StreakState.empty

        _ = streak.recordCompletion(on: day(-2), calendar: calendar)
        _ = streak.recordCompletion(on: day(-1), calendar: calendar)

        XCTAssertEqual(streak.recordCompletion(on: day(0), calendar: calendar), 3)
    }

    func testMissedDayResetsToOne() {
        var streak = StreakState.empty

        _ = streak.recordCompletion(on: day(-5), calendar: calendar)

        XCTAssertEqual(streak.recordCompletion(on: day(0), calendar: calendar), 1)
    }

    func testBestIsRetainedAfterAReset() {
        var streak = StreakState.empty

        _ = streak.recordCompletion(on: day(-3), calendar: calendar)
        _ = streak.recordCompletion(on: day(-2), calendar: calendar)
        _ = streak.recordCompletion(on: day(0), calendar: calendar)

        XCTAssertEqual(streak.current, 1)
        XCTAssertEqual(streak.best, 2)
    }

    /// Finishing yesterday and not having started today is not a broken
    /// streak — the user still has the rest of the day.
    func testYesterdayStillCounts() {
        var streak = StreakState.empty
        _ = streak.recordCompletion(on: day(-1), calendar: calendar)

        XCTAssertEqual(streak.current(asOf: day(0), calendar: calendar), 1)
    }

    /// But a stored value goes stale once a whole day is skipped, and reading
    /// it directly would show a streak that has actually lapsed.
    func testStreakReadsAsZeroOnceADayIsMissed() {
        var streak = StreakState.empty
        _ = streak.recordCompletion(on: day(-3), calendar: calendar)

        XCTAssertEqual(streak.current, 1, "The stored value is still 1")
        XCTAssertEqual(streak.current(asOf: day(0), calendar: calendar), 0, "But it displays as lapsed")
    }
}
