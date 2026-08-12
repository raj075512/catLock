import SwiftUI

/// Home is the whole app.
///
/// Two glass objects at the top (identity and overflow) and one glass panel at
/// the bottom (length → start → adjust). The middle third belongs to the cat,
/// and that emptiness is the product — there is no tab bar, no nav bar, and
/// nothing else competing for the screen.
struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    private var state: AppState { AppState.shared }
    private var access: PremiumAccessService { PremiumAccessService.shared }
    private var store: StoreKitService { StoreKitService.shared }

    var body: some View {
        ZStack {
            // Holds its last frame here. Motion only ever means a live session.
            CatSceneBackground(room: viewModel.selectedRoom, playback: .once)

            VStack(spacing: 0) {
                topBar
                trialBanner
                Spacer(minLength: 0)
                controlPanel
            }
            .padding(.horizontal, AppLayout.glassSideInset)
            .padding(.bottom, AppLayout.glassBottomInset)
        }
        .preferredColorScheme(.light)
        .onAppear { viewModel.resumeSessionIfNeeded() }
        .task {
            // The entitlement is StoreKit's answer, not a cached flag, so it
            // is re-read on every launch.
            await access.refresh()
            await store.loadProducts()
        }
        .sheet(item: $viewModel.presentedSheet) { sheet in
            presentedSheet(sheet)
        }
        .fullScreenCover(isPresented: $viewModel.isSessionActive) {
            FocusSessionView(
                minutes: viewModel.selectedMinutes,
                sound: state.selectedSound,
                room: viewModel.selectedRoom,
                restoring: viewModel.restoredSession
            )
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack(spacing: AppSpacing.small) {
            StreakPill(
                streak: viewModel.currentStreak,
                hasEverCompleted: viewModel.hasEverCompleted
            ) {
                viewModel.presentedSheet = .progress
            }

            Spacer(minLength: 0)

            Menu {
                Button {
                    viewModel.presentedSheet = .progress
                } label: {
                    Label("Progress", systemImage: "chart.bar.fill")
                }

                Button {
                    viewModel.presentedSheet = .settings
                } label: {
                    Label("Settings", systemImage: "gearshape.fill")
                }
            } label: {
                GlassSurface(cornerRadius: AppCornerRadius.capsule, style: .pill) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(width: AppLayout.circleButton, height: AppLayout.circleButton)
                }
            }
            .accessibilityLabel("More options")
        }
        .padding(.top, AppSpacing.small)
    }

    /// Screen 31. A fourth glass object under the top bar, never during a
    /// session, and never once it has done its two appearances.
    @ViewBuilder
    private var trialBanner: some View {
        if viewModel.isShowingTrialBanner {
            TrialEndingBanner(
                message: viewModel.trialBannerMessage,
                onManage: viewModel.trialWillRenew
                    ? { viewModel.presentedSheet = .settings }
                    : nil,
                onDismiss: { viewModel.dismissTrialBanner() }
            )
        }
    }

    // MARK: - Bottom control panel

    private var controlPanel: some View {
        GlassSurface(cornerRadius: AppCornerRadius.panel) {
            VStack(spacing: AppSpacing.medium) {
                durationRow
                startButton
                quickActionRow
            }
            .padding(AppSpacing.large)
        }
    }

    /// 15 · 25 · 45 · Custom. The custom chip replaces the word "Custom" with
    /// its value rather than adding a fifth chip — the row is already at its
    /// width limit with four.
    private var durationRow: some View {
        ProportionalHStack(spacing: AppSpacing.small) {
            ForEach(HomeViewModel.durationPresets, id: \.self) { minutes in
                DurationChip(
                    title: "\(minutes)",
                    isSelected: viewModel.selectedMinutes == minutes && !viewModel.isCustomSelected
                ) {
                    withAnimation(AppAnimation.quick) {
                        viewModel.selectPreset(minutes)
                    }
                }
                .flex(1)
            }

            DurationChip(
                title: viewModel.customChipTitle,
                isSelected: viewModel.isCustomSelected
            ) {
                HapticManager.shared.selection()
                viewModel.presentedSheet = .customDuration
            }
            .flex(viewModel.customChipFlex)
        }
    }

    private var startButton: some View {
        CapsuleButton("Start Focus", systemImage: "play.fill", style: .accent) {
            viewModel.startSession()
        }
        .accessibilityIdentifier("startFocus")
        .accessibilityLabel("Start a \(viewModel.selectedMinutes) minute focus session")
    }

    private var quickActionRow: some View {
        HStack(spacing: AppSpacing.small) {
            QuickActionPill(title: "Sounds", systemImage: "speaker.wave.2.fill") {
                viewModel.presentedSheet = .sounds
            }
            .accessibilityIdentifier("quickActionSounds")

            QuickActionPill(title: "Room", systemImage: "photo.fill") {
                viewModel.presentedSheet = .room
            }
            .accessibilityIdentifier("quickActionRoom")

            QuickActionPill(title: "Tasks", systemImage: "checklist") {
                viewModel.presentedSheet = .tasks
            }
            .accessibilityIdentifier("quickActionTasks")
        }
    }

    @ViewBuilder
    private func presentedSheet(_ sheet: HomeViewModel.Sheet) -> some View {
        switch sheet {
        case .sounds:
            SoundsSheet()
        case .room:
            RoomSheet()
        case .tasks:
            TaskListView()
        case .progress:
            FocusProgressView { viewModel.presentedSheet = nil; viewModel.startSession() }
        case .settings:
            SettingsView()
        case .customDuration:
            CustomDurationSheet()
        }
    }
}

#Preview {
    HomeView()
}
