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
