import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    var selectedScene = SceneOption.study
    var selectedSound = SoundOption.rain
    var sessionDuration: TimeInterval = 25 * 60

    func startFocusSession() -> FocusSession {
        FocusSession(plannedDuration: sessionDuration, state: .running)
    }
}
