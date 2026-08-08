import SwiftUI

struct WeeklySummaryView: View {
    let summary: ProgressSummary

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text("This Week")
                .font(AppFonts.headline)

            HStack {
                summaryItem(title: "Sessions", value: "\(summary.completedSessions)")
                Spacer()
                summaryItem(title: "Focus", value: summary.formattedTotalFocusTime)
            }
        }
        .cardSurface()
    }

    private func summaryItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
            Text(value)
                .font(AppFonts.title)
                .foregroundStyle(AppColors.textPrimary)

            Text(title)
                .font(AppFonts.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
    }
}
