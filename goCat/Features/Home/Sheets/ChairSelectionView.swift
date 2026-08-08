import SwiftUI

struct ChairSelectionView: View {
    @Binding var selection: ChairOption

    var body: some View {
        List(ChairOption.options) { option in
            SelectionCard(isSelected: option == selection) {
                selection = option
            } content: {
                HStack(spacing: AppSpacing.medium) {
                    Image(systemName: "sofa.fill")
                        .frame(width: 28)
                        .foregroundStyle(AppColors.accent)

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
