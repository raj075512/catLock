import SwiftUI

struct LoadingView: View {
    var message: String = "Loading"

    var body: some View {
        VStack(spacing: AppSpacing.medium) {
            SwiftUI.ProgressView()
            Text(message)
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}
