import SwiftUI

/// The landing screen. Full-bleed cat scene with everything else floating on
/// glass on top of it: streak + overflow at the top, and a single bottom panel
/// holding duration chips, Start Focus, and the Sounds / Room / Tasks shortcuts.
///
/// There is deliberately no tab bar here — the artwork is the screen, and the
/// remaining destinations (Progress, Settings) live in the overflow menu so
/// nothing competes with the scene.
struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var customizationKind: CustomizationSheet.Kind?
    @State private var isShowingTasks = false
    @State private var isShowingProgress = false
    @State private var isShowingSettings = false
    @State private var isSessionActive = false

    var body: some View {
        ZStack {
            // Plays through once and rests on the last frame. The endless
            // loop belongs to an active session, not to the picker.
            CatSceneBackground(playback: .once)

            VStack(spacing: 0) {
                topBar
                Spacer(minLength: 0)
                controlPanel
            }
            .padding(.horizontal, AppSpacing.medium)
            .padding(.bottom, AppSpacing.medium)
        }
        .preferredColorScheme(.light)
        .sheet(item: $customizationKind) { kind in
            CustomizationSheet(kind: kind, viewModel: viewModel)
        }
        .sheet(isPresented: $isShowingTasks) {
            // TaskListView supplies its own NavigationStack; nesting another
            // one here would swallow its toolbar (including the Done button).
            TaskListView()
        }
        .sheet(isPresented: $isShowingProgress) {
            FocusProgressView()
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
        }
        .fullScreenCover(isPresented: $isSessionActive, onDismiss: {
            // A completed session may have bumped the streak in the
            // background (StreakStore) — pick that up now that we're back.
            viewModel.refreshStreak()
        }) {
            FocusSessionView(session: viewModel.startFocusSession())
        }
        .sheet(isPresented: $viewModel.isShowingCustomPicker) {
            CustomDurationPickerView(
                totalMinutes: Binding(
                    get: { viewModel.customMinutes ?? viewModel.selectedMinutes },
                    set: { viewModel.selectCustomDuration($0) }
                )
            )
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            GlassPill {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.secondary)

                    Text("\(viewModel.currentStreak) day streak")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppColors.textPrimary)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(viewModel.currentStreak) day streak")

            Spacer()

            Menu {
                Button {
                    isShowingProgress = true
                } label: {
                    Label("Progress", systemImage: "chart.bar.fill")
                }

                Button {
                    isShowingSettings = true
                } label: {
                    Label("Settings", systemImage: "gearshape.fill")
                }
            } label: {
                GlassSurface(cornerRadius: 22, tint: .white.opacity(0.14)) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(width: 44, height: 44)
                }
            }
            .accessibilityLabel("More options")
        }
        .padding(.top, AppSpacing.small)
    }

    // MARK: - Bottom control panel

    private var controlPanel: some View {
        GlassSurface(cornerRadius: 32) {
            VStack(spacing: AppSpacing.small + 2) {
                durationRow
                startButton
                quickActionRow
            }
            .padding(AppSpacing.small + 2)
        }
    }

    private var durationRow: some View {
        HStack(spacing: AppSpacing.small) {
            ForEach(HomeViewModel.durationPresets, id: \.self) { minutes in
                DurationChip(
                    minutes: minutes,
                    isSelected: viewModel.selectedMinutes == minutes && !viewModel.isCustomSelected
                ) {
                    withAnimation(AppAnimation.quick) {
                        viewModel.selectedMinutes = minutes
                    }
                    HapticManager.shared.selection()
                }
            }

            DurationChip(
                title: viewModel.customChipTitle,
                systemImage: "slider.horizontal.3",
                isSelected: viewModel.isCustomSelected
            ) {
                HapticManager.shared.selection()
                viewModel.isShowingCustomPicker = true
            }
        }
    }

    private var startButton: some View {
        Button {
            HapticManager.shared.impact()
            isSessionActive = true
        } label: {
            HStack(spacing: AppSpacing.small) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 24, weight: .medium))

                Text("Start Focus")
                    .font(.system(size: 19, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background {
                Capsule(style: .continuous)
                    .fill(AppColors.accent.opacity(0.92))
            }
            .overlay {
                Capsule(style: .continuous)
                    .strokeBorder(.white.opacity(0.35), lineWidth: 0.8)
            }
            .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Start a \(viewModel.selectedMinutes) minute focus session")
    }

    private var quickActionRow: some View {
        HStack(spacing: AppSpacing.small) {
            QuickActionPill(title: "Sounds", systemImage: "music.note") {
                customizationKind = .sound
            }

            QuickActionPill(title: "Room", systemImage: "lamp.table.fill") {
                customizationKind = .room
            }

            QuickActionPill(title: "Tasks", systemImage: "checklist") {
                isShowingTasks = true
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(AppState())
}
