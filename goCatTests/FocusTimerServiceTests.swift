import XCTest
@testable import goCat

final class FocusTimerServiceTests: XCTestCase {
    @MainActor
    func testResetRestoresDuration() {
        let service = FocusTimerService(duration: 60)

        service.start()
        service.complete()
        service.reset()

        XCTAssertEqual(service.remainingSeconds, 60)
        XCTAssertEqual(service.state, .idle)
    }

    @MainActor
    func testStartingSetsAnEndDateFromTheWallClock() {
        let service = FocusTimerService(duration: 25 * 60)

        service.start()

        let end = try? XCTUnwrap(service.endDate)
        XCTAssertNotNil(end)
        XCTAssertEqual(
            service.endDate?.timeIntervalSinceNow ?? 0,
            25 * 60,
            accuracy: 2,
            "The end date is what the countdown is derived from"
        )
    }

    /// The drift bug. The old implementation subtracted one second per tick,
    /// so time spent suspended in the background simply didn't count and a
    /// 25-minute session could take an hour of wall clock.
    @MainActor
    func testTimeElapsedWhileSuspendedStillCounts() {
        let service = FocusTimerService(duration: 600)

        // Start as though the session began ten minutes ago — the same
        // situation as returning to a session that ran while backgrounded.
        service.start(endingAt: Date.now.addingTimeInterval(60))

        XCTAssertEqual(service.remainingSeconds, 60, accuracy: 2)
        XCTAssertEqual(service.state, .running)
    }

    @MainActor
    func testRefreshCompletesASessionWhoseEndDateHasPassed() {
        let service = FocusTimerService(duration: 600)
        var didComplete = false
        service.onComplete = { didComplete = true }

        service.start(endingAt: Date.now.addingTimeInterval(-1))
        service.refresh()

        XCTAssertTrue(didComplete, "A session that ended while away must complete, not resume")
        XCTAssertEqual(service.state, .completed)
        XCTAssertEqual(service.remainingSeconds, 0)
    }

    @MainActor
    func testFinalMinuteIsFlaggedForTheHairline() {
        let service = FocusTimerService(duration: 600)

        service.start(endingAt: Date.now.addingTimeInterval(120))
        XCTAssertFalse(service.isInFinalMinute)

        service.start(endingAt: Date.now.addingTimeInterval(30))
        XCTAssertFalse(service.isInFinalMinute, "start() is a no-op while already running")

        let fresh = FocusTimerService(duration: 600)
        fresh.start(endingAt: Date.now.addingTimeInterval(30))
        XCTAssertTrue(fresh.isInFinalMinute)
        XCTAssertEqual(fresh.finalMinuteProgress, 0.5, accuracy: 0.05)
    }

    @MainActor
    func testCancellingStopsTheCountdown() {
        let service = FocusTimerService(duration: 600)
        var didComplete = false
        service.onComplete = { didComplete = true }

        service.start()
        service.cancel()

        XCTAssertEqual(service.state, .cancelled)
        XCTAssertFalse(didComplete, "Cancelling is not completing")
    }
}
