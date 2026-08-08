import SwiftUI

struct WelcomePage: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.large) {
            Image(systemName: "pawprint.circle.fill")
                .font(.system(size: 72, weight: .regular))
                .foregroundStyle(AppColors.primary)

            Text("GoCat")
                .font(AppFonts.largeTitle)
                .foregroundStyle(AppColors.textPrimary)

            Text("A calm focus timer with a room you can shape over time.")
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            PrimaryButton("Continue", systemImage: "arrow.right", action: onContinue)
        }
    }
}
