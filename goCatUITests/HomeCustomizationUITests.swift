import XCTest

final class HomeCustomizationUITests: XCTestCase {
    func testAppCanLaunchForHomeCustomization() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.exists)
    }
}
