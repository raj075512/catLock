import XCTest
@testable import goCat

@MainActor
final class FocusSessionViewModelTests: XCTestCase {
    func testSessionStartsRunning() {
        let viewModel = FocusSessionViewModel(minutes: 25, sound: nil, room: .livingRoom)

        XCTAssertEqual(viewModel.outcome, .running)
        XCTAssertEqual(viewModel.minutes, 25)
    }

    func testCancellingDiscardsWithoutCompleting() {
        let viewModel = FocusSessionViewModel(minutes: 25, sound: nil, room: .livingRoom)

        viewModel.start()
        viewModel.cancel()

        XCTAssertEqual(viewModel.outcome, .cancelled)
        XCTAssertEqual(
            viewModel.streakAfterCompletion,
            0,
            "Rule 3: cancelling never touches the streak"
        )
    }

    func testCountdownIsFormattedAsMinutesAndSeconds() {
        let viewModel = FocusSessionViewModel(minutes: 25, sound: nil, room: .livingRoom)

        XCTAssertEqual(viewModel.formattedRemainingTime, "25:00")
    }

    /// A session longer than an hour needs the hour component, or 1h20m reads
    /// as 20 minutes.
    func testLongSessionsShowHours() {
        let viewModel = FocusSessionViewModel(minutes: 80, sound: nil, room: .livingRoom)

        XCTAssertEqual(viewModel.formattedRemainingTime, "1:20:00")
    }

    /// A restored session adopts the original end date rather than restarting
    /// the clock — force-quitting is not a way out of a session.
    func testRestoredSessionResumesTheOriginalEndDate() {
        let endDate = Date.now.addingTimeInterval(300)
        let viewModel = FocusSessionViewModel(
            minutes: 25,
            sound: nil,
            room: .livingRoom,
            restoring: ActiveSession(endDate: endDate, minutes: 25, soundID: nil)
        )

        viewModel.start()

        XCTAssertEqual(viewModel.timerService.endDate, endDate)
        XCTAssertEqual(viewModel.timerService.remainingSeconds, 300, accuracy: 2)
    }
}
