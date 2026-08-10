import SwiftUI

/// Picking a sound previews it immediately — you cannot choose ambient audio
/// you have not heard. Tapping the selected row again stops the preview; the
/// choice itself sticks and is what the next session plays.
struct SoundSelectionView: View {
    @Bindable var viewModel: HomeViewModel

    // Not `@State`: this is a shared singleton the view observes, not state the
    // view owns. `@Observable` tracks any property read inside `body`, so
    // updates still arrive.
    private let audio = AudioPlayerService.shared

    var body: some View {
        VStack(spacing: 0) {
            soundToggle

            List(SoundOption.options) { option in
                SelectionCard(isSelected: option == viewModel.selectedSound) {
                    viewModel.selectSound(option)
                    audio.toggle(option)
                } content: {
                    row(for: option)
                }
                .listRowSeparator(.hidden)
                .disabled(!viewModel.soundEnabled)
                .opacity(viewModel.soundEnabled ? 1 : 0.4)
                .accessibilityLabel(option.name)
                .accessibilityValue(isNowPlaying(option) ? "Playing" : "")
                .accessibilityHint(isNowPlaying(option) ? "Double tap to stop" : "Double tap to preview")
            }
            .listStyle(.plain)

            if viewModel.soundEnabled {
                volumeControl
            }
        }
    }

    private var soundToggle: some View {
        Toggle(isOn: Binding(
            get: { viewModel.soundEnabled },
            set: { isOn in
                viewModel.setSoundEnabled(isOn)
                // Turning it off must silence whatever is previewing right now,
                // not just affect the next session.
                if !isOn { audio.stop() }
            }
        )) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Ambient sound")
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.textPrimary)

                Text(viewModel.soundEnabled ? "Plays for the whole session" : "Sessions run in silence")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .tint(AppColors.primary)
        .padding(.horizontal, AppSpacing.large)
        .padding(.vertical, AppSpacing.medium)
    }

    private func row(for option: SoundOption) -> some View {
        HStack(spacing: AppSpacing.medium) {
            Image(systemName: isNowPlaying(option) ? "speaker.wave.2.fill" : "play.circle")
                .frame(width: 28)
                .foregroundStyle(isNowPlaying(option) ? AppColors.primary : AppColors.secondary)
                .contentTransition(.symbolEffect(.replace))

            Text(option.name)
                .font(AppFonts.body)

            Spacer()

            if option.isPremium {
                PremiumLockBadge()
            }
        }
    }

    private var volumeControl: some View {
        HStack(spacing: AppSpacing.small) {
            Image(systemName: "speaker.fill")
                .foregroundStyle(AppColors.textSecondary)

            Slider(
                value: Binding(get: { audio.volume }, set: { audio.setVolume($0) }),
                in: 0...1
            )
            .tint(AppColors.primary)

            Image(systemName: "speaker.wave.3.fill")
                .foregroundStyle(AppColors.textSecondary)
        }
        .font(AppFonts.caption)
        .padding(.horizontal, AppSpacing.large)
        .padding(.vertical, AppSpacing.medium)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Volume")
    }

    private func isNowPlaying(_ option: SoundOption) -> Bool {
        audio.isPlaying && audio.currentSound == option
    }
}
