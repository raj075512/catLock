import AVFoundation
import XCTest
@testable import goCat

/// These exist because the Sounds feature shipped for weeks with an empty
/// `Resources/Audio/` folder and a test suite that was green the whole time.
/// The old test asserted that a Bool flipped. These assert that audio exists.
final class SoundAssetTests: XCTestCase {

    func testEverySoundOptionHasABundledFile() {
        for option in SoundOption.options {
            XCTAssertNotNil(
                Bundle.main.url(forResource: option.resourceName, withExtension: "m4a"),
                "No bundled audio for '\(option.name)' (expected \(option.resourceName).m4a)"
            )
        }
    }

    func testEverySoundIsDecodableAndNonSilent() throws {
        for option in SoundOption.options {
            let url = try XCTUnwrap(Bundle.main.url(forResource: option.resourceName, withExtension: "m4a"))
            let player = try AVAudioPlayer(contentsOf: url)

            XCTAssertGreaterThan(player.duration, 30, "\(option.name) is shorter than a usable loop")
            XCTAssertEqual(player.numberOfChannels, 1, "\(option.name) should be mono to keep the bundle small")
        }
    }

    func testGainTrimIsSane() {
        for option in SoundOption.options {
            XCTAssertGreaterThan(option.gainTrim, 0, "\(option.name) would be silent")
            XCTAssertLessThanOrEqual(option.gainTrim, 2.0, "\(option.name) trim is high enough to clip")
        }
    }

    @MainActor
    func testTogglingTheSameSoundStopsIt() {
        let service = AudioPlayerService.shared
        service.stop()

        service.toggle(.rain)
        XCTAssertTrue(service.isPlaying)
        XCTAssertEqual(service.currentSound, .rain)

        service.toggle(.rain)
        XCTAssertFalse(service.isPlaying)
        XCTAssertNil(service.currentSound)
    }
}

/// Regression tests for defects found while wiring the audio up.
extension SoundAssetTests {

    /// `purr` and `cafe` shipped in earlier builds and were removed. Anyone who
    /// had one selected still has that ID persisted.
    func testRemovedSoundIDsFallBackInsteadOfVanishing() {
        XCTAssertEqual(SoundOption.option(id: "purr"), .rain)
        XCTAssertEqual(SoundOption.option(id: "cafe"), .rain)
        XCTAssertEqual(SoundOption.option(id: "nonsense"), .rain)
    }

    func testKnownSoundIDsStillResolveToThemselves() {
        for option in SoundOption.options {
            XCTAssertEqual(SoundOption.option(id: option.id), option)
        }
    }

    /// The sound is meant to play *during* a session. It previously only
    /// previewed in the picker and then went silent the moment focusing began.
    @MainActor
    func testSessionStartsAndStopsTheSelectedSound() {
        let audio = AudioPlayerService.shared
        audio.stop()

        let viewModel = FocusSessionViewModel(
            minutes: 1,
            sound: .rain,
            room: .livingRoom
        )

        viewModel.start()
        XCTAssertTrue(audio.isPlaying, "Starting a session should start the chosen sound")

        viewModel.cancel()
        XCTAssertFalse(audio.isPlaying, "Cancelling a session must stop the sound")
    }

    @MainActor
    func testSessionWithNoSoundStaysSilent() {
        let audio = AudioPlayerService.shared
        audio.stop()

        let viewModel = FocusSessionViewModel(
            minutes: 1,
            sound: nil,
            room: .livingRoom
        )
        viewModel.start()

        XCTAssertFalse(audio.isPlaying, "A session with sound disabled must run silently")
    }
}
