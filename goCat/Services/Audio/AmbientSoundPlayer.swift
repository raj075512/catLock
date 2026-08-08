import Foundation
import Observation

@MainActor
@Observable
final class AmbientSoundPlayer {
    private let audioPlayerService: AudioPlayerService

    var isPlaying: Bool {
        audioPlayerService.isPlaying
    }

    init(audioPlayerService: AudioPlayerService = .shared) {
        self.audioPlayerService = audioPlayerService
    }

    func toggle(sound: SoundOption) {
        if audioPlayerService.isPlaying {
            audioPlayerService.stop()
        } else {
            audioPlayerService.play(sound)
        }
    }
}
