import SwiftUI

private struct CardSurfaceModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppSpacing.medium)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
}

extension View {
    func cardSurface() -> some View {
        modifier(CardSurfaceModifier())
    }
}
