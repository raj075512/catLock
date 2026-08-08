import SwiftUI

struct PurchasedItemsView: View {
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text("Owned Items")
                .font(AppFonts.headline)

            ForEach(items, id: \.self) { item in
                Label(item, systemImage: "checkmark.circle")
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.textPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
    }
}
