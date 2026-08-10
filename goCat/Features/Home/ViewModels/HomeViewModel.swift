import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    /// The three fixed presets on the landing screen. Custom durations are
    /// handled separately (see `customMinutes`) rather than added here,
    /// since Custom needs its own picker sheet, not just another number.
    static let durationPresets = [15, 25, 45]

    var selectedScene = SceneOption.study
    var selectedSound = SoundOption.rain

    /// Off means a session runs silently. Sound is optional company, not a
    /// requirement — some people focus better with nothing at all.
    var soundEnabled = true
    var selectedMinutes = 25

    /// The last value set via the Custom picker, if any. Kept separate from
    /// `selectedMinutes` so the Custom chip can keep showing "1h 20m" even
    /// after the user taps back over to a preset like 25 min.
    var customMinutes: Int?
    var isShowingCustomPicker = false

    private let streakStore: StreakStore

    init(streakStore: StreakStore = .shared) {
        self.streakStore = streakStore
        self.currentStreak = streakStore.currentStreak
    }

    private(set) var currentStreak: Int

    /// Call after a focus session sheet dismisses — a completed session may
    /// have bumped the streak in the background via `StreakStore`.
    func refreshStreak() {
        currentStreak = streakStore.currentStreak
    }

    var isCustomSelected: Bool {
        customMinutes != nil && selectedMinutes == customMinutes
    }

    var customChipTitle: String {
        guard let customMinutes else { return "Custom" }
        let hours = customMinutes / 60
        let minutes = customMinutes % 60
        switch (hours, minutes) {
        case (0, let m):
            return "\(m) min"
        case (let h, 0):
            return "\(h)h"
        case (let h, let m):
            return "\(h)h \(m)m"
        }
    }

    func selectCustomDuration(_ minutes: Int) {
        customMinutes = minutes
        selectedMinutes = minutes
    }

    var sessionDuration: TimeInterval {
        TimeInterval(selectedMinutes * 60)
    }

    func startFocusSession() -> FocusSession {
        FocusSession(plannedDuration: sessionDuration, state: .running)
    }
}
