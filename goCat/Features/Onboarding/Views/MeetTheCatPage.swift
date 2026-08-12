import SwiftUI

/// Screen 2. First human contact: calm, one decision.
///
/// Rule 6 — no sign-in wall on launch. There is no skip, no login, and no
/// "already have an account", because there are no accounts.
struct MeetTheCatPage: View {
    let onGetStarted: () -> Void

    private var state: AppState { AppState.shared }

    var body: some View {
        ZStack {
            CatSceneBackground(room: state.selectedRoom, playback: .once)

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                GlassSurface(cornerRadius: AppCornerRadius.panel) {
                    VStack(spacing: AppSpacing.medium) {
                        Text("catLock")
                            .largeTitleTracking()
                            .foregroundStyle(AppColors.textPrimary)

                        Text("Lock yourself in with your cat.")
                            .font(AppFonts.body)
                            .foregroundStyle(AppColors.textSecondary)
                            .multilineTextAlignment(.center)

                        CapsuleButton("Get started", style: .accent, action: onGetStarted)
                            .padding(.top, AppSpacing.small)
                    }
                    .padding(.vertical, AppSpacing.xLarge)
                    .padding(.horizontal, AppSpacing.large)
                }
            }
            .padding(.horizontal, AppLayout.glassSideInset)
            .padding(.bottom, AppLayout.glassBottomInset)
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    MeetTheCatPage {}
}
