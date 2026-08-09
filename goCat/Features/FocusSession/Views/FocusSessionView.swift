import SwiftUI

/// The active focus session. Deliberately continuous with the landing screen:
/// the same full-bleed cat scene stays put and only the glass panel swaps from
/// "choose a length" to "here's the countdown", so starting a session feels
/// like settling in rather than navigating somewhere new.
///
/// There is no back/close button here on purpose — once a session starts,
/// the only ways out are Pause and Complete (in `SessionControlsView`).
/// That's the whole "lock yourself with your cat" premise: starting a
/// session shouldn't be one accidental tap away from bailing on it.
struct FocusSessionView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: FocusSessionViewModel

    init(session: FocusSession = FocusSession()) {
        _viewModel = State(initialValue: FocusSessionViewModel(session: session))
    }

    var body: some View {
        ZStack {
            CatSceneBackground()

            VStack(spacing: 0) {
                controlPanel
                    .padding(.top, AppSpacing.small)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, AppSpacing.medium)
        }
        .preferredColorScheme(.light)
        .onAppear {
            if viewModel.session.state == .running {
                viewModel.start()
            }
        }
    }

    /// Thin, low-opacity strip pinned to the top — noticeably less present
    /// than the landing screen's bottom panel (lower tint, fainter border,
    /// tighter padding) so it reads as a readout, not a card.
    private var controlPanel: some View {
        GlassSurface(cornerRadius: 22, tint: .white.opacity(0.05), borderOpacity: 0.16) {
            Group {
                if viewModel.session.state == .completed {
                    completedPanel
                } else {
                    activePanel
                }
            }
            .padding(.horizontal, AppSpacing.medium)
            .padding(.vertical, AppSpacing.small)
        }
    }

    private var activePanel: some View {
        HStack(spacing: AppSpacing.medium) {
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.session.state == .paused ? "Paused" : "Focusing")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)

                Text(viewModel.formattedRemainingTime)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(AppColors.textPrimary)
                    .accessibilityLabel("Remaining time \(viewModel.formattedRemainingTime)")
            }

            Spacer(minLength: AppSpacing.medium)

            SessionControlsView(
                state: viewModel.session.state,
                onStart: viewModel.start,
                onPause: viewModel.pause,
                onComplete: viewModel.complete
            )
        }
    }

    private var completedPanel: some View {
        VStack(spacing: AppSpacing.medium) {
            SessionCompletedView()

            Button("Done") {
                dismiss()
            }
            .font(AppFonts.headline)
            .foregroundStyle(AppColors.primary)
        }
    }
}

#Preview {
    FocusSessionView(session: FocusSession(plannedDuration: 25 * 60, state: .running))
}
