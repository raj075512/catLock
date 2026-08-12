import Foundation

/// A room the cat sits in. The room and the ambient sound are the *only* two
/// things about the scene a user can change.
///
/// Rule 5: no cat, chair, collar, hat, colour or breed option may ever be
/// added here. The Room sheet's subhead — "Same cat, same chair. Different
/// room." — states that out loud so the absence reads as intent rather than
/// as a feature nobody got round to.
struct RoomOption: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    /// Base name of the room's clip in `Resources/Media/`. Each room needs a
    /// play-once variant, a seamless loop and a poster frame; only
    /// `session_cat` is bundled today, so the others fall back to it.
    var mediaName: String
    var isPremium: Bool

    static let livingRoom = RoomOption(
        id: "living_room",
        name: "Living room",
        mediaName: "session_cat",
        isPremium: false
    )

    static let options: [RoomOption] = [
        .livingRoom,
        RoomOption(id: "study", name: "Study", mediaName: "room_study", isPremium: false),
        RoomOption(id: "cabin", name: "Cabin", mediaName: "room_cabin", isPremium: false),
        RoomOption(id: "porch", name: "Porch", mediaName: "room_porch", isPremium: true),
        RoomOption(id: "library", name: "Library", mediaName: "room_library", isPremium: true),
        RoomOption(id: "night_porch", name: "Night porch", mediaName: "room_night_porch", isPremium: true)
    ]

    /// Resolve a persisted ID, falling back to Living room.
    ///
    /// Also the landing point for a lapsed subscriber: when Plus ends, a
    /// previously selected locked room silently falls back here and the Room
    /// sheet says so once.
    static func option(id: RoomOption.ID) -> RoomOption {
        options.first { $0.id == id } ?? .livingRoom
    }
}
