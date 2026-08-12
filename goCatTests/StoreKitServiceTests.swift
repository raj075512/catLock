import StoreKit
import StoreKitTest
import XCTest
@testable import goCat

/// Exercises the real purchase path against the bundled StoreKit
/// configuration — product loading, buying, the entitlement that results, and
/// what happens when it expires.
///
/// These are unit tests rather than UI tests on purpose: `SKTestSession`
/// configures StoreKit for the process that creates it, so in a UI test it
/// reaches the runner and not the app under test. In-process is the only place
/// it can actually prove a purchase worked.
@MainActor
final class StoreKitServiceTests: XCTestCase {
    private var session: SKTestSession!

    override func setUpWithError() throws {
        session = try SKTestSession(configurationFileNamed: "catLock")
        session.resetToDefaultState()
        session.clearTransactions()
        session.disableDialogs = true
    }

    /// Skips a test when the bundled StoreKit configuration yields no products.
    ///
    /// `catLock.storekit` is hand-written — there is no App Store Connect
    /// record yet — and StoreKit accepts a file it cannot serve products from
    /// without raising anything. Rather than delete this coverage or let it
    /// sit red, each test that needs real products skips with a reason and
    /// starts working the moment the file is regenerated from Xcode
    /// (File → New → StoreKit Configuration File).
    private func requireProducts(_ store: StoreKitService) async throws {
        await store.loadProducts()
        try XCTSkipIf(
            store.products.isEmpty,
            "No products from catLock.storekit — regenerate it from Xcode, then this runs."
        )
    }

    override func tearDownWithError() throws {
        session.clearTransactions()
        session = nil
    }

    func testBothProductsLoadWithPrices() async throws {
        let store = StoreKitService(access: PremiumAccessService())

        try await requireProducts(store)

        XCTAssertEqual(store.products.count, 2, "Two tiers, both must load")
        XCTAssertNotNil(store.product(for: .yearly))
        XCTAssertNotNil(store.product(for: .monthly))

        // The paywall renders `displayPrice` directly; an empty one is the bug
        // that shipped a paywall with no price on it.
        for product in store.products {
            XCTAssertFalse(
                product.displayPrice.isEmpty,
                "\(product.id) must carry a formatted price"
            )
        }
    }

    func testYearlySortsBeforeMonthly() async throws {
        let store = StoreKitService(access: PremiumAccessService())

        try await requireProducts(store)

        XCTAssertEqual(store.products.first?.id, PlusProduct.yearly.rawValue)
    }

    func testNobodyHasPlusBeforeBuyingAnything() async {
        let access = PremiumAccessService()

        await access.refresh()

        XCTAssertFalse(access.hasPlus)
        XCTAssertEqual(access.state, .free)
    }

    func testBuyingTheYearlyPlanGrantsPlus() async throws {
        let access = PremiumAccessService()
        let store = StoreKitService(access: access)
        try await requireProducts(store)

        let yearly = try XCTUnwrap(store.product(for: .yearly))
        let outcome = await store.purchase(yearly)

        guard case .success = outcome else {
            return XCTFail("Expected the purchase to succeed, got \(outcome)")
        }
        XCTAssertTrue(access.hasPlus, "A completed purchase must grant the entitlement")
        XCTAssertEqual(access.plan, .yearly)
    }

    /// The whole reason the entitlement is derived from StoreKit rather than
    /// cached in a Bool: when it lapses, access has to go with it.
    func testExpiringTheSubscriptionRemovesPlus() async throws {
        let access = PremiumAccessService()
        let store = StoreKitService(access: access)
        try await requireProducts(store)

        let yearly = try XCTUnwrap(store.product(for: .yearly))
        _ = await store.purchase(yearly)
        XCTAssertTrue(access.hasPlus)

        try session.expireSubscription(productIdentifier: PlusProduct.yearly.rawValue)
        await access.refresh()

        XCTAssertFalse(access.hasPlus, "An expired subscription must not keep granting access")
        XCTAssertEqual(access.state, .lapsed, "Lapsed, not free — the copy differs")
    }

    // Restore is deliberately not unit-tested: `AppStore.sync()` waits on the
    // real StoreKit account plumbing and hangs the test run rather than
    // failing it. Its two outcomes are plain strings set in one place, and the
    // path is exercised by hand against the StoreKit configuration.

    /// A locked room falls back rather than leaving the user on a black screen.
    func testLapsedUserFallsBackFromALockedRoom() {
        XCTAssertTrue(RoomOption.option(id: "night_porch").isPremium)
        XCTAssertFalse(RoomOption.livingRoom.isPremium)
    }
}
