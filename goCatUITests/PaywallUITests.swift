import XCTest

/// The paywall is the screen most likely to fail App Review, so its
/// non-negotiable furniture is asserted rather than eyeballed: a close button
/// that is present immediately, the auto-renewal disclosure, Restore, Terms
/// and Privacy — all reachable without scrolling past them.
///
/// Prices come from the bundled StoreKit configuration referenced by the
/// scheme, so these run without an App Store Connect record.
final class PaywallUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    private func launchToPaywallViaSounds() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-resetState"]
        app.launch()

        // Through onboarding to Home.
        let getStarted = app.buttons["Get started"]
        XCTAssertTrue(getStarted.waitForExistence(timeout: 10))
        getStarted.tap()

        XCTAssertTrue(app.staticTexts["How did you hear about catLock?"].waitForExistence(timeout: 5))
        app.buttons["Skip"].tap()
        XCTAssertTrue(app.staticTexts["How it works"].waitForExistence(timeout: 5))
        app.buttons["Got it"].tap()
        XCTAssertTrue(app.buttons["Start focusing"].waitForExistence(timeout: 5))
        app.buttons["Start focusing"].tap()
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 5))
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.buttons["Continue"].waitForExistence(timeout: 5))
        app.buttons["Continue"].tap()

        // A locked sound is clear intent, so it opens the paywall.
        XCTAssertTrue(app.buttons["quickActionSounds"].waitForExistence(timeout: 5))
        app.buttons["quickActionSounds"].tap()
        XCTAssertTrue(app.staticTexts["Sounds"].waitForExistence(timeout: 5))
        app.buttons["Fireplace"].firstMatch.tap()

        return app
    }

    @MainActor
    func testLockedSoundOpensThePaywall() {
        let app = launchToPaywallViaSounds()

        XCTAssertTrue(app.staticTexts["catLock Plus"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Two sessions in. Here's what's behind the locks."].exists)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "30-paywall"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Every one of these is a rejection risk if it goes missing.
    @MainActor
    func testPaywallCarriesItsRequiredLegalFurniture() {
        let app = launchToPaywallViaSounds()
        XCTAssertTrue(app.staticTexts["catLock Plus"].waitForExistence(timeout: 10))

        XCTAssertTrue(app.buttons["Close"].exists, "Close must be present immediately, never delayed")
        XCTAssertTrue(app.buttons["Restore Purchases"].exists)
        XCTAssertTrue(app.links["Terms"].exists || app.buttons["Terms"].exists)
        XCTAssertTrue(app.links["Privacy"].exists || app.buttons["Privacy"].exists)

        // The auto-renewal disclosure, stated in full.
        let disclosure = app.staticTexts.containing(
            NSPredicate(format: "label CONTAINS[c] %@", "until you cancel")
        ).firstMatch
        XCTAssertTrue(disclosure.exists, "The auto-renewal disclosure must be on screen")
    }

    /// Prices are deliberately *not* asserted here.
    ///
    /// Under `xcodebuild`, StoreKit's test configuration does not reach the
    /// app process — the scheme reference only applies when Xcode launches it,
    /// and `SKTestSession` configures the runner rather than the app under
    /// test. The first version of this file asserted only copy that exists in
    /// the no-products fallback, so it passed against a paywall showing no
    /// price at all. Purchase, pricing and entitlement are covered in-process
    /// by `StoreKitServiceTests` instead, where they can actually be proven.
    ///
    /// What is worth asserting here is the state this environment *does*
    /// produce, because it is also what a user sees when the App Store is
    /// unreachable: no dead button, and an explanation.
    @MainActor
    func testPaywallExplainsItselfWhenPricesCannotBeLoaded() {
        let app = launchToPaywallViaSounds()
        XCTAssertTrue(app.staticTexts["catLock Plus"].waitForExistence(timeout: 10))

        let priced = app.staticTexts.containing(
            NSPredicate(format: "label CONTAINS[c] %@", "/ year")
        ).firstMatch

        if priced.waitForExistence(timeout: 5) {
            XCTAssertTrue(
                app.buttons["Start 7-day free trial"].isEnabled,
                "With prices loaded the purchase button must be live"
            )
        } else {
            XCTAssertTrue(
                app.staticTexts["Prices couldn't be loaded. Check your connection and try again."]
                    .waitForExistence(timeout: 5),
                "Without prices the paywall must say why, not show a dead button"
            )
            XCTAssertTrue(app.buttons["Try again"].exists)
        }
    }

    /// Only what exists is sold. Advertising an unbuilt widget is a Guideline
    /// 3.1.2 problem, so it must not creep back into the copy.
    @MainActor
    func testPaywallDoesNotSellFeaturesThatDoNotExist() {
        let app = launchToPaywallViaSounds()
        XCTAssertTrue(app.staticTexts["catLock Plus"].waitForExistence(timeout: 10))

        XCTAssertFalse(
            app.staticTexts["Home Screen widget"].exists,
            "There is no widget — do not sell one"
        )
        XCTAssertFalse(
            app.staticTexts["Advanced stats and history"].exists,
            "Advanced stats are not built — do not sell them"
        )
        XCTAssertTrue(app.staticTexts["All six ambient sounds"].exists)
        XCTAssertTrue(app.staticTexts["All six rooms"].exists)
    }

    /// Dismissing is an answer: no second-chance offer, no "are you sure".
    @MainActor
    func testClosingThePaywallReturnsWithoutAnUpsell() {
        let app = launchToPaywallViaSounds()
        XCTAssertTrue(app.staticTexts["catLock Plus"].waitForExistence(timeout: 10))

        app.buttons["Close"].tap()

        XCTAssertTrue(app.staticTexts["Sounds"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.alerts.element.exists, "Dismissal must not raise a retention dialog")
    }
}
