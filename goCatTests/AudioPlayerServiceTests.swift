import XCTest
@testable import goCat

final class AudioPlayerServiceTests: XCTestCase {
    @MainActor
    func testPlayStoresCurrentSound() {
        let service = AudioPlayerService()

        service.play(.rain)

        XCTAssertTrue(service.isPlaying)
        XCTAssertEqual(service.currentSound, .rain)
    }
}
