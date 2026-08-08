import XCTest
@testable import goCat

final class FocusTimerServiceTests: XCTestCase {
    @MainActor
    func testResetRestoresDuration() {
        let service = FocusTimerService(duration: 60)

        service.complete()
        service.reset()

        XCTAssertEqual(service.remainingSeconds, 60)
        XCTAssertEqual(service.state, .idle)
    }
}
