import SwiftUI

/// Screen 10. Ends onboarding inside the product.
///
/// This launches a real session, not a tour. The chip row and Start capsule
/// are already Home's vocabulary, on Home's own glass panel over Home's own
/// video, so arriving at Home afterwards feels like staying put rather than
/// navigating somewhere new.
///
/// No Custom chip: the two-hour picker is deliberately not a first-run
/// decision.
struct FirstSessionPage: View {
    let preselectedMinutes: Int
    let onStart: (Int) -> Void

    @State private var selectedMinutes: Int

    private var state: AppState { AppState.shared }

    init(preselectedMinutes: Int, onStart: @escaping (Int) -> Void) {
        self.preselectedMinutes = preselectedMinutes
        self.onStart = onStart
        _selectedMinutes = State(initialValue: preselectedMinutes)
    }

    var body: some View {
        ZStack {
            CatSceneBackground(room: state.selectedRoom, playback: .once)

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                GlassSurface(cornerRadius: AppCornerRadius.panel) {
                    VStack(alignment: .leading, spacing: AppSpacing.medium) {
                        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                            Text("Your first session")
                                .font(AppFonts.title)
                                .foregroundStyle(AppColors.textPrimary)

                            Text("Based on your answers. Change it any time.")
                                .font(AppFonts.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }

                        HStack(spacing: AppSpacing.small) {
                            ForEach(HomeViewModel.durationPresets, id: \.self) { minutes in
                                DurationChip(
                                    title: "\(minutes)",
                                    isSelected: selectedMinutes == minutes
                                ) {
                                    withAnimation(AppAnimation.quick) { selectedMinutes = minutes }
                                    HapticManager.shared.selection()
                                }
                            }
                        }

                        CapsuleButton("Start focusing", systemImage: "play.fill", style: .accent) {
                            onStart(selectedMinutes)
                        }
                    }
                    .padding(AppSpacing.large)
                }
            }
            .padding(.horizontal, AppLayout.glassSideInset)
            .padding(.bottom, AppLayout.glassBottomInset)
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    FirstSessionPage(preselectedMinutes: 25) { _ in }
}
