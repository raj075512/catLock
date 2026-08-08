import Foundation

enum NavigationDestination: Hashable {
    case taskDetail(FocusTask.ID)
    case session(FocusSession.ID)
    case settings
}
