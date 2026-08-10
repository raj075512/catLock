import Foundation
import Observation

@MainActor
@Observable
final class FocusSessionViewModel {
    var timerService: FocusTimerService
    var session: FocusSession

    /// Set once the timer reaches zero, so the completion screen can show the
    /// new streak without re-reading the store.
    private(set) var completedStreak: Int?

    /// The ambient loop to run for the duration of the session, if any.
    private let sound: SoundOption?
    private let audio: AudioPlayerService

    init(
        session: FocusSession = FocusSession(),
        sound: SoundOption? = nil,
        streakStore: StreakStore = .shared,
        audio: AudioPlayerService = .shared
    ) {
        self.session = session
        self.sound = sound
        self.audio = audio
        self.timerService = FocusTimerService(duration: session.plannedDuration)

        timerService.onComplete = { [weak self] in
            guard let self else { return }
            self.session.state = .completed
            self.session.endedAt = .now
            self.completedStreak = streakStore.recordCompletedSession()
            // The trophy should land in silence, not over rain.
            self.audio.stop()
        }
    }

    var formattedRemainingTime: String {
        let total = Int(timerService.remainingSeconds)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func start() {
        timerService.start()
        session.state = .running

        if let sound {
            audio.play(sound)
        } else {
            // A silent session has to actually be silent. Without this, a
            // preview still running from the Sounds sheet would carry straight
            // into a session the user chose to run without sound.
            audio.stop()
        }
    }

    func cancel() {
        timerService.cancel()
        session.state = .cancelled
        session.endedAt = .now
        audio.stop()
    }

    /// Belt and braces: if the screen goes away for any reason we did not
    /// anticipate, the ambient loop must not outlive it.
    func stopAudio() {
        audio.stop()
    }
}
