import Foundation
import Observation

@MainActor
@Observable
final class AudioPlayerService {
    static let shared = AudioPlayerService()

    private(set) var currentSound: SoundOption?
    private(set) var isPlaying = false

    func play(_ sound: SoundOption) {
        currentSound = sound
        isPlaying = true
    }

    func stop() {
        isPlaying = false
        currentSound = nil
    }
}
