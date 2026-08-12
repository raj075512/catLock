import SwiftUI

/// Screens 15–19. The session, and the two ways it can end.
///
/// One object on screen and one control on it. No status bar treatment, no nav
/// bar, no back, no close, no pause, no task list, no sound control — anything
/// a person could fidget with instead of working has been removed on purpose
/// (rules 1 and 2). Swipe-to-dismiss is off for the same reason.
///
/// The strip is more transparent than Home's panel so the cat stays the
/// brightest thing on screen, and the countdown is the only red in the app
/// besides Cancel.
struct FocusSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion

    @State private var viewModel: FocusSessionViewModel
    @State private var hasAppeared = false

    private var state: AppState { AppState.shared }

    init(minutes: Int, sound: SoundOption?, room: RoomOption, restoring: ActiveSession? = nil) {
        _viewModel = State(
            initialValue: FocusSessionViewModel(
                minutes: minutes,
                sound: sound,
                room: room,
                restoring: restoring
            )
        )
    }

    var body: some View {
        ZStack {
            // Loops for the whole session — the motion is the company.
            CatSceneBackground(room: viewModel.room, playback: .looping)

            VStack(spacing: 0) {
                if viewModel.outcome != .running {
                    endStateTopBar
                }
                Spacer(minLength: 0)
                panel
            }
            .padding(.horizontal, AppLayout.glassSideInset)
            .padding(.bottom, AppLayout.glassBottomInset)
        }
        .preferredColorScheme(.light)
        .interactiveDismissDisabled()
        .statusBarHidden(viewModel.outcome == .running)
        .onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            viewModel.modelContext = modelContext
            viewModel.start()
        }
        .onChange(of: scenePhase) { _, phase in
            // The clock ran while we were away; the session may already be over.
            if phase == .active { viewModel.refresh() }
        }
        .onDisappear { viewModel.stopAudio() }
    }

    /// The streak pill is deliberately visible on both end states — untouched
    /// at 7 after a cancel, counted up to 8 after a completion.
    private var endStateTopBar: some View {
        HStack {
            StreakPill(
                streak: streakForPill,
                hasEverCompleted: streakForPill > 0
            ) {}
            .allowsHitTesting(false)

            Spacer(minLength: 0)
        }
        .padding(.top, AppSpacing.small)
    }

    private var streakForPill: Int {
        viewModel.outcome == .completed
            ? viewModel.streakAfterCompletion
            : StreakStore.shared.currentStreak
    }

    @ViewBuilder
    private var panel: some View {
        switch viewModel.outcome {
        case .running:
            runningStrip
                .transition(.identity)

        case .cancelled:
            GlassSurface(cornerRadius: AppCornerRadius.panel) {
                SessionCancelledView { dismiss() }
            }
            .transition(.opacity)

        case .completed:
            GlassSurface(cornerRadius: AppCornerRadius.panel) {
                SessionCompletedView(
                    streak: viewModel.streakAfterCompletion,
                    minutes: viewModel.minutes,
                    isFirstEver: viewModel.isFirstEverCompletion
                ) {
                    dismiss()
                }
            }
            .transition(.opacity)
        }
    }

    private var runningStrip: some View {
        GlassSurface(cornerRadius: AppCornerRadius.strip, style: .sessionStrip) {
            HStack(spacing: AppSpacing.medium) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Focusing")
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.textSecondary)

                    Text(viewModel.formattedRemainingTime)
                        .font(AppFonts.countdown)
                        .monospacedDigit()
                        .tracking(-1)
                        .foregroundStyle(AppColors.danger)
                        .contentTransition(.numericText(countsDown: true))
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Focusing. \(viewModel.formattedRemainingTime) remaining.")

                Spacer(minLength: AppSpacing.medium)

                Button("Cancel") {
                    viewModel.cancel()
                }
                .font(AppFonts.headline)
                .foregroundStyle(AppColors.danger)
                .frame(minHeight: AppLayout.minimumTapTarget)
                .accessibilityHint("Discards this session. Your streak is unchanged.")
            }
            .padding(.horizontal, AppSpacing.large)
            .padding(.vertical, AppSpacing.medium)
        }
        .overlay(alignment: .topLeading) { finalMinuteHairline }
    }

    /// The only change in the final minute: a 3pt sage hairline on the strip's
    /// top edge, filling left to right as the minute runs out.
    ///
    /// Peripheral, silent, and static in place — nothing moves the type or the
    /// cat, so someone mid-sentence isn't pulled out of the task, but a glance
    /// registers "nearly done" without reading digits. Green because the
    /// ending is a success, not an alarm.
    @ViewBuilder
    private var finalMinuteHairline: some View {
        if viewModel.isInFinalMinute {
            GeometryReader { proxy in
                let reduceMotion = state.prefersReducedMotion(system: systemReduceMotion)
                // Reduce Motion gets it at full width at 00:30 rather than
                // sweeping, so it still communicates without animating.
                let fraction = reduceMotion
                    ? (viewModel.finalMinuteProgress >= 0.5 ? 1 : 0)
                    : viewModel.finalMinuteProgress

                Rectangle()
                    .fill(AppColors.accent)
                    .frame(width: proxy.size.width * fraction, height: 3)
            }
            .frame(height: 3)
            .accessibilityHidden(true)
        }
    }
}

#Preview {
    FocusSessionView(minutes: 25, sound: .rain, room: .livingRoom)
}
