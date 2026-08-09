import SwiftUI
import UIKit

/// The full-bleed cat scene that sits behind the landing screen and the active
/// session. Using one component for both means the artwork never jumps or
/// reloads when a session starts — only the controls layered on top change.
///
/// `isAnimated` lets the caller choose the looping video (during a session, and
/// on the landing screen) versus the static poster frame. Reduce Motion always
/// wins and forces the poster.
struct CatSceneBackground: View {
    var isAnimated: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            // Matches the artwork's muted sage backdrop so the edges blend on
            // aspect ratios where the video doesn't cover the full screen.
            Color(red: 0.60, green: 0.65, blue: 0.60)

            if isAnimated && !reduceMotion {
                LoopingCatVideo()
            } else {
                CatScenePoster()
            }

            // Keeps the top badges and bottom glass panel legible against the
            // bright centre of the artwork.
            LinearGradient(
                colors: [
                    .black.opacity(0.18),
                    .clear,
                    .clear,
                    .black.opacity(0.12)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

/// Static first frame of the loop. Also used as the Reduce Motion fallback.
struct CatScenePoster: View {
    var body: some View {
        if let path = Bundle.main.path(forResource: "session_cat_poster", ofType: "jpg"),
           let uiImage = UIImage(contentsOfFile: path) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            AppColors.elevatedSurface
        }
    }
}

#Preview {
    CatSceneBackground()
}
