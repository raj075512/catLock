import SwiftUI

/// The scene shown while a focus session is active. Uses the default,
/// non-customizable companion loop (cat resting in its rocking chair) —
/// there is no character/chair/scene switching here by design, keeping the
/// session view simple and consistent every time.
struct SessionSceneView: View {
    var body: some View {
        VStack(spacing: AppSpacing.medium) {
            SessionVideoPlayerView()
                .aspectRatio(9.0 / 10.0, contentMode: .fit)
                .frame(maxWidth: 320)

            Text("Focus in progress")
                .font(AppFonts.title)
                .foregroundStyle(AppColors.textPrimary)
        }
    }
}

#Preview {
    SessionSceneView()
        .padding()
        .background(AppColors.background)
}
