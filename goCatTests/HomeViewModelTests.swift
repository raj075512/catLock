import XCTest
@testable import goCat

final class HomeViewModelTests: XCTestCase {
    @MainActor
    func testDefaultSessionDurationIsTwentyFiveMinutes() {
        let viewModel = HomeViewModel()

        XCTAssertEqual(viewModel.selectedMinutes, 25)
        XCTAssertEqual(viewModel.sessionDuration, 25 * 60)
    }

    @MainActor
    func testSelectingPresetUpdatesSessionDuration() {
        let viewModel = HomeViewModel()

        viewModel.selectedMinutes = 45

        XCTAssertEqual(viewModel.sessionDuration, 45 * 60)
    }

    @MainActor
    func testStartedSessionUsesSelectedDuration() {
        let viewModel = HomeViewModel()
        viewModel.selectedMinutes = 15

        let session = viewModel.startFocusSession()

        XCTAssertEqual(session.plannedDuration, 15 * 60)
        XCTAssertEqual(session.state, .running)
    }
}
