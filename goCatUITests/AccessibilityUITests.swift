import XCTest

final class AccessibilityUITests: XCTestCase {
    func testAppExposesLaunchApplication() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.exists)
    }
}
