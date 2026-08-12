import Foundation

/// Everything the app remembers about how the user likes to work. Local only —
/// there is no account and nothing here is ever sent anywhere.
struct UserPreferences: Codable, Hashable {
    var selectedMinutes: Int

    /// The last value set in the custom picker. Kept separate from
    /// `selectedMinutes` so the fourth chip keeps reading "1h 20m" after the
    /// user taps back over to 25 — the custom length is remembered until it is
    /// changed, not until it is deselected.
    var customMinutes: Int?

    /// `nil` means silence, which is a valid choice: tapping the selected row
    /// in the Sounds sheet deselects it rather than refusing to.
    var selectedSoundID: SoundOption.ID?
    var selectedRoomID: RoomOption.ID

    var hasCompletedOnboarding: Bool
    var surveyAnswers: SurveyAnswers

    /// Prompts that have fired and must never fire again. The notification ask
    /// and the account offer each get exactly one chance; declining costs the
    /// user nothing and is not re-litigated.
    var retiredPrompts: Set<RetiredPrompt>

    var notificationsEnabled: Bool

    // MARK: - Accessibility

    /// Defaults on when iOS Reduce Motion is on, and can be overridden here.
    var reduceMotion: Bool
    var haptics: Bool
    /// Raises glass fills from translucent to a fully opaque `surface` with a
    /// `textSecondary` border. A translucent-panel design needs an opaque
    /// escape hatch, and this is it.
    var higherContrastPanels: Bool

    enum RetiredPrompt: String, Codable {
        case notifications
        case account
    }

    static let defaults = UserPreferences(
        selectedMinutes: 25,
        customMinutes: nil,
        selectedSoundID: SoundOption.rain.id,
        selectedRoomID: RoomOption.livingRoom.id,
        hasCompletedOnboarding: false,
        surveyAnswers: .empty,
        retiredPrompts: [],
        notificationsEnabled: false,
        reduceMotion: false,
        haptics: true,
        higherContrastPanels: false
    )

    var selectedSound: SoundOption? {
        selectedSoundID.map { SoundOption.option(id: $0) }
    }

    var selectedRoom: RoomOption {
        RoomOption.option(id: selectedRoomID)
    }
}
