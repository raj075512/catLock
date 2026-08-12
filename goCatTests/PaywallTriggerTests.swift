import XCTest
@testable import goCat

/// The paywall's rules are the ones most likely to be broken by a later
/// well-meaning change, and the ones most likely to be noticed by App Review
/// and by users. They are pinned here.
final class PaywallTriggerTests: XCTestCase {
    private func makeTrigger() -> PaywallTrigger {
        let defaults = UserDefaults(suiteName: "PaywallTriggerTests-\(UUID().uuidString)")!
        return PaywallTrigger(store: UserDefaultsStore(defaults: defaults))
    }

    func testDoesNotFireOnTheFirstCompletedSession() {
        let trigger = makeTrigger()

        XCTAssertFalse(
            trigger.recordCompletionAndAskToPresent(hasPlus: false),
            "One session is not enough to have felt the value"
        )
    }

    func testFiresOnTheSecondCompletedSession() {
        let trigger = makeTrigger()

        _ = trigger.recordCompletionAndAskToPresent(hasPlus: false)

        XCTAssertTrue(trigger.recordCompletionAndAskToPresent(hasPlus: false))
    }

    /// A dismissal is an answer. After one automatic showing the paywall is
    /// reachable only from Plan & Billing or by tapping a lock.
    func testNeverFiresAutomaticallyMoreThanOnce() {
        let trigger = makeTrigger()

        _ = trigger.recordCompletionAndAskToPresent(hasPlus: false)
        XCTAssertTrue(trigger.recordCompletionAndAskToPresent(hasPlus: false))

        for _ in 0..<10 {
            XCTAssertFalse(
                trigger.recordCompletionAndAskToPresent(hasPlus: false),
                "Once shown, never again automatically"
            )
        }
    }

    func testNeverFiresForSomeoneWhoAlreadyPaid() {
        let trigger = makeTrigger()

        _ = trigger.recordCompletionAndAskToPresent(hasPlus: true)

        XCTAssertFalse(trigger.recordCompletionAndAskToPresent(hasPlus: true))
        XCTAssertFalse(trigger.hasBeenShown, "A subscriber must not burn the one automatic showing")
    }

    /// Cancelled sessions never reach the trigger at all — asking for money
    /// straight after someone gave up is the worst possible read of the room.
    /// This pins the count itself, which is what the rule rests on.
    func testOnlyCompletionsAdvanceTheCount() {
        let trigger = makeTrigger()

        _ = trigger.recordCompletionAndAskToPresent(hasPlus: false)

        XCTAssertEqual(trigger.completedSessionCount, 1)
    }
}

/// The banner that warns about the first charge. Getting this wrong is the
/// difference between a subscriber and a chargeback.
final class TrialBannerPolicyTests: XCTestCase {
    private let calendar = Calendar(identifier: .gregorian)

    private func makePolicy() -> TrialBannerPolicy {
        let defaults = UserDefaults(suiteName: "TrialBannerTests-\(UUID().uuidString)")!
        return TrialBannerPolicy(store: UserDefaultsStore(defaults: defaults), calendar: calendar)
    }

    private func daysFromNow(_ days: Int) -> Date {
        calendar.date(byAdding: .day, value: days, to: .now)!
    }

    func testShowsTwoDaysBeforeTheCharge() {
        XCTAssertTrue(
            makePolicy().shouldShow(renewalDate: daysFromNow(2), isInTrial: true)
        )
    }

    func testDoesNotShowTooEarly() {
        XCTAssertFalse(
            makePolicy().shouldShow(renewalDate: daysFromNow(5), isInTrial: true),
            "Five days out is not a warning, it is a nag"
        )
    }

    func testDoesNotShowWhenThereIsNoTrial() {
        XCTAssertFalse(
            makePolicy().shouldShow(renewalDate: daysFromNow(1), isInTrial: false)
        )
    }

    func testDismissingHidesItForTheRestOfTheDay() {
        let policy = makePolicy()
        XCTAssertTrue(policy.shouldShow(renewalDate: daysFromNow(2), isInTrial: true))

        policy.dismissForToday()

        XCTAssertFalse(policy.shouldShow(renewalDate: daysFromNow(2), isInTrial: true))
    }

    /// It returns once more on the final day — dismissing is for today, not
    /// forever, because the charge is the thing being warned about.
    func testReturnsTheFollowingDay() {
        let policy = makePolicy()
        policy.dismissForToday(now: calendar.date(byAdding: .day, value: -1, to: .now)!)

        XCTAssertTrue(policy.shouldShow(renewalDate: daysFromNow(1), isInTrial: true))
    }

    func testCopyNamesTheDayAndTheAmountAndOffersTheWayOut() {
        let message = makePolicy().message(
            renewalDate: daysFromNow(2),
            price: "$79.99",
            willRenew: true
        )

        XCTAssertTrue(message.contains("$79.99"), "The amount must be stated")
        XCTAssertTrue(message.contains("unless you cancel"), "The way out comes first")
        XCTAssertFalse(message.lowercased().contains("streak"), "Never leverage the streak")
    }

    /// Already cancelled: reassure, don't sell, and drop the amount entirely.
    func testCancelledTrialCopySaysNoChargeIsComing() {
        let message = makePolicy().message(
            renewalDate: daysFromNow(2),
            price: "$79.99",
            willRenew: false
        )

        XCTAssertTrue(message.contains("won't be charged"))
        XCTAssertFalse(message.contains("$79.99"))
    }
}

/// Two tiers, and only the yearly one carries the trial.
final class PlusProductTests: XCTestCase {
    func testYearlyIsPreselectedAndCarriesTheTrial() {
        XCTAssertEqual(PlusProduct.preselected, .yearly)
        XCTAssertTrue(PlusProduct.yearly.hasIntroductoryTrial)
    }

    func testMonthlyHasNoTrial() {
        XCTAssertFalse(
            PlusProduct.monthly.hasIntroductoryTrial,
            "The monthly card says \"Billed monthly. No trial.\" and must mean it"
        )
    }

    func testThereAreExactlyTwoTiers() {
        XCTAssertEqual(PlusProduct.allCases.count, 2)
        XCTAssertEqual(PlusProduct.identifiers.count, 2)
    }

    func testYearlySortsFirst() {
        XCTAssertLessThan(PlusProduct.yearly.displayOrder, PlusProduct.monthly.displayOrder)
    }
}
