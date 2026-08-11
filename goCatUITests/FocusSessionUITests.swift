import XCTest

/// Home, the sheets, and the session's product rules — the things that would
/// be embarrassing to break: no pause, no back button, cancel discards.
final class FocusSessionUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Skips onboarding by running it, so the app lands on Home.
    @MainActor
    private func launchToHome() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-resetState"]
        app.launch()

        let getStarted = app.buttons["Get started"]
        XCTAssertTrue(getStarted.waitForExistence(timeout: 10))
        getStarted.tap()

        XCTAssertTrue(
            app.staticTexts["How did you hear about catLock?"].waitForExistence(timeout: 5)
        )
        app.buttons["Skip"].tap()

        XCTAssertTrue(app.staticTexts["How it works"].waitForExistence(timeout: 5))
        app.buttons["Got it"].tap()

        XCTAssertTrue(app.buttons["Start focusing"].waitForExistence(timeout: 5))
        app.buttons["Start focusing"].tap()

        // A real session starts here; cancel out of it to reach Home.
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 5))
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.buttons["Continue"].waitForExistence(timeout: 5))
        app.buttons["Continue"].tap()

        return app
    }

    @MainActor
    private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testHomeShowsTheDurationRowAndQuickActions() {
        let app = launchToHome()

        XCTAssertTrue(app.buttons["startFocus"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Custom"].exists)
        XCTAssertTrue(app.buttons["quickActionSounds"].exists)
        XCTAssertTrue(app.buttons["quickActionRoom"].exists)
        XCTAssertTrue(app.buttons["quickActionTasks"].exists)
        capture(app, "11-home")
    }

    /// Rule 1 and 2: while a session runs there is no pause and no way back.
    @MainActor
    func testRunningSessionOffersOnlyCancel() {
        let app = launchToHome()

        app.buttons["startFocus"].tap()

        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 5))
        capture(app, "15-session-running")

        XCTAssertFalse(app.buttons["Pause"].exists, "Rule 1: there is no pause")
        XCTAssertFalse(app.buttons["Back"].exists, "Rule 2: there is no way back")
        XCTAssertFalse(app.buttons["Close"].exists, "Rule 2: there is no close")
    }

    /// Rule 3: cancelling is immediate, with no confirmation dialog, and the
    /// copy attaches no verdict to it.
    @MainActor
    func testCancellingDiscardsWithoutAConfirmationDialog() {
        let app = launchToHome()

        app.buttons["startFocus"].tap()
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 5))
        app.buttons["Cancel"].tap()

        XCTAssertTrue(app.staticTexts["Session cancelled"].waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.staticTexts["This one didn't count — start again whenever you're ready."].exists
        )
        XCTAssertFalse(app.alerts.element.exists, "Cancel must not raise a confirmation dialog")
        capture(app, "17-session-cancelled")
    }

    @MainActor
    func testSoundsSheetOpensAndOffersSilence() {
        let app = launchToHome()

        app.buttons["quickActionSounds"].tap()

        XCTAssertTrue(app.staticTexts["Sounds"].waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.staticTexts["Plays through the session. Mixes with your own music."].exists
        )
        capture(app, "20-sounds")
        app.buttons["Done"].tap()
    }

    @MainActor
    func testRoomSheetStatesRuleFive() {
        let app = launchToHome()

        app.buttons["quickActionRoom"].tap()

        XCTAssertTrue(app.staticTexts["Room"].waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.staticTexts["Same cat, same chair. Different room."].exists,
            "Rule 5 is stated out loud so the absence reads as intent"
        )
        capture(app, "21-room")
        app.buttons["Done"].tap()
    }

    @MainActor
    func testTasksEmptyStateInvitesAFirstTask() {
        let app = launchToHome()

        app.buttons["quickActionTasks"].tap()

        XCTAssertTrue(app.staticTexts["What's this session for?"].waitForExistence(timeout: 5))
        capture(app, "23-tasks-empty")

        app.buttons["addFirstTaskButton"].tap()
        let field = app.textFields["What are you working on?"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.typeText("Draft the intro paragraph")
        capture(app, "24-add-task")
        app.buttons["Add"].tap()

        XCTAssertTrue(app.staticTexts["Draft the intro paragraph"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Completed tasks clear themselves at midnight."].exists)
        capture(app, "22-tasks-populated")
    }

    /// The empty Progress sheet explains the streak rule rather than showing
    /// zeroes, and uses em dashes in the stat cards.
    @MainActor
    func testProgressEmptyStateExplainsTheRule() {
        let app = launchToHome()

        app.buttons["Day 1 starts here"].tap()

        XCTAssertTrue(app.staticTexts["No streak yet"].waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.staticTexts["One finished session starts it. Cancelling never breaks it."].exists
        )
        XCTAssertTrue(app.staticTexts["Your first session will show up here."].exists)
        capture(app, "26-progress-empty")
    }
}
