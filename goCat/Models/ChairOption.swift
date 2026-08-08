import Foundation

struct ChairOption: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var thumbnailName: String
    var isPremium: Bool

    static let starter = ChairOption(
        id: "starter",
        name: "Simple Chair",
        thumbnailName: "chair_starter",
        isPremium: false
    )

    static let options: [ChairOption] = [
        .starter,
        ChairOption(id: "cushion", name: "Cushion Chair", thumbnailName: "chair_cushion", isPremium: false),
        ChairOption(id: "lounge", name: "Lounge Chair", thumbnailName: "chair_lounge", isPremium: true)
    ]
}
