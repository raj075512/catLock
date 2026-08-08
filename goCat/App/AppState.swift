import Foundation
import Observation

@MainActor
@Observable
final class AppState {
    var router = AppRouter()
    var preferences: UserPreferences

    private let settingsStore: SettingsStore

    init(settingsStore: SettingsStore = .shared) {
        self.settingsStore = settingsStore
        self.preferences = settingsStore.loadUserPreferences()
    }

    func completeOnboarding() {
        preferences.hasCompletedOnboarding = true
        settingsStore.saveUserPreferences(preferences)
    }

    func updatePreferences(_ preferences: UserPreferences) {
        self.preferences = preferences
        settingsStore.saveUserPreferences(preferences)
    }
}
