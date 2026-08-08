import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        VStack(spacing: AppSpacing.medium) {
            Image(systemName: systemImage)
                .font(.system(size: 44, weight: .regular))
                .foregroundStyle(AppColors.secondary)

            Text(title)
                .font(AppFonts.title)
                .foregroundStyle(AppColors.textPrimary)

            Text(message)
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppSpacing.large)
        .frame(maxWidth: .infinity)
    }
}
