import SwiftData
import SwiftUI

@main
struct GoCatApp: App {
#if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
#endif

    @State private var appState = AppState()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        .modelContainer(sharedModelContainer)
    }
}
