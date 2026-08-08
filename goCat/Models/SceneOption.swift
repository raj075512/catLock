import Foundation

struct SceneOption: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var thumbnailName: String
    var isPremium: Bool

    static let study = SceneOption(
        id: "study",
        name: "Study",
        thumbnailName: "scene_study",
        isPremium: false
    )

    static let options: [SceneOption] = [
        .study,
        SceneOption(id: "window", name: "Window", thumbnailName: "scene_window", isPremium: false),
        SceneOption(id: "fireplace", name: "Fireplace", thumbnailName: "scene_fireplace", isPremium: true)
    ]
}
