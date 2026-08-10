import SwiftUI

struct NotificationPermissionPage: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.large) {
            Image(systemName: "bell.badge")
                .font(.system(size: 64, weight: .semibold))
                .foregroundStyle(AppColors.accent)

            Text("Know when the session ends")
                .font(AppFonts.title)
                .foregroundStyle(AppColors.textPrimary)

            Text("catLock can remind you when a focus block is complete.")
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            PrimaryButton("Continue", systemImage: "bell", action: onContinue)
        }
    }
}
