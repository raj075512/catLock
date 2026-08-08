import SwiftUI

struct SoundSelectionView: View {
    @Binding var selection: SoundOption

    var body: some View {
        List(SoundOption.options) { option in
            SelectionCard(isSelected: option == selection) {
                selection = option
            } content: {
                HStack(spacing: AppSpacing.medium) {
                    Image(systemName: "speaker.wave.2.fill")
                        .frame(width: 28)
                        .foregroundStyle(AppColors.secondary)

                    Text(option.name)
                        .font(AppFonts.body)

                    Spacer()

                    if option.isPremium {
                        PremiumLockBadge()
                    }
                }
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
}
