import Foundation
import Observation

@MainActor
@Observable
final class PremiumAccessService {
    static let shared = PremiumAccessService()

    private(set) var hasPremiumAccess = false

    func updateAccess(_ isEnabled: Bool) {
        hasPremiumAccess = isEnabled
    }
}
