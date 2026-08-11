import XCTest
@testable import goCat

/// The sound choice used to be thrown away on every launch: `selectedSoundID`
/// existed in UserPreferences and nothing read or wrote it. These pin the
/// behaviour down.
///
/// Silence is now modelled as `nil` rather than a separate `soundEnabled`
/// flag, which is what the Sounds sheet needs: tapping the selected row
/// deselects it, and there is no "None" row to select instead.
@MainActor
final class SoundPreferenceTests: XCTestCase {

    private func freshState() -> AppState {
        let defaults = UserDefaults(suiteName: "SoundPreferenceTests-\(UUID().uuidString)")!
        return AppState(settingsStore: SettingsStore(store: UserDefaultsStore(defaults: defaults)))
    }

    private func state(sharing store: SettingsStore) -> AppState {
        AppState(settingsStore: store)
    }

    private func freshStore() -> SettingsStore {
        let defaults = UserDefaults(suiteName: "SoundPreferenceTests-\(UUID().uuidString)")!
        return SettingsStore(store: UserDefaultsStore(defaults: defaults))
    }

    func testThereIsAlwaysADefaultSound() {
        let state = freshState()

        XCTAssertEqual(
            state.selectedSound,
            .rain,
            "A user who never opens the Sounds sheet must still get a sound"
        )
    }

    func testChoiceSurvivesRelaunch() {
        let store = freshStore()
        let ocean = SoundOption.options.first { $0.id == "ocean" }!

        state(sharing: store).selectSound(ocean)

        XCTAssertEqual(
            state(sharing: store).selectedSound,
            ocean,
            "The sound choice must outlive the process"
        )
    }

    func testSilenceSurvivesRelaunch() {
        let store = freshStore()

        let first = state(sharing: store)
        first.selectSound(nil)
        XCTAssertNil(first.selectedSound, "Deselecting means a session runs silently")

        XCTAssertNil(state(sharing: store).selectedSound)
    }

    func testChoosingASoundAfterSilenceWorks() {
        let store = freshStore()
        let fireplace = SoundOption.options.first { $0.id == "fireplace" }!

        let state = state(sharing: store)
        state.selectSound(nil)
        XCTAssertNil(state.selectedSound)

        state.selectSound(fireplace)
        XCTAssertEqual(state.selectedSound, fireplace)
    }

    /// `purr` and `cafe` shipped in earlier builds. A stored selection of one
    /// of them must not leave the user with no sound at all.
    func testStoredSoundFromAnOlderBuildFallsBackToRain() {
        let store = freshStore()

        var preferences = UserPreferences.defaults
        preferences.selectedSoundID = "purr"
        store.saveUserPreferences(preferences)

        XCTAssertEqual(state(sharing: store).selectedSound, .rain)
    }
}
