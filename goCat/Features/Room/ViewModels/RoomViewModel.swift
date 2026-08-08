import Foundation
import Observation

@MainActor
@Observable
final class RoomViewModel {
    var purchasedItems: [String] = [
        "Simple Chair",
        "Study Scene"
    ]
}
