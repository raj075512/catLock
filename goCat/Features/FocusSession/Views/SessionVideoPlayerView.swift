import AVFoundation
import os
import SwiftUI
import UIKit

/// Chrome-less, muted playback of the default companion clip (cat rocking in
/// its chair). Two modes:
///
/// - `.looping` — gapless infinite loop via `AVQueuePlayer` + `AVPlayerLooper`.
///   Used during an active focus session, where the motion is the point.
/// - `.once` — plays through a single time and holds on the last frame. Used
///   on the landing screen, so the scene settles into a still while the user
///   is picking a duration instead of rocking at them indefinitely.
///
/// Lightweight by design: no controls, no audio, no network — one bundled
/// asset. This is the fixed session "character"; there is intentionally no
/// cat/chair customization anywhere in the app.
///
/// Callers generally want `CatSceneBackground` instead, which adds the Reduce
/// Motion fallback and the legibility scrim used by the landing screen and the
/// active session.
struct CatSceneVideo: UIViewRepresentable {
    enum Playback {
        case looping
        case once
    }

    var playback: Playback = .looping
    var resourceName: String = "session_cat_loop"
    var resourceExtension: String = "mp4"

    func makeUIView(context: Context) -> CatScenePlayerUIView {
        CatScenePlayerUIView(
            playback: playback,
            resourceName: resourceName,
            resourceExtension: resourceExtension
        )
    }

    /// Playback mode is fixed for the lifetime of the view. Each screen builds
    /// its own instance, so there's nothing to reconcile here — and re-reading
    /// the mode mid-flight would risk restarting the clip on an unrelated
    /// SwiftUI update.
    func updateUIView(_ uiView: CatScenePlayerUIView, context: Context) {}
}

final class CatScenePlayerUIView: UIView {
    private let playback: CatSceneVideo.Playback
    private var player: AVPlayer?
    private var playerLooper: AVPlayerLooper?
    private let playerLayer = AVPlayerLayer()

    /// Set once the single run finishes in `.once` mode. Guards the
    /// foreground-resume path so returning to the app doesn't quietly hand the
    /// user a second run of an animation that's meant to play exactly once.
    private var hasFinishedSingleRun = false

    init(playback: CatSceneVideo.Playback, resourceName: String, resourceExtension: String) {
        self.playback = playback
        super.init(frame: .zero)

        guard let url = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension) else {
            AppLogger.app.error("Missing bundled session video asset: \(resourceName, privacy: .public).\(resourceExtension, privacy: .public)")
            return
        }

        let item = AVPlayerItem(url: url)
        let activePlayer: AVPlayer

        switch playback {
        case .looping:
            let queuePlayer = AVQueuePlayer(playerItem: item)
            // `.none` hands end-of-item handling to the looper.
            queuePlayer.actionAtItemEnd = .none
            playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
            activePlayer = queuePlayer

        case .once:
            let singlePlayer = AVPlayer(playerItem: item)
            // Hold on the final frame rather than blanking the layer.
            singlePlayer.actionAtItemEnd = .pause
            activePlayer = singlePlayer

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleDidPlayToEnd),
                name: AVPlayerItem.didPlayToEndTimeNotification,
                object: item
            )
        }

        activePlayer.isMuted = true
        player = activePlayer

        playerLayer.player = activePlayer
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)

        activePlayer.play()

        // Suspend decoding while backgrounded so a long focus session isn't
        // burning cycles on frames nobody can see.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handleDidPlayToEnd() {
        hasFinishedSingleRun = true
    }

    @objc private func handleDidEnterBackground() {
        player?.pause()
    }

    @objc private func handleWillEnterForeground() {
        guard !hasFinishedSingleRun else { return }
        player?.play()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}

#Preview {
    CatSceneVideo(playback: .once)
        .frame(width: 260, height: 320)
}
