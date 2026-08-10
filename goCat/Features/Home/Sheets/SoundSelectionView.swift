import SwiftUI

/// Picking a sound previews it immediately — you cannot choose ambient audio
/// you have not heard. Tapping the selected row again stops it.
struct SoundSelectionView: View {
    @Binding var selection: SoundOption

    // Not `@State`: this is a shared singleton the view observes, not state the
    // view owns. `@Observable` tracks any property read inside `body`, so
    // updates still arrive.
    private let audio = AudioPlayerService.shared

    var body: some View {
        VStack(spacing: 0) {
            List(SoundOption.options) { option in
                SelectionCard(isSelected: option == selection) {
                    selection = option
                    audio.toggle(option)
                } content: {
                    HStack(spacing: AppSpacing.medium) {
                        Image(systemName: iconName(for: option))
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
                .listRowSeparator(.hidden)
                .accessibilityLabel(option.name)
                .accessibilityValue(isNowPlaying(option) ? "Playing" : "")
                .accessibilityHint(isNowPlaying(option) ? "Double tap to stop" : "Double tap to preview")
            }
            .listStyle(.plain)

            volumeControl
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

    private func iconName(for option: SoundOption) -> String {
        isNowPlaying(option) ? "speaker.wave.2.fill" : "play.circle"
    }
}
