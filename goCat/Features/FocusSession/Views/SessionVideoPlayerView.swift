import AVFoundation
import SwiftUI

/// Plays the default session companion loop (cat rocking in its chair) as a
/// silent, seamless, looping background video. This is the fixed "character"
/// for a focus session — there is intentionally no cat/chair customization,
/// keeping the session scene simple and consistent.
///
/// Falls back to a static poster frame when Reduce Motion is enabled, per the
/// app's accessibility guidelines in DESIGN.md.
struct SessionVideoPlayerView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            if reduceMotion {
                posterImage
            } else {
                LoopingVideoPlayer(resourceName: "session_cat_loop", resourceExtension: "mp4")
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
        .accessibilityHidden(true)
    }

    private var posterImage: some View {
        Group {
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
}

/// A chrome-less, muted, infinitely looping video view backed by
/// `AVQueuePlayer` + `AVPlayerLooper` for gapless playback. Lightweight by
/// design: no controls, no audio, no network — a single bundled asset.
private struct LoopingVideoPlayer: UIViewRepresentable {
    let resourceName: String
    let resourceExtension: String

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
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}

#Preview {
    SessionVideoPlayerView()
        .frame(width: 260, height: 320)
}
