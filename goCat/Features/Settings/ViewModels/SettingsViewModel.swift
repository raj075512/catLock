import Foundation
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    var preferences: UserPreferences

    private let settingsStore: SettingsStore

    init(settingsStore: SettingsStore = .shared) {
        self.settingsStore = settingsStore
        self.preferences = settingsStore.loadUserPreferences()
    }

    func save() {
        settingsStore.saveUserPreferences(preferences)
    }
}
