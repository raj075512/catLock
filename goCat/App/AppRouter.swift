import SwiftUI

@MainActor
@Observable
final class AppRouter {
    var selectedTab: TabItem = .home
    var navigationPath = NavigationPath()

    func reset() {
        selectedTab = .home
        navigationPath = NavigationPath()
    }
}
