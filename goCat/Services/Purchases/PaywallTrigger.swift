import Foundation

/// Decides whether the paywall may appear, and remembers that it did.
///
/// The rules it enforces, all of them deliberate:
///
/// - **After the second completed session**, on top of the completion screen —
///   not instead of it. The user has just felt the value and has a streak
///   worth keeping, which is the highest-intent moment the app has.
/// - **Never during a session.** Not once, not for anything.
/// - **Never on a cancelled session.** Asking for money immediately after
///   someone gave up is the worst possible read of the room.
/// - **Once, automatically.** A dismissal is an answer. Afterwards the paywall
///   is reachable only from Plan & Billing or by tapping a lock.
///
/// `MONETIZATION.md` previously carried a contradicting rule — "never show a
/// paywall on the completion screen" — while the wireframe specified exactly
/// that. The wireframe won; the rule has been rewritten rather than left to
/// disagree with the code.
struct PaywallTrigger {
    /// Completed sessions after which the paywall may fire.
    static let completionsBeforePaywall = 2

    private enum Keys {
        static let completedSessionCount = "completedSessionCount"
        static let paywallHasBeenShown = "paywallHasBeenShown"
    }

    private let store: UserDefaultsStore

    init(store: UserDefaultsStore = .shared) {
        self.store = store
    }

    var completedSessionCount: Int {
        get { store.value(forKey: Keys.completedSessionCount, fallback: 0) }
        nonmutating set { store.set(newValue, forKey: Keys.completedSessionCount) }
    }

    var hasBeenShown: Bool {
        get { store.value(forKey: Keys.paywallHasBeenShown, fallback: false) }
        nonmutating set { store.set(newValue, forKey: Keys.paywallHasBeenShown) }
    }

    /// Call once per completed session. Returns whether the paywall should be
    /// presented on top of the completion screen.
    func recordCompletionAndAskToPresent(hasPlus: Bool) -> Bool {
        completedSessionCount += 1

        guard !hasPlus, !hasBeenShown else { return false }
        guard completedSessionCount >= Self.completionsBeforePaywall else { return false }

        hasBeenShown = true
        return true
    }

    /// Test seam.
    func reset() {
        store.removeValue(forKey: Keys.completedSessionCount)
        store.removeValue(forKey: Keys.paywallHasBeenShown)
    }
}
