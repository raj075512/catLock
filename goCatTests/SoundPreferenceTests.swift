import XCTest
@testable import goCat

/// The sound choice used to be thrown away on every launch: `selectedSoundID`
/// existed in UserPreferences and nothing read or wrote it. These pin the
/// behaviour down.
@MainActor
final class SoundPreferenceTests: XCTestCase {

    private func freshStore() -> SettingsStore {
        let defaults = UserDefaults(suiteName: "SoundPreferenceTests-\(UUID().uuidString)")!
        return SettingsStore(store: UserDefaultsStore(defaults: defaults))
    }

    func testThereIsAlwaysADefaultSound() {
        let viewModel = HomeViewModel(settingsStore: freshStore())

        XCTAssertEqual(viewModel.selectedSound, .rain,
                       "A user who never opens the Sounds sheet must still get a sound")
        XCTAssertTrue(viewModel.soundEnabled)
        XCTAssertEqual(viewModel.sessionSound, .rain)
    }

    func testChoiceSurvivesRelaunch() {
        let store = freshStore()
        let ocean = SoundOption.options.first { $0.id == "ocean" }!

        let first = HomeViewModel(settingsStore: store)
        first.selectSound(ocean)

        let relaunched = HomeViewModel(settingsStore: store)
        XCTAssertEqual(relaunched.selectedSound, ocean, "The sound choice must outlive the process")
    }

    func testSilenceSurvivesRelaunch() {
        let store = freshStore()

        let first = HomeViewModel(settingsStore: store)
        first.setSoundEnabled(false)
        XCTAssertNil(first.sessionSound, "Sound off means a session runs silently")

        let relaunched = HomeViewModel(settingsStore: store)
        XCTAssertFalse(relaunched.soundEnabled)
        XCTAssertNil(relaunched.sessionSound)
    }

    func testTurningSoundBackOnRestoresTheChosenSound() {
        let store = freshStore()
        let fireplace = SoundOption.options.first { $0.id == "fireplace" }!

        let viewModel = HomeViewModel(settingsStore: store)
        viewModel.selectSound(fireplace)
        viewModel.setSoundEnabled(false)
        XCTAssertNil(viewModel.sessionSound)

        viewModel.setSoundEnabled(true)
        XCTAssertEqual(viewModel.sessionSound, fireplace,
                       "Disabling sound must not forget which sound was chosen")
    }

    /// `purr` and `cafe` shipped in earlier builds. A stored selection of one
    /// of them must not leave the user with no sound at all.
    func testStoredSoundFromAnOlderBuildFallsBackToRain() {
        let defaults = UserDefaults(suiteName: "SoundPreferenceTests-legacy-\(UUID().uuidString)")!
        let store = SettingsStore(store: UserDefaultsStore(defaults: defaults))

        var preferences = UserPreferences.defaults
        preferences.selectedSoundID = "purr"
        store.saveUserPreferences(preferences)

        let viewModel = HomeViewModel(settingsStore: store)
        XCTAssertEqual(viewModel.selectedSound, .rain)
        XCTAssertNotNil(viewModel.sessionSound)
    }
}
