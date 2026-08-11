import SwiftUI

/// Screen 9. Sells the constraint before it is felt.
///
/// Step 3 states the trade plainly — "Finishing earns the streak; cancelling
/// just doesn't" — so Cancel never reads as punishment. That sentence is the
/// reason this screen exists.
///
/// Reachable again later from Settings › Replay intro.
struct HowItWorksPage: View {
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion

    private var state: AppState { AppState.shared }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                Text("How it works")
                    .largeTitleTracking()
                    .foregroundStyle(AppColors.textPrimary)

                Text("Pick a length. Start. No pause, no going back — your cat waits it out with you.")
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, AppSpacing.xLarge)
            .padding(.horizontal, AppSpacing.large)

            CatScenePoster(room: state.selectedRoom)
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
                .padding(.horizontal, AppSpacing.medium)
                .padding(.vertical, AppSpacing.large)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, text in
                    HStack(alignment: .top, spacing: AppSpacing.medium) {
                        Text("\(index + 1)")
                            .font(AppFonts.caption)
                            .foregroundStyle(AppColors.primary)
                            .frame(width: AppSpacing.large, height: AppSpacing.large)
                            .background(Circle().fill(AppColors.elevatedSurface))

                        Text(text)
                            .font(AppFonts.body)
                            .foregroundStyle(AppColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: 0)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.large)

            Spacer(minLength: AppSpacing.large)

            CapsuleButton("Got it", style: .primary, action: onContinue)
                .padding(.horizontal, AppSpacing.medium)
                .padding(.bottom, AppSpacing.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColors.background)
    }

    /// Under Reduce Motion the running cue can't be the rocking, because there
    /// isn't any — so step 2 names the thing that is actually true in that
    /// mode. Motion is decoration; the timer is the information.
    private var steps: [String] {
        [
            "Choose 15, 25 or 45 minutes.",
            state.prefersReducedMotion(system: systemReduceMotion)
                ? "A still room means the clock is live."
                : "The chair starts rocking. That's your signal the clock is live.",
            "Cancel any time. Finishing earns the streak; cancelling just doesn't."
        ]
    }
}

#Preview {
    HowItWorksPage {}
}
