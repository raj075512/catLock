import XCTest
@testable import goCat

final class HomeViewModelTests: XCTestCase {
    @MainActor
    func testDefaultSessionDurationIsTwentyFiveMinutes() {
        let viewModel = HomeViewModel()

        XCTAssertEqual(viewModel.sessionDuration, 25 * 60)
    }
}
