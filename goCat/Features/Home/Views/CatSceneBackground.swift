import SwiftUI
import UIKit

/// The full-bleed cat scene that sits behind the landing screen and the active
/// session. Using one component for both keeps the artwork identical across
/// the two screens — only the controls layered on top change.
///
/// `playback` is what differs between them:
/// - Landing screen passes `.once`. The clip plays through a single time and
///   holds on its last frame, so the scene settles down while the user picks a
///   duration.
/// - An active session passes `.looping`, the original endless rocking.
///
/// Note that the session screen is a `fullScreenCover`, so it builds its own
/// player starting from frame 0 rather than inheriting the landing screen's
/// paused one. The clip is authored as a seamless loop (last frame meets first
/// frame), which is what keeps that handover from reading as a cut.
///
/// `isAnimated` still forces the static poster, and Reduce Motion always wins.
struct CatSceneBackground: View {
    var isAnimated: Bool = true
    var playback: CatSceneVideo.Playback = .looping

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            // Matches the artwork's muted sage backdrop so the edges blend on
            // aspect ratios where the video doesn't cover the full screen.
            Color(red: 0.60, green: 0.65, blue: 0.60)

            if isAnimated && !reduceMotion {
                CatSceneVideo(playback: playback)
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
    CatSceneBackground(playback: .once)
}
