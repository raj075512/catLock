import XCTest

final class FocusSessionUITests: XCTestCase {
    func testAppCanLaunchForFocusSession() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.exists)
    }
}
