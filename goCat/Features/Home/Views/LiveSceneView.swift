import SwiftUI

struct LiveSceneView: View {
    let scene: SceneOption
    let cat: CatOption
    let chair: ChairOption

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                .fill(sceneBackground)

            VStack(spacing: AppSpacing.medium) {
                Image(systemName: "sofa.fill")
                    .font(.system(size: 44, weight: .regular))
                    .foregroundStyle(AppColors.accent)
                    .accessibilityHidden(true)

                CatRiveView(cat: cat)

                Text(scene.name)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(AppSpacing.large)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1.45, contentMode: .fit)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(cat.name) in \(chair.name) inside \(scene.name)")
    }

    private var sceneBackground: LinearGradient {
        LinearGradient(
            colors: [AppColors.elevatedSurface, AppColors.surface],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
