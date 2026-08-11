import SwiftData
import SwiftUI

@main
struct GoCatApp: App {
#if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
#endif

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(AppModelContainer.shared)
    }
}
