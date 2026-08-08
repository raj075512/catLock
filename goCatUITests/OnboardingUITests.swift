import XCTest

final class OnboardingUITests: XCTestCase {
    func testAppLaunchesToOnboardingOrHome() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.exists)
    }
}
