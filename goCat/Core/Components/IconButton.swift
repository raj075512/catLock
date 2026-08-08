import SwiftUI

struct IconButton: View {
    let systemImage: String
    let accessibilityTitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .semibold))
                .frame(width: 40, height: 40)
        }
        .buttonStyle(.bordered)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
        .accessibilityLabel(accessibilityTitle)
    }
}
