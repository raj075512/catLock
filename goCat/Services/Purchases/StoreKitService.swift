import Foundation
import Observation
import StoreKit
// Required explicitly: the target builds with
// SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY, so `os`'s string-
// interpolation members (the `privacy:` argument) are not visible
// transitively through AppLogger.
import os

/// Everything that talks to StoreKit.
///
/// StoreKit 2 directly rather than RevenueCat: one platform, two products, one
/// entitlement. There is no server to verify against and nothing to reconcile,
/// so a dependency would buy a dashboard and cost a third-party privacy
/// disclosure on an app whose entire pitch is that it collects nothing.
///
/// Entitlements live on the **Apple Account**, not on a catLock account —
/// which is what lets Restore Purchases work while signed out, and why the
/// Plan & Billing screen says so in as many words.
@MainActor
@Observable
final class StoreKitService {
    static let shared = StoreKitService()

    private(set) var products: [Product] = []
    private(set) var isLoadingProducts = false
    /// Set while a purchase or restore is in flight, so the paywall button can
    /// show progress and refuse to be tapped twice.
    private(set) var isProcessing = false

    /// Result of the last Restore Purchases tap. Shown as a plain line on the
    /// screen — never a dialog, including on failure.
    private(set) var restoreMessage: String?

    private let access: PremiumAccessService
    private var updatesTask: Task<Void, Never>?

    init(access: PremiumAccessService = .shared) {
        self.access = access
        listenForTransactions()
    }

    // No `deinit` cancelling `updatesTask`: this is a singleton that lives as
    // long as the process, and the listener is meant to outlive every screen —
    // a renewal or a family-sharing grant can arrive at any moment. A
    // main-actor-isolated property can't be touched from `deinit` anyway.

    // MARK: - Products

    func loadProducts() async {
        guard !LaunchFlags.isUITesting else { return }
        guard products.isEmpty, !isLoadingProducts else { return }
        isLoadingProducts = true
        defer { isLoadingProducts = false }

        do {
            let loaded = try await Product.products(for: PlusProduct.identifiers)
            products = loaded.sorted {
                (PlusProduct(rawValue: $0.id)?.displayOrder ?? 99)
                    < (PlusProduct(rawValue: $1.id)?.displayOrder ?? 99)
            }
        } catch {
            // The paywall stays dismissible and the app stays usable — every
            // feature behind this is an extra, not the core loop.
            AppLogger.purchases.error("Could not load products: \(error.localizedDescription, privacy: .public)")
        }
    }

    func product(for plan: PlusProduct) -> Product? {
        products.first { $0.id == plan.rawValue }
    }

    // MARK: - Purchase

    enum PurchaseOutcome {
        case success
        case userCancelled
        case pending
        case failed(String)
    }

    func purchase(_ product: Product) async -> PurchaseOutcome {
        guard !isProcessing else { return .userCancelled }
        isProcessing = true
        defer { isProcessing = false }

        do {
            switch try await product.purchase() {
            case .success(let verification):
                guard let transaction = verified(verification) else {
                    return .failed("That purchase could not be verified.")
                }
                await transaction.finish()
                await access.refresh()
                return .success

            case .userCancelled:
                return .userCancelled

            case .pending:
                // Ask to Buy, or a payment needing action. The entitlement
                // arrives later through `Transaction.updates`.
                return .pending

            @unknown default:
                return .failed("That purchase could not be completed.")
            }
        } catch {
            AppLogger.purchases.error("Purchase failed: \(error.localizedDescription, privacy: .public)")
            return .failed("That purchase could not be completed.")
        }
    }

    // MARK: - Restore

    /// Runs the restore in place and reports with a plain line either way.
    func restorePurchases() async {
        guard !isProcessing else { return }
        isProcessing = true
        defer { isProcessing = false }

        restoreMessage = nil

        do {
            try await AppStore.sync()
            await access.refresh()
            restoreMessage = access.hasPlus
                ? "Plus restored."
                : "Nothing to restore on this Apple Account."
        } catch {
            AppLogger.purchases.error("Restore failed: \(error.localizedDescription, privacy: .public)")
            restoreMessage = "Couldn't reach the App Store. Try again in a moment."
        }
    }

    func clearRestoreMessage() {
        restoreMessage = nil
    }

    // MARK: - Transaction updates

    /// A long-lived listener, started once.
    ///
    /// This is how an entitlement arrives when it wasn't this device that
    /// bought it: a renewal, a family-sharing grant, an Ask to Buy approval,
    /// or a purchase made on another device.
    private func listenForTransactions() {
        updatesTask?.cancel()
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                guard let self else { return }
                guard let transaction = await self.verified(update) else { continue }
                await transaction.finish()
                await self.access.refresh()
            }
        }
    }

    private func verified<T>(_ result: VerificationResult<T>) -> T? {
        switch result {
        case .verified(let value):
            return value
        case .unverified(_, let error):
            AppLogger.purchases.error("Unverified transaction: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
}
