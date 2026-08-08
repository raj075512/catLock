import SwiftData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    init(inMemory: Bool = false) {
        let schema = Schema([
            Item.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)

        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
