import SwiftUI

struct PremiumLockBadge: View {
    var title: String = "Premium"

    var body: some View {
        Label(title, systemImage: "lock.fill")
            .font(AppFonts.caption)
            .padding(.horizontal, AppSpacing.small)
            .padding(.vertical, AppSpacing.xSmall)
            .background(AppColors.secondary.opacity(0.16))
            .foregroundStyle(AppColors.warning)
            .clipShape(Capsule())
            .accessibilityLabel(title)
    }
}
