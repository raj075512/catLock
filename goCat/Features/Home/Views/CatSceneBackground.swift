import SwiftUI
import UIKit

/// The full-bleed cat scene behind Home and behind an active session. One
/// component for both, so the handover between them is invisible — only the
/// controls layered on top change.
///
/// `playback` is the whole difference:
/// - Home passes `.once`. The clip plays through a single time and holds its
///   last frame.
/// - A session passes `.looping`.
///
/// That split is load-bearing, not decorative: **motion means a session is
/// running.** It is never the only signal, though — the countdown is always
/// the source of truth, which is what lets Reduce Motion swap the whole thing
/// for a still room without losing information.
struct CatSceneBackground: View {
    var room: RoomOption = .livingRoom
    var playback: CatSceneVideo.Playback = .looping

    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    private var state: AppState { AppState.shared }

    var body: some View {
        ZStack {
            // Matches the artwork's muted sage backdrop so the edges blend on
            // aspect ratios where the video doesn't cover the full screen.
            Color(red: 0.60, green: 0.65, blue: 0.60)

            if state.prefersReducedMotion(system: systemReduceMotion) {
                CatScenePoster(room: room)
            } else {
                CatSceneVideo(playback: playback, resourceName: room.loopResourceName)
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

/// Static frame of the room. The Reduce Motion fallback, and the Room grid's
/// thumbnail.
struct CatScenePoster: View {
    var room: RoomOption = .livingRoom

    var body: some View {
        if let path = Bundle.main.path(forResource: room.posterResourceName, ofType: "jpg"),
           let uiImage = UIImage(contentsOfFile: path) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            AppColors.elevatedSurface
        }
    }
}

extension RoomOption {
    /// Only the Living room's clip is bundled today. The rest resolve to it so
    /// selecting a room is real and persists, rather than showing a black
    /// screen for art that hasn't been produced yet.
    var loopResourceName: String {
        let candidate = "\(mediaName)_loop"
        return Bundle.main.url(forResource: candidate, withExtension: "mp4") != nil
            ? candidate
            : "session_cat_loop"
    }

    var posterResourceName: String {
        let candidate = "\(mediaName)_poster"
        return Bundle.main.path(forResource: candidate, ofType: "jpg") != nil
            ? candidate
            : "session_cat_poster"
    }
}

#Preview {
    CatSceneBackground(playback: .once)
}
