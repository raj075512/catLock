import Foundation

enum FocusSessionState: String, Codable, CaseIterable, Hashable {
    case idle
    case running
    case paused
    case completed
    case cancelled

    var title: String {
        switch self {
        case .idle:
            "Idle"
        case .running:
            "Running"
        case .paused:
            "Paused"
        case .completed:
            "Completed"
        case .cancelled:
            "Cancelled"
        }
    }
}
