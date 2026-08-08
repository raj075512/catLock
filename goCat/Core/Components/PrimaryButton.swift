import SwiftUI

struct PrimaryButton: View {
    let title: String
    let systemImage: String?
    let action: () -> Void

    init(_ title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.small) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .font(AppFonts.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.medium)
        }
        .buttonStyle(.borderedProminent)
        .tint(AppColors.primary)
        .accessibilityLabel(title)
    }
}
