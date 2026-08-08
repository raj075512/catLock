import SwiftUI

struct SelectionCard<Content: View>: View {
    let isSelected: Bool
    let action: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        Button(action: action) {
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(AppSpacing.medium)
                .background(AppColors.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous)
                        .stroke(isSelected ? AppColors.primary : AppColors.elevatedSurface, lineWidth: isSelected ? 2 : 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
