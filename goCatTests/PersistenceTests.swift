import XCTest
@testable import goCat

final class PersistenceTests: XCTestCase {
    func testTaskPersistenceTitleTrimsWhitespace() {
        let task = FocusTask(title: "  Focus  ")

        XCTAssertEqual(task.persistenceTitle, "Focus")
    }
}
