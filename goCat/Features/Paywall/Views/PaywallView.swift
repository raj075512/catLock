import StoreKit
import SwiftUI

/// Screen 30. catLock Plus.
///
/// This screen is the one most likely to fail App Review, so its furniture is
/// not negotiable and none of it is behind a scroll:
///
/// - The close button is top-left, full size, and **never delayed**.
/// - The yearly price is the largest, boldest type on the screen — larger than
///   the title, larger than the monthly price, larger than the button.
/// - The full auto-renewal disclosure, Restore Purchases, Terms and Privacy
///   all sit above the fold.
/// - Dismissing is an answer. No second-chance offer, no "are you sure".
///
/// It sells what was already visibly locked in the Sounds and Room sheets
/// rather than introducing new promises. The wireframe also listed advanced
/// stats and a Home Screen widget; neither exists, and charging for an absent
/// feature is a Guideline 3.1.2 rejection, so both lines are omitted until
/// they are built. See `DECISIONS.md`.
struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss

    private var store: StoreKitService { StoreKitService.shared }
    private var access: PremiumAccessService { PremiumAccessService.shared }

    @State private var selection: PlusProduct = .preselected
    @State private var errorMessage: String?

    /// Only the six sounds and six rooms — both real, both already locked in
    /// the app where the user has seen them.
    private let perks = [
        "All six ambient sounds",
        "All six rooms"
    ]

    var body: some View {
        ZStack(alignment: .topLeading) {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.large) {
                    header
                    perkList
                    planCards
                    purchaseButton
                    disclosure
                    legalRow
                }
                .padding(.horizontal, AppSpacing.medium)
                .padding(.top, 72)
                .padding(.bottom, AppSpacing.large)
            }

            closeButton
        }
        .task {
            await store.loadProducts()
        }
        .onDisappear {
            store.clearRestoreMessage()
        }
    }

    // MARK: - Chrome

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)
                .frame(width: AppLayout.minimumTapTarget, height: AppLayout.minimumTapTarget)
                .contentShape(Rectangle())
        }
        .padding(.leading, AppSpacing.small)
        .padding(.top, AppSpacing.small)
        .accessibilityLabel("Close")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text("catLock Plus")
                .largeTitleTracking()
                .foregroundStyle(AppColors.textPrimary)

            Text("Two sessions in. Here's what's behind the locks.")
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var perkList: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            ForEach(perks, id: \.self) { perk in
                HStack(spacing: AppSpacing.medium) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppColors.accent)
                        .frame(width: 20)

                    Text(perk)
                        .font(AppFonts.body)
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer(minLength: 0)
                }
            }
        }
    }

    // MARK: - Plans

    private var planCards: some View {
        VStack(spacing: AppSpacing.small) {
            ForEach(PlusProduct.allCases.sorted { $0.displayOrder < $1.displayOrder }, id: \.self) { plan in
                planCard(plan)
            }
        }
    }

    private func planCard(_ plan: PlusProduct) -> some View {
        let product = store.product(for: plan)
        let isSelected = selection == plan

        return Button {
            withAnimation(AppAnimation.quick) { selection = plan }
            HapticManager.shared.selection()
        } label: {
            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                // The price is the largest, boldest thing on the screen.
                Text(priceHeadline(for: plan, product: product))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text(priceCaption(for: plan, product: product))
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.medium)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                    .fill(isSelected ? AppColors.selectedRowTint : AppColors.surface)
            )
            .overlay {
                RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                    .strokeBorder(
                        isSelected ? AppColors.primary : AppColors.hairline,
                        lineWidth: isSelected ? 1.5 : 1
                    )
            }
            .contentShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private func priceHeadline(for plan: PlusProduct, product: Product?) -> String {
        guard let product else {
            return plan == .yearly ? "Yearly" : "Monthly"
        }
        return plan == .yearly
            ? "\(product.displayPrice) / year"
            : "\(product.displayPrice) / month"
    }

    private func priceCaption(for plan: PlusProduct, product: Product?) -> String {
        guard let product else {
            return plan == .yearly ? "7 days free, then billed yearly." : "Billed monthly. No trial."
        }

        switch plan {
        case .yearly:
            let monthly = monthlyEquivalent(for: product)
            return "7 days free, then \(product.displayPrice) billed yearly\(monthly.map { " · \($0)/month equivalent" } ?? "")"
        case .monthly:
            return "Billed monthly. No trial."
        }
    }

    /// The per-month equivalent of the yearly price, formatted in the same
    /// currency StoreKit gave us — never hand-converted.
    private func monthlyEquivalent(for product: Product) -> String? {
        let perMonth = product.price / 12
        return perMonth.formatted(product.priceFormatStyle)
    }

    // MARK: - Purchase

    private var purchaseButton: some View {
        VStack(spacing: AppSpacing.small) {
            if store.product(for: selection) == nil && !store.isLoadingProducts {
                // Never a dead button. If the App Store can't be reached the
                // screen says so and offers a retry, rather than showing a
                // greyed-out control next to a card with no price on it.
                Text("Prices couldn't be loaded. Check your connection and try again.")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                CapsuleButton("Try again", style: .outlined) {
                    Task { await store.loadProducts() }
                }
            } else {
                CapsuleButton(
                    buttonTitle,
                    style: .accent,
                    isEnabled: !store.isProcessing && store.product(for: selection) != nil
                ) {
                    Task { await buy() }
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.warning)
                    .multilineTextAlignment(.center)
            }
        }
    }

    /// Relabels with the selection, so the button always says what it will do.
    private var buttonTitle: String {
        guard let product = store.product(for: selection) else {
            return selection.hasIntroductoryTrial ? "Start 7-day free trial" : "Subscribe"
        }
        return selection.hasIntroductoryTrial
            ? "Start 7-day free trial"
            : "Subscribe for \(product.displayPrice)/month"
    }

    private func buy() async {
        guard let product = store.product(for: selection) else { return }
        errorMessage = nil

        switch await store.purchase(product) {
        case .success:
            HapticManager.shared.success()
            dismiss()
        case .userCancelled:
            break
        case .pending:
            errorMessage = "That purchase is waiting for approval. Plus turns on as soon as it clears."
        case .failed(let message):
            errorMessage = message
        }
    }

    // MARK: - Legal

    /// Full auto-renewal disclosure, above the fold, at caption size beneath
    /// the price rather than hidden behind a scroll or a link.
    private var disclosure: some View {
        Text(disclosureText)
            .font(AppFonts.caption)
            .foregroundStyle(AppColors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var disclosureText: String {
        let price = store.product(for: .yearly)?.displayPrice ?? "the yearly price"
        if selection.hasIntroductoryTrial {
            return "Your free trial lasts 7 days, then \(price) is charged to your Apple Account yearly until you cancel. Cancel any time in Settings, at least 24 hours before renewal."
        }
        let monthly = store.product(for: .monthly)?.displayPrice ?? "the monthly price"
        return "\(monthly) is charged to your Apple Account monthly until you cancel. Cancel any time in Settings, at least 24 hours before renewal."
    }

    private var legalRow: some View {
        VStack(spacing: AppSpacing.medium) {
            Button {
                Task {
                    await store.restorePurchases()
                    if access.hasPlus { dismiss() }
                }
            } label: {
                Text("Restore Purchases")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.primary)
            }
            .disabled(store.isProcessing)

            if let message = store.restoreMessage {
                Text(message)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: AppSpacing.large) {
                Link("Terms", destination: URL(string: "https://catlock.app/terms")!)
                Link("Privacy", destination: URL(string: "https://catlock.app/privacy")!)
            }
            .font(AppFonts.caption)
            .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    PaywallView()
}
