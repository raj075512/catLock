import SwiftUI

struct CatSelectionView: View {
    @Binding var selection: CatOption

    var body: some View {
        List(CatOption.options) { option in
            SelectionCard(isSelected: option == selection) {
                selection = option
            } content: {
                HStack(spacing: AppSpacing.medium) {
                    Image(systemName: "pawprint.fill")
                        .frame(width: 28)
                        .foregroundStyle(AppColors.primary)

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
