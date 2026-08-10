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
    var selectedMinutes = 25

    /// The last value set via the Custom picker, if any. Kept separate from
    /// `selectedMinutes` so the Custom chip can keep showing "1h 20m" even
    /// after the user taps back over to a preset like 25 min.
    var customMinutes: Int?
    var isShowingCustomPicker = false

    /// There is always a selected sound — Rain by default — so a session never
    /// starts silent by accident. Silence is a deliberate choice via
    /// `soundEnabled`, not the result of never having picked one.
    private(set) var selectedSound: SoundOption
    private(set) var soundEnabled: Bool

    private(set) var currentStreak: Int

    private let streakStore: StreakStore
    private let settingsStore: SettingsStore

    init(streakStore: StreakStore = .shared, settingsStore: SettingsStore = .shared) {
        self.streakStore = streakStore
        self.settingsStore = settingsStore
        self.currentStreak = streakStore.currentStreak

        // Restore the previous choice. `option(id:)` falls back to Rain, which
        // matters for anyone whose stored ID is `purr` or `cafe` — sounds that
        // shipped in earlier builds and no longer exist.
        let preferences = settingsStore.loadUserPreferences()
        self.selectedSound = SoundOption.option(id: preferences.selectedSoundID)
        self.soundEnabled = preferences.soundEnabled
    }

    // MARK: - Sound

    func selectSound(_ sound: SoundOption) {
        selectedSound = sound
        persistSoundPreferences()
    }

    /// Set through a method rather than a `didSet` observer — property
    /// observers collide with the `@Observable` macro's generated accessors.
    func setSoundEnabled(_ isEnabled: Bool) {
        soundEnabled = isEnabled
        persistSoundPreferences()
    }

    /// The loop a session should run, or nil for silence.
    var sessionSound: SoundOption? {
        soundEnabled ? selectedSound : nil
    }

    private func persistSoundPreferences() {
        var preferences = settingsStore.loadUserPreferences()
        preferences.selectedSoundID = selectedSound.id
        preferences.soundEnabled = soundEnabled
        settingsStore.saveUserPreferences(preferences)
    }

    // MARK: - Streak

    /// Call after a focus session sheet dismisses — a completed session may
    /// have bumped the streak in the background via `StreakStore`.
    func refreshStreak() {
        currentStreak = streakStore.currentStreak
    }

    // MARK: - Duration

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
