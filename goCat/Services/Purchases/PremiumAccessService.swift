import Foundation
import Observation
import StoreKit

/// The single source of truth for "does this person have Plus".
///
/// Was a `Bool` with a setter nobody ever called. It is now derived from
/// `Transaction.currentEntitlements` — StoreKit's own answer — so there is no
/// local flag that can drift out of step with what Apple thinks, and nothing
/// to keep in sync when a subscription renews, lapses or is refunded.
///
/// Deliberately *not* persisted. A cached entitlement is a cached wrong answer
/// the moment a subscription lapses, and the free tier is a complete app —
/// there is no offline state worth protecting with a stale flag.
@MainActor
@Observable
final class PremiumAccessService {
    static let shared = PremiumAccessService()

    /// The subscription state, as far as StoreKit is concerned.
    enum State: Equatable {
        case free
        /// Inside the seven-day introductory offer. `renewalDate` is when the
        /// first charge lands.
        case trial(plan: PlusProduct, renewalDate: Date?)
        case subscribed(plan: PlusProduct, renewalDate: Date?, willRenew: Bool)
        /// Had Plus, doesn't now. Sessions, streak and tasks are untouched —
        /// only the extra sounds and rooms lock.
        case lapsed
    }

    private(set) var state: State = .free
    private(set) var hasCheckedOnce = false

    var hasPlus: Bool {
        switch state {
        case .trial, .subscribed: true
        case .free, .lapsed: false
        }
    }

    var isInTrial: Bool {
        if case .trial = state { return true }
        return false
    }

    var renewalDate: Date? {
        switch state {
        case .trial(_, let date), .subscribed(_, let date, _): date
        case .free, .lapsed: nil
        }
    }

    var plan: PlusProduct? {
        switch state {
        case .trial(let plan, _), .subscribed(let plan, _, _): plan
        case .free, .lapsed: nil
        }
    }

    /// Re-read the entitlement from StoreKit. Call on launch, on foreground,
    /// and after any purchase or restore.
    func refresh() async {
        guard !LaunchFlags.isUITesting else {
            state = .free
            hasCheckedOnce = true
            return
        }

        var resolved: State = hasEverSubscribed ? .lapsed : .free

        for await entitlement in Transaction.currentEntitlements {
            guard case .verified(let transaction) = entitlement,
                  let plan = PlusProduct(rawValue: transaction.productID) else { continue }

            // A revoked or expired transaction still appears here; only a
            // live one grants access.
            if let revocation = transaction.revocationDate, revocation <= .now { continue }
            if let expiry = transaction.expirationDate, expiry <= .now { continue }

            hasEverSubscribed = true

            let status = await subscriptionStatus(for: transaction)
            resolved = status.isInTrial
                ? .trial(plan: plan, renewalDate: transaction.expirationDate)
                : .subscribed(
                    plan: plan,
                    renewalDate: transaction.expirationDate,
                    willRenew: status.willRenew
                )
            break
        }

        state = resolved
        hasCheckedOnce = true
    }

    private func subscriptionStatus(
        for transaction: Transaction
    ) async -> (isInTrial: Bool, willRenew: Bool) {
        guard let statuses = try? await transaction.subscriptionStatus,
              case .verified(let renewalInfo) = statuses.renewalInfo else {
            return (false, true)
        }

        let isInTrial = renewalInfo.offerType == .introductory
        return (isInTrial, renewalInfo.willAutoRenew)
    }

    /// Distinguishes "never subscribed" from "subscribed and lapsed", which
    /// the Plan & Billing screen needs — the lapsed copy leads by reassuring
    /// that history is intact, and that would read as nonsense to someone who
    /// never paid.
    private var hasEverSubscribed: Bool {
        get { UserDefaults.standard.bool(forKey: "hasEverSubscribed") }
        set { UserDefaults.standard.set(newValue, forKey: "hasEverSubscribed") }
    }

    /// Test seam. Production code always goes through `refresh()`.
    func override(_ state: State) {
        self.state = state
        hasCheckedOnce = true
    }
}
