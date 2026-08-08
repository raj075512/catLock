import SwiftUI

struct ErrorStateView: View {
    let title: String
    let message: String
    var retryTitle: String = "Try Again"
    var retryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: AppSpacing.medium) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(AppColors.warning)

            Text(title)
                .font(AppFonts.title)

            Text(message)
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            if let retryAction {
                PrimaryButton(retryTitle, systemImage: "arrow.clockwise", action: retryAction)
                    .padding(.top, AppSpacing.small)
            }
        }
        .padding(AppSpacing.large)
    }
}
