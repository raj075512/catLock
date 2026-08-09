import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    /// The three durations offered on the landing screen. Kept short and
    /// opinionated — picking a session should be one tap, not a stepper.
    static let durationPresets = [15, 25, 45]

    var selectedScene = SceneOption.study
    var selectedSound = SoundOption.rain
    var selectedMinutes = 25

    /// Placeholder until session history feeds this. Progress/streak tracking
    /// lands with the stats work — see DESIGN.md MVP scope.
    var currentStreak = 0

    var sessionDuration: TimeInterval {
        TimeInterval(selectedMinutes * 60)
    }

    func startFocusSession() -> FocusSession {
        FocusSession(plannedDuration: sessionDuration, state: .running)
    }
}
