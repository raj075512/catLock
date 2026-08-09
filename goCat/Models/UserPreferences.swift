import Foundation

struct UserPreferences: Codable, Hashable {
    var selectedSceneID: SceneOption.ID
    var selectedSoundID: SoundOption.ID
    var focusDuration: TimeInterval
    var breakDuration: TimeInterval
    var notificationsEnabled: Bool
    var soundEnabled: Bool
    var hasCompletedOnboarding: Bool

    static let defaults = UserPreferences(
        selectedSceneID: SceneOption.study.id,
        selectedSoundID: SoundOption.rain.id,
        focusDuration: 25 * 60,
        breakDuration: 5 * 60,
        notificationsEnabled: false,
        soundEnabled: true,
        hasCompletedOnboarding: false
    )
}
