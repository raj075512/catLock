import SwiftUI

/// Screen 20. Choose the audio before starting — it can't be changed
/// mid-session (rule 2), so this sheet doubles as the player: tapping a free
/// row previews it immediately.
///
/// There is no volume slider. System volume owns loudness, and a second
/// control for it would just be a way to get the two out of sync.
struct SoundsSheet: View {
    @Environment(\.dismiss) private var dismiss

    private var state: AppState { AppState.shared }
    private var audio: AudioPlayerService { AudioPlayerService.shared }
    private var access: PremiumAccessService { PremiumAccessService.shared }

    @State private var isShowingPaywall = false

    private var freeSounds: [SoundOption] { SoundOption.options.filter { !$0.isPremium } }
    private var lockedSounds: [SoundOption] { SoundOption.options.filter(\.isPremium) }

    var body: some View {
        SheetScaffold(
            title: "Sounds",
            subtitle: "Plays through the session. Mixes with your own music.",
            onDone: { dismiss() }
        ) {
            ScrollView {
                VStack(spacing: AppSpacing.small) {
                    ForEach(freeSounds) { sound in
                        soundRow(sound)
                    }

                    ForEach(lockedSounds) { sound in
                        soundRow(sound)
                    }

                    // Locks and the upsell both disappear entirely once Plus
                    // is active. No upsell after purchase.
                    if !access.hasPlus {
                        plusFooter
                            .padding(.top, AppSpacing.small)
                    }
                }
                .padding(.horizontal, AppSpacing.medium)
                .padding(.bottom, AppSpacing.xLarge)
            }
        }
        .onDisappear {
            // The preview is for choosing, not for listening to on Home. The
            // session starts its own playback from scratch.
            audio.stop()
        }
        .sheet(isPresented: $isShowingPaywall) {
            PaywallView()
        }
    }

    private func soundRow(_ sound: SoundOption) -> some View {
        let isSelected = state.selectedSound?.id == sound.id

        return OptionRow(
            title: sound.name,
            subtitle: isSelected ? "Playing" : nil,
            systemImage: "speaker.wave.2.fill",
            isSelected: isSelected,
            isLocked: sound.isPremium && !access.hasPlus,
            trailing: {
                if isSelected {
                    HStack(spacing: AppSpacing.small) {
                        LevelMeter()
                        Image(systemName: "checkmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AppColors.primary)
                    }
                }
            },
            action: { select(sound, isSelected: isSelected) }
        )
    }

    private func select(_ sound: SoundOption, isSelected: Bool) {
        guard !sound.isPremium || access.hasPlus else {
            // A locked row is clear intent, so it opens the paywall rather
            // than doing nothing.
            HapticManager.shared.selection()
            isShowingPaywall = true
            return
        }

        if isSelected {
            // Tapping the selected row deselects it. Silence is a valid choice
            // and this is the only way to reach it — there is no "None" row.
            state.selectSound(nil)
            audio.stop()
        } else {
            state.selectSound(sound)
            audio.play(sound)
        }
        HapticManager.shared.selection()
    }

    private var plusFooter: some View {
        Button {
            isShowingPaywall = true
        } label: {
            HStack {
            Text("Three more sounds with Plus")
                .font(AppFonts.caption)
                .foregroundStyle(AppColors.textSecondary)

            Spacer(minLength: AppSpacing.small)

            Text("See Plus")
                .font(AppFonts.caption)
                .foregroundStyle(AppColors.primary)
            }
            .padding(AppSpacing.medium)
            .background(AppColors.elevatedSurface)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

/// The four-bar meter beside the playing sound. Decorative — the "Playing"
/// caption and the checkmark are what actually carry the state.
struct LevelMeter: View {
    @State private var phase: CGFloat = 0

    private let heights: [CGFloat] = [8, 14, 6, 11]

    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(heights.indices, id: \.self) { index in
                Capsule()
                    .fill(AppColors.primary)
                    .frame(width: 2, height: heights[index])
            }
        }
        .frame(height: 14)
        .accessibilityHidden(true)
    }
}

#Preview {
    Color.gray.sheet(isPresented: .constant(true)) {
        SoundsSheet().presentationDragIndicator(.visible)
    }
}
