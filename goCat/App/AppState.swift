import Foundation
import Observation
import SwiftUI

/// App-wide, user-facing state: what they picked, and what they've turned on.
///
/// A singleton rather than an injected environment object, because the glass
/// panels read `higherContrastPanels` from deep inside sheets and covers, and
/// threading an optional environment value through every one of them made the
/// accessibility switch easy to forget and impossible to verify.
@MainActor
@Observable
final class AppState {
    static let shared = AppState()

    private(set) var preferences: UserPreferences

    private let settingsStore: SettingsStore

    init(settingsStore: SettingsStore = .shared) {
        self.settingsStore = settingsStore

        // UI tests need a first-run app on every launch, and the simulator
        // keeps UserDefaults between runs.
        if ProcessInfo.processInfo.arguments.contains("-resetState") {
            self.preferences = .defaults
            settingsStore.saveUserPreferences(.defaults)
        } else {
            self.preferences = settingsStore.loadUserPreferences()
        }
    }

    // MARK: - Duration

    var selectedMinutes: Int { preferences.selectedMinutes }
    var customMinutes: Int? { preferences.customMinutes }

    /// True when the fourth chip is the active one. A custom value stays
    /// remembered — and stays on the chip — after tapping back to a preset.
    var isCustomSelected: Bool {
        guard let custom = preferences.customMinutes else { return false }
        return preferences.selectedMinutes == custom
    }

    func selectPreset(_ minutes: Int) {
        mutate { $0.selectedMinutes = minutes }
    }

    func setCustomDuration(_ minutes: Int) {
        mutate {
            $0.customMinutes = minutes
            $0.selectedMinutes = minutes
        }
    }

    // MARK: - Scene

    var selectedSound: SoundOption? { preferences.selectedSound }
    var selectedRoom: RoomOption { preferences.selectedRoom }

    /// Passing `nil` selects silence, which the Sounds sheet reaches by tapping
    /// the already-selected row.
    func selectSound(_ sound: SoundOption?) {
        mutate { $0.selectedSoundID = sound?.id }
    }

    func selectRoom(_ room: RoomOption) {
        mutate { $0.selectedRoomID = room.id }
    }

    // MARK: - Onboarding

    var hasCompletedOnboarding: Bool { preferences.hasCompletedOnboarding }
    var surveyAnswers: SurveyAnswers { preferences.surveyAnswers }

    /// Set when onboarding ends by starting a session, and consumed by Home.
    ///
    /// Onboarding cannot present that session itself: completing onboarding
    /// flips `RootView` over to Home, which tears the onboarding view — and
    /// any cover it was presenting — straight back down. Home starts it on
    /// appear instead, which is also what makes the handover invisible.
    var pendingFirstSessionMinutes: Int?

    func completeOnboarding(answers: SurveyAnswers) {
        mutate {
            $0.surveyAnswers = answers
            $0.hasCompletedOnboarding = true
            if let span = answers.focusSpan {
                $0.selectedMinutes = span.defaultMinutes
            }
        }
    }

    /// Settings › Replay intro. Sends the user back through "How it works"
    /// only — the survey has already been answered and asking again would
    /// overwrite settings they may have since changed by hand.
    func replayIntro() {
        mutate { $0.hasCompletedOnboarding = false }
    }

    func retirePrompt(_ prompt: UserPreferences.RetiredPrompt) {
        mutate { $0.retiredPrompts.insert(prompt) }
    }

    func hasRetired(_ prompt: UserPreferences.RetiredPrompt) -> Bool {
        preferences.retiredPrompts.contains(prompt)
    }

    func setNotificationsEnabled(_ isEnabled: Bool) {
        mutate { $0.notificationsEnabled = isEnabled }
    }

    // MARK: - Accessibility

    var haptics: Bool { preferences.haptics }
    var higherContrastPanels: Bool { preferences.higherContrastPanels }

    /// The user's own switch. Combine with the system setting via
    /// `prefersReducedMotion(system:)` — either one turning it on is enough.
    var reduceMotion: Bool { preferences.reduceMotion }

    func prefersReducedMotion(system: Bool) -> Bool {
        preferences.reduceMotion || system
    }

    func setReduceMotion(_ isOn: Bool) { mutate { $0.reduceMotion = isOn } }
    func setHaptics(_ isOn: Bool) { mutate { $0.haptics = isOn } }
    func setHigherContrastPanels(_ isOn: Bool) { mutate { $0.higherContrastPanels = isOn } }

    private func mutate(_ change: (inout UserPreferences) -> Void) {
        var updated = preferences
        change(&updated)
        preferences = updated
        settingsStore.saveUserPreferences(updated)
    }
}
