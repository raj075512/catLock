import Foundation
import OSLog

final class AudioSessionManager {
    static let shared = AudioSessionManager()

    private init() {}

    func configureForAmbientPlayback() {
        AppLogger.audio.debug("Ambient audio session configuration requested")
    }
}
