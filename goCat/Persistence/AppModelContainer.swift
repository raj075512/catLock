import Foundation
import SwiftData
// Required explicitly: the target builds with
// SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY, so `os`'s string-
// interpolation members (the `privacy:` argument) are not visible
// transitively through AppLogger.
import os

/// The app's one SwiftData container.
///
/// Replaced a half-finished split where a SwiftData container held only the
/// Xcode template's `Item` while an unused Core Data model sat alongside it.
/// One store, two models, no mapping layer.
enum AppModelContainer {
    static let shared: ModelContainer = {
        let schema = Schema([CompletedSession.self, TaskItem.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // A container that won't open means history and tasks are both
            // gone. Fall back to memory so the timer — the part that actually
            // matters — still works for this launch.
            AppLogger.persistence.error("Falling back to an in-memory store: \(error.localizedDescription, privacy: .public)")
            let memoryConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            // swiftlint:disable:next force_try
            return try! ModelContainer(for: schema, configurations: [memoryConfiguration])
        }
    }()

    static func inMemory() -> ModelContainer {
        let schema = Schema([CompletedSession.self, TaskItem.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        // swiftlint:disable:next force_try
        return try! ModelContainer(for: schema, configurations: [configuration])
    }
}
