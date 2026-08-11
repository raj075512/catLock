import XCTest

/// Walks the baseline onboarding, screens 1–10, capturing each one.
///
/// The previous UI tests only asserted `app.exists`, which passes for an app
/// showing a blank screen. These drive the real flow and fail if a screen
/// stops rendering its copy.
final class OnboardingUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    private func launchFreshApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-resetState"]
        app.launch()
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
    func testBaselineOnboardingRunsThroughToTheFirstSession() {
        let app = launchFreshApp()

        // 2 · Meet the cat. The splash advances on its own.
        let getStarted = app.buttons["Get started"]
        XCTAssertTrue(getStarted.waitForExistence(timeout: 10), "Splash should advance to Meet the cat")
        capture(app, "02-meet-the-cat")
        getStarted.tap()

        // 3 · Survey 1 of 5 — source
        XCTAssertTrue(
            app.staticTexts["How did you hear about catLock?"].waitForExistence(timeout: 5)
        )
        capture(app, "03-survey-source")
        app.buttons["Reddit"].tap()

        // 4 · Survey 2 of 5 — use case
        XCTAssertTrue(app.staticTexts["What will you use it for?"].waitForExistence(timeout: 5))
        capture(app, "04-survey-use-case")
        app.buttons["Work"].tap()

        // 5 · Survey 3 of 5 — the only functional answer
        XCTAssertTrue(
            app.staticTexts["How long can you usually focus before drifting?"]
                .waitForExistence(timeout: 5)
        )
        XCTAssertTrue(app.staticTexts["A guess is fine. This sets your default session."].exists)
        capture(app, "05-survey-focus-span")
        app.buttons["15–25 min"].tap()

        // 6 · Survey 4 of 5 — hardest part
        XCTAssertTrue(app.staticTexts["What's hardest for you?"].waitForExistence(timeout: 5))
        capture(app, "06-survey-hardest")
        app.buttons["Getting started"].tap()

        // 7 · Survey 5 of 5 — time of day
        XCTAssertTrue(app.staticTexts["When do you usually focus?"].waitForExistence(timeout: 5))
        capture(app, "07-survey-time-of-day")
        app.buttons["Morning"].tap()

        // 8 · Personalised summary. Q3 was "15–25 min", so this must say 25.
        let summaryTitle = app.staticTexts["25-minute sessions it is."]
        XCTAssertTrue(summaryTitle.waitForExistence(timeout: 5), "The summary must reflect Q3")
        XCTAssertTrue(app.staticTexts["All of this stays on your phone."].exists)
        capture(app, "08-summary")
        app.buttons["Sounds good"].tap()

        // 9 · How it works
        XCTAssertTrue(app.staticTexts["How it works"].waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.staticTexts["Cancel any time. Finishing earns the streak; cancelling just doesn't."].exists,
            "Step 3 states the trade, so Cancel never reads as punishment"
        )
        capture(app, "09-how-it-works")
        app.buttons["Got it"].tap()

        // 10 · Pick your first session
        XCTAssertTrue(app.staticTexts["Your first session"].waitForExistence(timeout: 5))
        capture(app, "10-first-session")
        XCTAssertTrue(app.buttons["Start focusing"].exists)
    }

    /// Skipping jumps past the summary — a summary of answers nobody gave
    /// would be a screen of fiction.
    @MainActor
    func testSkippingTheSurveyGoesStraightToHowItWorks() {
        let app = launchFreshApp()

        let getStarted = app.buttons["Get started"]
        XCTAssertTrue(getStarted.waitForExistence(timeout: 10))
        getStarted.tap()

        XCTAssertTrue(
            app.staticTexts["How did you hear about catLock?"].waitForExistence(timeout: 5)
        )
        app.buttons["Skip"].tap()

        XCTAssertTrue(app.staticTexts["How it works"].waitForExistence(timeout: 5))
        XCTAssertFalse(
            app.staticTexts["Here's what your answers changed."].exists,
            "The summary must be skipped when the survey was"
        )
    }
}
