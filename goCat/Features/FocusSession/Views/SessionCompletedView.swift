import SwiftUI

/// Screens 18 and 19. The payoff.
///
/// The title steps up to 24 — larger than the cancelled screen's 17 — and
/// Continue becomes a filled capsule rather than a text button. This is the
/// one place in the app that raises its voice.
///
/// The first-ever completion reuses the identical furniture and changes only
/// the words, so the first win isn't a special screen that never comes back.
/// The copy says "come back tomorrow", never "don't break your streak".
struct SessionCompletedView: View {
    let streak: Int
    let minutes: Int
    let isFirstEver: Bool
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.large) {
            LottiePlaybackView(resourceName: "session_trophy")
                .frame(width: 120, height: 120)
                .accessibilityHidden(true)

            VStack(spacing: AppSpacing.small) {
                Text(title)
                    .font(AppFonts.title)
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                caption
            }

            CapsuleButton("Continue", style: .primary, action: onContinue)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppSpacing.xLarge)
        .padding(.horizontal, AppSpacing.large)
        .padding(.bottom, AppSpacing.large)
        .accessibilityElement(children: .contain)
    }

    private var title: String {
        isFirstEver ? "That's one." : "Session complete"
    }

    @ViewBuilder
    private var caption: some View {
        if isFirstEver {
            Text("\(minutes) minutes done, and a streak started. Come back tomorrow and it's two.")
                .font(AppFonts.caption)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 260)
        } else {
            HStack(spacing: AppSpacing.xSmall) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.secondary)

                Text("\(streak) day streak · \(minutes) minutes")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }
}

#Preview("Complete") {
    SessionCompletedView(streak: 8, minutes: 25, isFirstEver: false) {}
        .background(AppColors.background)
}

#Preview("First ever") {
    SessionCompletedView(streak: 1, minutes: 25, isFirstEver: true) {}
        .background(AppColors.background)
}
