import Foundation

enum TabItem: String, CaseIterable, Identifiable, Hashable {
    case home
    case tasks
    case room
    case progress
    case settings

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .home:
            "Home"
        case .tasks:
            "Tasks"
        case .room:
            "Room"
        case .progress:
            "Progress"
        case .settings:
            "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .home:
            "house"
        case .tasks:
            "checklist"
        case .room:
            "sofa"
        case .progress:
            "chart.bar"
        case .settings:
            "gearshape"
        }
    }
}
