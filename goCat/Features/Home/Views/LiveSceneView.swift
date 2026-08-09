import SwiftUI
import UIKit

/// A quiet preview of the selected room shown on Home. The companion (cat +
/// chair) is a fixed default shown as a static poster here — the full
/// looping animation only plays once a focus session actually starts, via
/// `CatSceneBackground`. There is no cat/chair switching by design.
struct LiveSceneView: View {
    let scene: SceneOption

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                .fill(sceneBackground)

            VStack(spacing: AppSpacing.medium) {
                posterImage
                    .frame(width: 96, height: 96)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
                    .accessibilityHidden(true)

                Text(scene.name)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(AppSpacing.large)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1.45, contentMode: .fit)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Your room: \(scene.name)")
    }

    @ViewBuilder
    private var posterImage: some View {
        if let path = Bundle.main.path(forResource: "session_cat_poster", ofType: "jpg"),
           let uiImage = UIImage(contentsOfFile: path) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            Image(systemName: "sofa.fill")
                .font(.system(size: 44, weight: .regular))
                .foregroundStyle(AppColors.accent)
        }
    }

    private var sceneBackground: LinearGradient {
        LinearGradient(
            colors: [AppColors.elevatedSurface, AppColors.surface],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
