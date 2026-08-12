import StoreKit
import SwiftUI

/// Screens 41, 42 and 43 — free, active, in-trial and lapsed.
///
/// One view because they share one layout: only the plan line, the explanatory
/// sentence and the single action change between them.
///
/// Two things here are compliance, not styling:
///
/// - **Restore Purchases is above the fold and works signed out.** Entitlements
///   belong to the Apple Account, not to a catLock account, and the caption
///   says so — "sign in to restore" is the single most common paid-app support
///   ticket, and this app has no sign-in at all.
/// - **Manage Subscription goes straight to Apple's sheet.** Between this
///   screen and cancellation there is no retention interstitial, no discount
///   offer, no "before you go" survey and no confirmation dialog.
struct PlanAndBillingView: View {
    @Environment(\.openURL) private var openURL

    private var store: StoreKitService { StoreKitService.shared }
    private var access: PremiumAccessService { PremiumAccessService.shared }

    @State private var isShowingPaywall = false
    @State private var isShowingManageSubscriptions = false

    var body: some View {
        PushedScreen(title: "Plan & Billing") {
            VStack(spacing: AppSpacing.large) {
                currentPlanCard

                switch access.state {
                case .free:
                    plusAddsCard
                    upgradeButton
                case .trial, .subscribed:
                    manageButton
                case .lapsed:
                    resubscribeButton
                }

                restoreSection
                legalLinks
            }
            .padding(.top, AppSpacing.medium)
        }
        .task { await store.loadProducts() }
        .sheet(isPresented: $isShowingPaywall) { PaywallView() }
        .manageSubscriptionsSheet(isPresented: $isShowingManageSubscriptions)
    }

    // MARK: - Current plan

    private var currentPlanCard: some View {
        ProgressCard {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                Text("Current plan")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)

                // Renewal date and price sit in 16pt body, not caption — a
                // subscriber should never have to hunt for what they pay.
                Text(planTitle)
                    .font(AppFonts.headline)
                    .foregroundStyle(AppColors.textPrimary)

                if let detail = planDetail {
                    Text(detail)
                        .font(AppFonts.body)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if case .free = access.state {
                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        ForEach(freeIncludes, id: \.self) { line in
                            HStack(spacing: AppSpacing.small) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(AppColors.accent)
                                Text(line)
                                    .font(AppFonts.caption)
                                    .foregroundStyle(AppColors.textPrimary)
                                Spacer(minLength: 0)
                            }
                        }
                    }
                    .padding(.top, AppSpacing.small)
                }
            }
        }
    }

    /// States what Free already *is* before saying what it isn't. Nothing in
    /// the core loop sits on the Plus side.
    private let freeIncludes = [
        "Unlimited sessions, any length",
        "Streaks, tasks and weekly stats",
        "Three sounds, three rooms"
    ]

    private var planTitle: String {
        switch access.state {
        case .free:
            return "Free"
        case .trial(_, let renewal):
            return "Free trial · ends \(formatted(renewal))"
        case .subscribed(let plan, _, let willRenew):
            let period = plan == .yearly ? "Yearly" : "Monthly"
            return willRenew ? "catLock Plus · \(period)" : "catLock Plus · \(period) · won't renew"
        case .lapsed:
            return "Plus expired"
        }
    }

    private var planDetail: String? {
        switch access.state {
        case .free:
            return nil
        case .trial(let plan, let renewal):
            let price = store.product(for: plan)?.displayPrice ?? ""
            return "On \(formatted(renewal)) you'll be charged \(price)\(plan == .yearly ? " for one year" : ""), unless you cancel."
        case .subscribed(let plan, let renewal, let willRenew):
            let price = store.product(for: plan)?.displayPrice ?? ""
            let period = plan == .yearly ? "year" : "month"
            return willRenew
                ? "Renews \(formatted(renewal)) · \(price)/\(period)"
                : "Ends \(formatted(renewal)) · won't renew"
        case .lapsed:
            // Leads with what is *not* lost. The fear is that expiry deletes
            // history; it doesn't, and that sentence comes first.
            return "Your sessions, streak and tasks are all untouched — only the extra sounds and rooms are locked."
        }
    }

    private func formatted(_ date: Date?) -> String {
        guard let date else { return "renewal" }
        return date.formatted(.dateTime.day().month(.wide))
    }

    // MARK: - What Plus adds

    private var plusAddsCard: some View {
        ProgressCard {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                Text("catLock Plus adds")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)

                // Only what exists. Advanced stats and the widget appear on
                // the drawn screen but are not built, and charging for an
                // absent feature is a Guideline 3.1.2 problem.
                ForEach(["All six ambient sounds", "All six rooms"], id: \.self) { line in
                    HStack(spacing: AppSpacing.small) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(AppColors.primary)
                        Text(line)
                            .font(AppFonts.body)
                            .foregroundStyle(AppColors.textPrimary)
                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private var upgradeButton: some View {
        VStack(spacing: AppSpacing.small) {
            CapsuleButton("Upgrade to Plus", style: .accent) { isShowingPaywall = true }

            if let yearly = store.product(for: .yearly) {
                Text("From \(yearly.displayPrice)/year. 7-day free trial.")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }

    private var manageButton: some View {
        VStack(spacing: AppSpacing.small) {
            CapsuleButton("Manage Subscription", style: .primary) {
                isShowingManageSubscriptions = true
            }

            Text(manageCaption)
                .font(AppFonts.caption)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// Says where the button goes before it is pressed, and sets expectations
    /// about what cancelling actually does.
    private var manageCaption: String {
        switch access.state {
        case .trial(_, let renewal):
            return "Cancel any time before \(formatted(renewal)) and you won't be charged. Plus stays on until then."
        case .subscribed(_, let renewal, _):
            return "Manage Subscription opens Apple's subscription settings, where you can change plan or cancel. Cancelling keeps Plus until \(formatted(renewal))."
        default:
            return "Manage Subscription opens Apple's subscription settings."
        }
    }

    private var resubscribeButton: some View {
        CapsuleButton("Resubscribe", style: .accent) { isShowingPaywall = true }
    }

    // MARK: - Restore

    private var restoreSection: some View {
        VStack(spacing: AppSpacing.small) {
            Button {
                Task { await store.restorePurchases() }
            } label: {
                Text("Restore Purchases")
                    .font(AppFonts.headline)
                    .foregroundStyle(AppColors.primary)
                    .frame(minHeight: AppLayout.minimumTapTarget)
            }
            .disabled(store.isProcessing)

            // Plain line, never a dialog — including on failure.
            if let message = store.restoreMessage {
                Text(message)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Text("Already subscribed on another device? Restore works without an account — purchases live with your Apple Account.")
                .font(AppFonts.caption)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var legalLinks: some View {
        HStack(spacing: AppSpacing.large) {
            Button("Terms") { open("https://catlock.app/terms") }
            Button("Privacy") { open("https://catlock.app/privacy") }
        }
        .font(AppFonts.caption)
        .foregroundStyle(AppColors.primary)
    }

    private func open(_ string: String) {
        guard let url = URL(string: string) else { return }
        openURL(url)
    }
}

#Preview {
    NavigationStack { PlanAndBillingView() }
}
