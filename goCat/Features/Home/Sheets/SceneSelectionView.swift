import SwiftUI

struct SceneSelectionView: View {
    @Binding var selection: SceneOption

    var body: some View {
        List(SceneOption.options) { option in
            SelectionCard(isSelected: option == selection) {
                selection = option
            } content: {
                optionRow(name: option.name, systemImage: "photo", isPremium: option.isPremium)
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }

    private func optionRow(name: String, systemImage: String, isPremium: Bool) -> some View {
        HStack(spacing: AppSpacing.medium) {
            Image(systemName: systemImage)
                .frame(width: 28)
                .foregroundStyle(AppColors.primary)

            Text(name)
                .font(AppFonts.body)

            Spacer()

            if isPremium {
                PremiumLockBadge()
            }
        }
    }
}
