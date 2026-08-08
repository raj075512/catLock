import SwiftUI

struct SessionSceneView: View {
    var body: some View {
        VStack(spacing: AppSpacing.medium) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 88, weight: .regular))
                .foregroundStyle(AppColors.primary)

            Text("Focus in progress")
                .font(AppFonts.title)
                .foregroundStyle(AppColors.textPrimary)
        }
    }
}
