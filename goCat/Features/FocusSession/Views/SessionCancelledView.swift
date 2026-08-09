import SwiftUI

/// Shown when the user taps Cancel before the countdown finishes. No
/// streak change, no soft-pedaling — a session that didn't happen goes to
/// the trash, visually.
struct SessionCancelledView: View {
    var onDone: (() -> Void)?

    var body: some View {
        VStack(spacing: AppSpacing.small) {
            LottiePlaybackView(resourceName: "trash_cancel", onFinish: onDone)
                .frame(width: 120, height: 120)
                .accessibilityHidden(true)

            Text("Session cancelled")
                .font(AppFonts.headline)
                .foregroundStyle(AppColors.textPrimary)

            Text("This one didn't count — start again whenever you're ready.")
                .font(AppFonts.caption)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            if let onDone {
                Button("Continue", action: onDone)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.primary)
                    .padding(.top, AppSpacing.xSmall)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Session cancelled. This one didn't count.")
    }
}

#Preview {
    SessionCancelledView {}
        .padding()
        .background(AppColors.background)
}
