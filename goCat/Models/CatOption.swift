import Foundation

struct CatOption: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var thumbnailName: String
    var isPremium: Bool

    static let starter = CatOption(
        id: "starter",
        name: "Starter Cat",
        thumbnailName: "cat_starter",
        isPremium: false
    )

    static let options: [CatOption] = [
        .starter,
        CatOption(id: "calm", name: "Calm Cat", thumbnailName: "cat_calm", isPremium: false),
        CatOption(id: "midnight", name: "Midnight Cat", thumbnailName: "cat_midnight", isPremium: true)
    ]
}
