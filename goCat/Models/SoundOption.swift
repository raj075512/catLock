import Foundation

struct SoundOption: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    /// Base name of the bundled `.m4a` in `Resources/Audio/`.
    var resourceName: String
    var isPremium: Bool

    /// Per-sound playback multiplier, applied on top of the user's volume.
    ///
    /// The files are all normalised to −23 LUFS except `fireplace`, whose
    /// crackle peaks cap it around −27, so it gets a lift here rather than
    /// being re-rendered with the transients squashed. Loudness matching for
    /// noise is ultimately a judgement call — these are starting values.
    /// **Tune them by ear on a real device, in a quiet room, at low volume.**
    var gainTrim: Float = 1.0

    static let rain = SoundOption(
        id: "rain",
        name: "Rain",
        resourceName: "rain",
        isPremium: false
    )

    static let options: [SoundOption] = [
        .rain,
        SoundOption(id: "ocean", name: "Ocean", resourceName: "ocean", isPremium: false),
        SoundOption(id: "fireplace", name: "Fireplace", resourceName: "fireplace", isPremium: true, gainTrim: 1.5),
        SoundOption(id: "white_noise", name: "White Noise", resourceName: "white_noise", isPremium: false),
        SoundOption(id: "pink_noise", name: "Pink Noise", resourceName: "pink_noise", isPremium: true),
        SoundOption(id: "brown_noise", name: "Brown Noise", resourceName: "brown_noise", isPremium: true)
    ]
}
