import SwiftUI

struct CatRiveView: View {
    let cat: CatOption

    var body: some View {
        VStack(spacing: AppSpacing.small) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 72, weight: .regular))
                .foregroundStyle(AppColors.primary)

            Text(cat.name)
                .font(AppFonts.headline)
                .foregroundStyle(AppColors.textPrimary)
        }
    }
}
