import SwiftUI

struct HomeHeaderView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                Text(Date.now.weekdayText)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)

                Text("Ready to focus")
                    .font(AppFonts.title)
                    .foregroundStyle(AppColors.textPrimary)
            }

            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(AppColors.secondary)
        }
    }
}
