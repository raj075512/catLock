import Foundation

final class SettingsStore {
    static let shared = SettingsStore()

    private enum Keys {
        static let preferences = "userPreferences"
    }

    private let store: UserDefaultsStore

    init(store: UserDefaultsStore = .shared) {
        self.store = store
    }

    func loadUserPreferences() -> UserPreferences {
        store.value(forKey: Keys.preferences, fallback: .defaults)
    }

    func saveUserPreferences(_ preferences: UserPreferences) {
        store.set(preferences, forKey: Keys.preferences)
    }
}
