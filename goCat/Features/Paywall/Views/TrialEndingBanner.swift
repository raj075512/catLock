import SwiftUI

/// Screen 31. Tells someone they are about to be charged — the amount, and
/// the day — two days early.
///
/// It states the fact, offers the way out first ("unless you cancel"), and
/// asks for nothing. No countdown, no "don't lose your streak", no discount,
/// no red. A trial reminder that tries to sell is how you earn a chargeback
/// instead of a subscriber.
///
/// Sits under Home's top bar as a fourth glass object; the control panel and
/// Start Focus are untouched. Never appears during a session (rule 2).
struct TrialEndingBanner: View {
    let message: String
    /// Nil once the trial has already been cancelled — there is nothing left
    /// to manage, and the copy says so instead.
    var onManage: (() -> Void)?
    let onDismiss: () -> Void

    var body: some View {
        GlassSurface(cornerRadius: AppCornerRadius.strip, style: .banner) {
            HStack(alignment: .top, spacing: AppSpacing.small) {
                Text(message)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: AppSpacing.small)

                if let onManage {
                    Button("Manage", action: onManage)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppColors.primary)
                }

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Dismiss")
            }
            .padding(AppSpacing.medium)
        }
        .padding(.top, AppSpacing.small)
    }
}

/// Decides whether the trial banner shows, and remembers dismissals.
///
/// It appears two days out, is dismissible for the day, returns once more on
/// the final day, and then never again.
struct TrialBannerPolicy {
    private enum Keys {
        static let dismissedOn = "trialBannerDismissedOn"
    }

    private let store: UserDefaultsStore
    private let calendar: Calendar

    init(store: UserDefaultsStore = .shared, calendar: Calendar = .current) {
        self.store = store
        self.calendar = calendar
    }

    /// Days before conversion at which the banner starts appearing.
    static let leadDays = 2

    func shouldShow(renewalDate: Date?, isInTrial: Bool, now: Date = .now) -> Bool {
        guard isInTrial, let renewalDate else { return false }

        let today = calendar.startOfDay(for: now)
        guard let daysLeft = calendar.dateComponents(
            [.day],
            from: today,
            to: calendar.startOfDay(for: renewalDate)
        ).day else { return false }

        guard daysLeft >= 0, daysLeft <= Self.leadDays else { return false }

        // Dismissed today? Stay gone until tomorrow.
        if let dismissed: Date = store.storedValue(forKey: Keys.dismissedOn),
           calendar.isDate(dismissed, inSameDayAs: now) {
            return false
        }
        return true
    }

    func dismissForToday(now: Date = .now) {
        store.set(calendar.startOfDay(for: now), forKey: Keys.dismissedOn)
    }

    /// Copy for the banner. The cancelled variant drops the Manage action and
    /// leads with reassurance instead of a charge.
    func message(renewalDate: Date?, price: String?, willRenew: Bool) -> String {
        let day = renewalDate?.formatted(.dateTime.weekday(.wide)) ?? "soon"
        guard willRenew else {
            return "Your trial ends \(day). You won't be charged."
        }
        let amount = price.map { " You'll be charged \($0) unless you cancel." } ?? " Cancel any time before then."
        return "Your trial ends \(day)." + amount
    }
}
