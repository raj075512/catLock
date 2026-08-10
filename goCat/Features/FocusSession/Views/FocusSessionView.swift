import SwiftUI

/// The active focus session. Deliberately continuous with the landing screen:
/// the same full-bleed cat scene stays put and only the glass panel changes,
/// so starting a session feels like settling in rather than navigating
/// somewhere new.
///
/// There is no back/close button and no pause — the only control is Cancel.
/// A session either runs to completion (trophy, streak +1) or gets
/// cancelled (trash, no streak change). That's the whole "lock yourself
/// with your cat" premise: no quiet way to just wander off.
struct FocusSessionView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: FocusSessionViewModel

    init(session: FocusSession = FocusSession()) {
        _viewModel = State(initialValue: FocusSessionViewModel(session: session))
    }

    var body: some View {
        ZStack {
            // Loops for the whole session — the motion is the company.
            CatSceneBackground(playback: .looping)

            VStack(spacing: 0) {
                Spacer(minLength: 0)
                controlPanel
            }
            .padding(.horizontal, AppSpacing.medium)
            .padding(.bottom, AppSpacing.medium)
        }
        .preferredColorScheme(.light)
        .onAppear {
            if viewModel.session.state == .running {
                viewModel.start()
            }
        }
    }

    /// Thin, low-opacity strip pinned to the bottom for the active
    /// countdown. Grows to fit an outcome screen (trophy/trash) once the
    /// session ends — that's expected; only the countdown state is this
    /// deliberately minimal.
    private var controlPanel: some View {
        GlassSurface(cornerRadius: 26, tint: .white.opacity(0.05), borderOpacity: 0.16) {
            Group {
                switch viewModel.session.state {
                case .completed:
                    SessionCompletedView(newStreak: viewModel.completedStreak ?? 0) {
                        dismiss()
                    }
                    .padding(.horizontal, AppSpacing.large)
                    .padding(.vertical, AppSpacing.medium)
                case .cancelled:
                    SessionCancelledView {
                        dismiss()
                    }
                    .padding(.horizontal, AppSpacing.large)
                    .padding(.vertical, AppSpacing.medium)
                default:
                    activePanel
                        .padding(.horizontal, AppSpacing.medium)
                        .padding(.vertical, AppSpacing.small)
                }
            }
        }
    }

    private var activePanel: some View {
        HStack(spacing: AppSpacing.medium) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Focusing")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)

                Text(viewModel.formattedRemainingTime)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(AppColors.danger)
                    .contentTransition(.numericText(countsDown: true))
                    .accessibilityLabel("Remaining time \(viewModel.formattedRemainingTime)")
            }

            Spacer(minLength: AppSpacing.medium)

            Button("Cancel", role: .destructive) {
                viewModel.cancel()
            }
            .font(AppFonts.headline)
            .foregroundStyle(AppColors.danger)
        }
    }
}

#Preview {
    FocusSessionView(session: FocusSession(plannedDuration: 25 * 60, state: .running))
}
