import Foundation

struct SoundOption: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var resourceName: String
    var isPremium: Bool

    static let rain = SoundOption(
        id: "rain",
        name: "Rain",
        resourceName: "rain",
        isPremium: false
    )

    static let options: [SoundOption] = [
        .rain,
        SoundOption(id: "purr", name: "Purr", resourceName: "purr", isPremium: false),
        SoundOption(id: "fireplace", name: "Fireplace", resourceName: "fireplace", isPremium: true),
        SoundOption(id: "ocean", name: "Ocean", resourceName: "ocean", isPremium: true),
        SoundOption(id: "cafe", name: "Cafe", resourceName: "cafe", isPremium: true),
        SoundOption(id: "white_noise", name: "White Noise", resourceName: "white_noise", isPremium: false)
    ]
}
