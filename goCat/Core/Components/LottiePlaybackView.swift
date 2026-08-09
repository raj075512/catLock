import Lottie
import SwiftUI

/// Plays a bundled `.lottie` file once and reports back when it's done.
/// Used for the two session outcomes — the trophy on completion, the sad
/// trash can on cancellation — both one-shot, not looping.
///
/// `DotLottieFile` has no public initializer: a `.lottie` is a zip archive
/// that has to be unpacked before it can be played, so Lottie only exposes
/// async loaders (`DotLottieFile.named(_:)`). `LottieView`'s async-closure
/// initializer handles that for us and renders the placeholder until the
/// file is ready.
struct LottiePlaybackView: View {
    let resourceName: String
    var onFinish: (() -> Void)?

    var body: some View {
        LottieView {
            try await DotLottieFile.named(resourceName)
        } placeholder: {
            Color.clear
        }
        .playing(loopMode: .playOnce)
        .animationDidFinish { completed in
            if completed {
                onFinish?()
            }
        }
    }
}
