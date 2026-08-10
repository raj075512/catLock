import SwiftUI

struct LaunchView: View {
    @State private var viewModel = LaunchViewModel()

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: AppSpacing.large) {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 56, weight: .semibold))
                    .foregroundStyle(AppColors.primary)

                Text("catLock")
                    .font(AppFonts.largeTitle)
                    .foregroundStyle(AppColors.textPrimary)
            }
        }
        .task {
            await viewModel.prepare()
        }
    }
}
