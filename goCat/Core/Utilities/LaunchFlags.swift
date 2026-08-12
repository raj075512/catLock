import Foundation

/// Launch arguments the UI tests pass, read in one place.
enum LaunchFlags {
    /// Set by every UI test. Two effects, both needed to make the suite
    /// deterministic:
    ///
    /// 1. Preferences reset, so each run starts at first launch — the
    ///    simulator keeps `UserDefaults` between runs otherwise.
    /// 2. StoreKit stays offline. `Product.products(for:)` and
    ///    `Transaction.currentEntitlements` reach the network when no
    ///    configuration is active, and XCUITest waits for the app to go idle
    ///    before every interaction — so those attempts turned a 21-second test
    ///    into an 81-second one and made two tests fail under parallel load
    ///    while passing in isolation.
    ///
    /// The paywall renders its prices-unavailable state in this mode, which is
    /// exactly what `PaywallUITests` asserts.
    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-resetState")
    }
}
