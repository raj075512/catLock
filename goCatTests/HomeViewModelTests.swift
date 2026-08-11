import XCTest
@testable import goCat

final class HomeViewModelTests: XCTestCase {
    @MainActor
    private func makeState() -> AppState {
        let defaults = UserDefaults(suiteName: "HomeViewModelTests")!
        defaults.removePersistentDomain(forName: "HomeViewModelTests")
        return AppState(settingsStore: SettingsStore(store: UserDefaultsStore(defaults: defaults)))
    }

    @MainActor
    func testDefaultDurationIsTwentyFiveMinutes() {
        XCTAssertEqual(makeState().selectedMinutes, 25)
    }

    @MainActor
    func testSelectingPresetUpdatesDuration() {
        let state = makeState()

        state.selectPreset(45)

        XCTAssertEqual(state.selectedMinutes, 45)
        XCTAssertFalse(state.isCustomSelected)
    }

    /// The custom length is remembered until it is *changed*, not until it is
    /// deselected — tapping 25 must not wipe the value off the fourth chip.
    @MainActor
    func testCustomDurationSurvivesSelectingAPreset() {
        let state = makeState()

        state.setCustomDuration(80)
        XCTAssertTrue(state.isCustomSelected)
        XCTAssertEqual(state.selectedMinutes, 80)

        state.selectPreset(25)

        XCTAssertFalse(state.isCustomSelected)
        XCTAssertEqual(state.customMinutes, 80, "The custom value must still be on the chip")
    }

    @MainActor
    func testCustomChipTitleFormatsHoursAndMinutes() {
        let state = makeState()
        let viewModel = HomeViewModel(state: state)

        XCTAssertEqual(viewModel.customChipTitle, "Custom")

        state.setCustomDuration(80)
        XCTAssertEqual(viewModel.customChipTitle, "1h 20m")

        state.setCustomDuration(120)
        XCTAssertEqual(viewModel.customChipTitle, "2h")

        state.setCustomDuration(45)
        XCTAssertEqual(viewModel.customChipTitle, "45 min")
    }

    /// Silence is a real choice, reached by tapping the already-selected row.
    @MainActor
    func testSelectingNilSoundMeansSilence() {
        let state = makeState()

        state.selectSound(nil)

        XCTAssertNil(state.selectedSound)
    }
}
