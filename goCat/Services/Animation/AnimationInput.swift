import Foundation

enum AnimationInput: String, Codable, Hashable {
    case idle
    case focusing
    case paused
    case completed
    case sleeping
}
