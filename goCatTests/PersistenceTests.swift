import SwiftData
import XCTest
@testable import goCat

/// Tasks used to be an in-memory array seeded with two placeholders, so
/// nothing survived a launch. These cover the SwiftData store that replaced it.
@MainActor
final class PersistenceTests: XCTestCase {
    private func makeContext() throws -> ModelContext {
        ModelContext(AppModelContainer.inMemory())
    }

    func testTasksSurviveInTheStore() throws {
        let context = try makeContext()
        context.insert(TaskItem(title: "Draft the intro paragraph"))
        try context.save()

        let stored = try context.fetch(FetchDescriptor<TaskItem>())

        XCTAssertEqual(stored.count, 1)
        XCTAssertEqual(stored.first?.title, "Draft the intro paragraph")
        XCTAssertFalse(stored.first?.isCompleted ?? true)
    }

    func testTogglingATaskRecordsWhenItWasCompleted() {
        let task = TaskItem(title: "Reply to Meera about Thursday")

        task.toggle()
        XCTAssertTrue(task.isCompleted)
        XCTAssertNotNil(task.completedAt)

        task.toggle()
        XCTAssertFalse(task.isCompleted)
        XCTAssertNil(task.completedAt, "Un-completing clears the timestamp so it isn't swept at midnight")
    }

    func testCompletedSessionsAreStoredForProgress() throws {
        let context = try makeContext()
        context.insert(CompletedSession(minutes: 25, soundName: "Rain"))
        context.insert(CompletedSession(minutes: 45, soundName: nil))
        try context.save()

        let stored = try context.fetch(FetchDescriptor<CompletedSession>())

        XCTAssertEqual(stored.count, 2)
        XCTAssertEqual(stored.map(\.minutes).sorted(), [25, 45])
    }

    /// Today's totals drive the two stat cards; the week drives the chart.
    func testProgressSummaryAggregatesTodayAndTheWeek() {
        let sessions = [
            CompletedSession(minutes: 25, soundName: "Rain", endedAt: .now),
            CompletedSession(minutes: 50, soundName: "Rain", endedAt: .now)
        ]

        let summary = ProgressSummary(sessions: sessions)

        XCTAssertEqual(summary.minutesToday, 75)
        XCTAssertEqual(summary.sessionsToday, 2)
        XCTAssertEqual(summary.weekMinutes.count, 7)
        XCTAssertEqual(summary.weekMinutes[summary.todayIndex], 75)
    }

    func testProgressSummaryFormatsHoursAndMinutes() {
        XCTAssertEqual(ProgressSummary.format(minutes: 250), "4h 10m")
        XCTAssertEqual(ProgressSummary.format(minutes: 120), "2h")
        XCTAssertEqual(ProgressSummary.format(minutes: 40), "40m")
    }

    func testEmptyHistoryReportsEmpty() {
        XCTAssertTrue(ProgressSummary(sessions: []).isEmpty)
    }
}
