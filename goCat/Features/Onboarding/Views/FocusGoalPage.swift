import SwiftUI

struct FocusGoalPage: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.large) {
            Image(systemName: "timer")
                .font(.system(size: 64, weight: .semibold))
                .foregroundStyle(AppColors.secondary)

            Text("Choose a steady rhythm")
                .font(AppFonts.title)
                .foregroundStyle(AppColors.textPrimary)

            Text("Start with a 25 minute focus session and adjust it from the home screen anytime.")
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            PrimaryButton("Use 25 minutes", systemImage: "checkmark", action: onContinue)
        }
    }
}
