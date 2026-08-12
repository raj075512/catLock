import SwiftUI

/// Screen 17. Closes the loop with no verdict attached.
///
/// The trash animation carries the "discarded" idea so the copy doesn't have
/// to. Two lines, then a way out — and the streak pill stays visible and
/// untouched above, because nothing was taken away. No confirmation, no
/// streak-loss warning, no re-engagement nudge, ever.
struct SessionCancelledView: View {
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.medium) {
            LottiePlaybackView(resourceName: "trash_cancel")
                .frame(width: 120, height: 120)
                .accessibilityHidden(true)

            Text("Session cancelled")
                .font(AppFonts.headline)
                .foregroundStyle(AppColors.textPrimary)

            Text("This one didn't count — start again whenever you're ready.")
                .font(AppFonts.caption)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 260)

            // A text button, not a filled one. The cancelled screen is the
            // quiet counterpart to the trophy — this is the one place the app
            // deliberately doesn't raise its voice.
            Button("Continue", action: onContinue)
                .font(AppFonts.headline)
                .foregroundStyle(AppColors.primary)
                .frame(minHeight: AppLayout.minimumTapTarget)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppSpacing.xLarge)
        .padding(.horizontal, AppSpacing.large)
        .padding(.bottom, AppSpacing.large)
    }
}

#Preview {
    SessionCancelledView {}
        .background(AppColors.background)
}
