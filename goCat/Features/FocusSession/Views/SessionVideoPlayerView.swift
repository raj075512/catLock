import AVFoundation
import os
import SwiftUI
import UIKit

/// A chrome-less, muted, infinitely looping playback of the default companion
/// clip (cat rocking in its chair), backed by `AVQueuePlayer` +
/// `AVPlayerLooper` for gapless looping.
///
/// Lightweight by design: no controls, no audio, no network — one bundled
/// asset. This is the fixed session "character"; there is intentionally no
/// cat/chair customization anywhere in the app.
///
/// Callers generally want `CatSceneBackground` instead, which adds the Reduce
/// Motion fallback and the legibility scrim used by the landing screen and the
/// active session.
struct LoopingCatVideo: UIViewRepresentable {
    var resourceName: String = "session_cat_loop"
    var resourceExtension: String = "mp4"

    func makeUIView(context: Context) -> LoopingPlayerUIView {
        LoopingPlayerUIView(resourceName: resourceName, resourceExtension: resourceExtension)
    }

    func updateUIView(_ uiView: LoopingPlayerUIView, context: Context) {}
}

final class LoopingPlayerUIView: UIView {
    private var queuePlayer: AVQueuePlayer?
    private var playerLooper: AVPlayerLooper?
    private let playerLayer = AVPlayerLayer()

    init(resourceName: String, resourceExtension: String) {
        super.init(frame: .zero)

        guard let url = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension) else {
            AppLogger.app.error("Missing bundled session video asset: \(resourceName, privacy: .public).\(resourceExtension, privacy: .public)")
            return
        }

        let item = AVPlayerItem(url: url)
        let player = AVQueuePlayer(playerItem: item)
        player.isMuted = true
        player.actionAtItemEnd = .none

        playerLooper = AVPlayerLooper(player: player, templateItem: item)
        queuePlayer = player

        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)

        player.play()

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

    @objc private func handleDidEnterBackground() {
        queuePlayer?.pause()
    }

    @objc private func handleWillEnterForeground() {
        queuePlayer?.play()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}

#Preview {
    LoopingCatVideo()
        .frame(width: 260, height: 320)
}
