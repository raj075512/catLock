import SwiftUI

/// The active focus session. Deliberately continuous with the landing screen:
/// the same full-bleed cat scene stays put and only the glass panel swaps from
/// "choose a length" to "here's the countdown", so starting a session feels
/// like settling in rather than navigating somewhere new.
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
                topBar
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

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                GlassSurface(cornerRadius: 22, tint: .white.opacity(0.14)) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(width: 44, height: 44)
                }
            }
            .accessibilityLabel("End session")

            Spacer()
        }
        .padding(.top, AppSpacing.small)
    }

    private var controlPanel: some View {
        GlassSurface(cornerRadius: 32) {
            VStack(spacing: AppSpacing.medium) {
                if viewModel.session.state == .completed {
                    completedPanel
                } else {
                    activePanel
                }
            }
            .padding(AppSpacing.large)
        }
    }

    private var activePanel: some View {
        VStack(spacing: AppSpacing.medium) {
            Text(viewModel.session.state == .paused ? "Paused" : "Focusing")
                .font(AppFonts.caption)
                .foregroundStyle(AppColors.textSecondary)

            SessionTimerView(timeText: viewModel.formattedRemainingTime)

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
