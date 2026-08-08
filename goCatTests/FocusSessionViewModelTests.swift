import XCTest
@testable import goCat

final class FocusSessionViewModelTests: XCTestCase {
    @MainActor
    func testStartMarksSessionRunning() {
        let viewModel = FocusSessionViewModel()

        viewModel.start()

        XCTAssertEqual(viewModel.session.state, .running)
    }
}
