import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class FocusSessionViewModel {
    enum Outcome: Equatable {
        case running
        case cancelled
        case completed
    }

    private(set) var outcome: Outcome = .running
    private(set) var streakAfterCompletion = 0
    private(set) var isFirstEverCompletion = false

    let minutes: Int
    let room: RoomOption

    var timerService: FocusTimerService

    private let sound: SoundOption?
    private let audio: AudioPlayerService
    private let streakStore: StreakStore
    private let activeSessionStore: ActiveSessionStore
    /// Set by the view once SwiftData's context is available, so a completed
    /// session is written to history.
    var modelContext: ModelContext?

    init(
        minutes: Int,
        sound: SoundOption?,
        room: RoomOption,
        restoring: ActiveSession? = nil,
        audio: AudioPlayerService = .shared,
        streakStore: StreakStore = .shared,
        activeSessionStore: ActiveSessionStore = .shared
    ) {
        self.minutes = restoring?.minutes ?? minutes
        self.sound = restoring.map { $0.soundID.map(SoundOption.option(id:)) } ?? sound
        self.room = room
        self.audio = audio
        self.streakStore = streakStore
        self.activeSessionStore = activeSessionStore
        self.timerService = FocusTimerService(duration: TimeInterval((restoring?.minutes ?? minutes) * 60))
        self.restoredEndDate = restoring?.endDate

        timerService.onComplete = { [weak self] in
            self?.handleCompletion()
        }
    }

    private let restoredEndDate: Date?

    var formattedRemainingTime: String {
        let total = Int(timerService.remainingSeconds.rounded(.up))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var isInFinalMinute: Bool { timerService.isInFinalMinute }
    var finalMinuteProgress: Double { timerService.finalMinuteProgress }

    func start() {
        guard outcome == .running, timerService.state != .running else { return }

        timerService.start(endingAt: restoredEndDate)

        if let endDate = timerService.endDate {
            activeSessionStore.begin(
                ActiveSession(endDate: endDate, minutes: minutes, soundID: sound?.id)
            )
        }

        if let sound {
            audio.play(sound)
        } else {
            // A silent session has to actually be silent. Without this, a
            // preview still running from the Sounds sheet would carry straight
            // into a session the user chose to run without sound.
            audio.stop()
        }

        // The end date may already have passed if the app was away long enough.
        timerService.refresh()
    }

    /// One tap, immediate, no confirmation dialog — including at 00:01, where
    /// a cancel still discards.
    func cancel() {
        timerService.cancel()
        audio.stop()
        activeSessionStore.clear()
        outcome = .cancelled
    }

    /// The clock kept running while the app was backgrounded.
    func refresh() {
        timerService.refresh()
    }

    func stopAudio() {
        audio.stop()
    }

    private func handleCompletion() {
        isFirstEverCompletion = !streakStore.hasEverCompleted
        streakAfterCompletion = streakStore.recordCompletedSession()

        modelContext?.insert(
            CompletedSession(minutes: minutes, soundName: sound?.name)
        )

        activeSessionStore.clear()
        // The trophy should land in silence, not over rain.
        audio.stop()
        HapticManager.shared.success()
        outcome = .completed
    }
}
